@echo off
title WebGIS 3D - Serra do Tabuleiro
echo ========================================================
echo   Iniciando WebGIS 3D - Parque Estadual Serra do Tabuleiro
echo ========================================================
echo Iniciando servidor local otimizado e abrindo navegador...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
