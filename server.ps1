param(
    [int]$Port = 8080,
    [switch]$NoBrowser
)

$baseDir = $PSScriptRoot
if (-not $baseDir -or -not (Test-Path $baseDir)) {
    $baseDir = (Get-Location).Path
}

function Get-AvailablePort([int]$startPort) {
    $p = $startPort
    while ($p -lt ($startPort + 50)) {
        $ipGlobalProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
        $tcpEndPoints = $ipGlobalProperties.GetActiveTcpListeners()
        $isUsed = $false
        foreach ($ep in $tcpEndPoints) {
            if ($ep.Port -eq $p) {
                $isUsed = $true
                break
            }
        }
        if (-not $isUsed) { return $p }
        $p++
    }
    return $startPort
}

$Port = Get-AvailablePort $Port
$prefix = "http://localhost:$Port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Host "[ERRO] Nao foi possivel iniciar na porta $Port : $_" -ForegroundColor Red
    exit 1
}

$url = "http://localhost:$Port/index.html"
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  WEBGIS 3D - PARQUE ESTADUAL DA SERRA DO TABULEIRO" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Servidor local rodando em: $url" -ForegroundColor Yellow
Write-Host " Suporte completo a streaming de Video 360 (HTTP Range 206)" -ForegroundColor DarkGray
Write-Host " Pressione Ctrl+C para encerrar o servidor." -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Green

if (-not $NoBrowser) {
    try {
        Start-Process $url
    } catch {
        Write-Host "Abra manualmente no navegador: $url" -ForegroundColor Yellow
    }
}

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".mjs"  = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json"
    ".geojson" = "application/json"
    ".gltf" = "model/gltf+json"
    ".glb"  = "model/gltf-binary"
    ".bin"  = "application/octet-stream"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".tif"  = "image/tiff"
    ".tiff" = "image/tiff"
    ".mp4"  = "video/mp4"
    ".webm" = "video/webm"
    ".dae"  = "model/vnd.collada+xml"
}

try {
    while ($listener.IsListening) {
        $context = $null
        try {
            $context = $listener.GetContext()
            $req = $context.Request
            $res = $context.Response

            $res.Headers.Add("Access-Control-Allow-Origin", "*")
            $res.Headers.Add("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS")
            $res.Headers.Add("Access-Control-Allow-Headers", "*")
            $res.Headers.Add("Accept-Ranges", "bytes")

            if ($req.HttpMethod -eq "OPTIONS") {
                $res.StatusCode = 200
                $res.Close()
                continue
            }

            $rawPath = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath)
            if ($rawPath -eq "/" -or $rawPath -eq "") {
                $rawPath = "/index.html"
            }

            $cleanRelPath = $rawPath.TrimStart('/').Replace('/', [System.IO.Path]::DirectorySeparatorChar)
            $localPath = [System.IO.Path]::Combine($baseDir, $cleanRelPath)

            if (-not (Test-Path $localPath -PathType Leaf)) {
                $res.StatusCode = 404
                $notFoundBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $rawPath")
                $res.ContentType = "text/plain"
                $res.ContentLength64 = $notFoundBytes.Length
                $res.OutputStream.Write($notFoundBytes, 0, $notFoundBytes.Length)
                $res.Close()
                continue
            }

            $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
            $contentType = "application/octet-stream"
            if ($mimeTypes.ContainsKey($ext)) {
                $contentType = $mimeTypes[$ext]
            }
            $res.ContentType = $contentType

            $fileInfo = New-Object System.IO.FileInfo($localPath)
            $fileLength = $fileInfo.Length

            $rangeHeader = $req.Headers["Range"]
            if ($rangeHeader -and $rangeHeader -match "bytes=(\d*)-(\d*)") {
                $start = 0
                $end = $fileLength - 1

                if ($matches[1] -ne "") {
                    $start = [int64]$matches[1]
                }
                if ($matches[2] -ne "") {
                    $end = [int64]$matches[2]
                }

                if ($start -ge $fileLength -or $end -ge $fileLength -or $start -gt $end) {
                    $res.StatusCode = 416
                    $res.Headers.Add("Content-Range", "bytes */$fileLength")
                    $res.Close()
                    continue
                }

                $count = $end - $start + 1
                $res.StatusCode = 206
                $res.Headers.Add("Content-Range", "bytes $start-$end/$fileLength")
                $res.ContentLength64 = $count

                if ($req.HttpMethod -ne "HEAD") {
                    $fs = [System.IO.File]::OpenRead($localPath)
                    try {
                        $null = $fs.Seek($start, [System.IO.SeekOrigin]::Begin)
                        $buffer = New-Object byte[] 65536
                        $remaining = $count
                        while ($remaining -gt 0) {
                            $toRead = [Math]::Min($buffer.Length, $remaining)
                            $read = $fs.Read($buffer, 0, $toRead)
                            if ($read -le 0) { break }
                            try {
                                $res.OutputStream.Write($buffer, 0, $read)
                            } catch {
                                break # Client aborted stream or closed socket
                            }
                            $remaining -= $read
                        }
                    } finally {
                        $fs.Close()
                    }
                }
            } else {
                $res.StatusCode = 200
                $res.ContentLength64 = $fileLength

                if ($req.HttpMethod -ne "HEAD") {
                    $fs = [System.IO.File]::OpenRead($localPath)
                    try {
                        $buffer = New-Object byte[] 65536
                        $read = 0
                        while (($read = $fs.Read($buffer, 0, $buffer.Length)) -gt 0) {
                            try {
                                $res.OutputStream.Write($buffer, 0, $read)
                            } catch {
                                break # Client aborted download
                            }
                        }
                    } finally {
                        $fs.Close()
                    }
                }
            }
        } catch {
            # Catch socket disconnects or individual request errors gracefully
        } finally {
            if ($context -and $context.Response) {
                try { $context.Response.Close() } catch {}
            }
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
