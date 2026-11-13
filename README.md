# ⛰️ WebGIS 3D • Parque Estadual da Serra do Tabuleiro

WebGIS 3D interativo do **Parque Estadual da Serra do Tabuleiro (PAEST)** em Santa Catarina, integrando modelo tridimensional de relevo digital (SRTM 30m), ortoimagem multiespectral de satélite (ESA Sentinel-2) e teletransporte interativo para experiência imersiva em **Vídeo 360° VR 4K** no Pico da Bandeira / Cambirela.

---

## 📸 Recursos e Destaques

- **Relevo 3D Realista**: Malha tridimensional georreferenciada gerada a partir do MDE SRTM 30m com exagero geomorfológico vertical de 4.5x.
- **Ortoimagem Sentinel-2 L1C**: Textura de alta resolução da constelação Copernicus da Agência Espacial Europeia (10/03/2020).
- **Ponto Interativo no Pico da Bandeira**:
  - Mastro 3D com bandeira ondulante ao vento e anel holográfico de radar.
  - Fixado no cume da montanha nas coordenadas exatas: **UTM SC 22S: 724.995 E, 6.925.439 N** (Altitude: **~1.043 m**).
  - Card flutuante dinâmico em tela com animação e clique para ação.
- **Teletransporte Cinemático para Vídeo 360°**:
  - Mergulho de câmera suave a partir do cume e efeito de transição espacial.
  - Player 360° equirretangular completo com controles de reprodução, linha do tempo, rotação automática, campo de visão (zoom) e bússola de orientação.
  - Botão de retorno suave para a visualização tridimensional da serra (`← VOLTAR AO WEBGIS 3D`).
- **Ferramentas GIS no Painel**:
  - Alternância de nuvens volumétricas (`Ocultar / Exibir Nuvens`).
  - Modos de iluminação: **Luz do Dia** e **Pôr do Sol**.
  - Visão aérea vertical (Nadir), visão geral e rotação contínua (órbita).
  - Telemetria de coordenadas e altitude em tempo real.
- **Servidor Local Otimizado**:
  - Servidor em PowerShell com suporte a streaming parcial por faixas de bytes (**HTTP Range 206**), permitindo reprodução instantânea do vídeo de 260 MB sem travamentos.
  - Inicializador em 1 clique para Windows (`iniciar_webgis.bat`).
- **100% Offline**:
  - Todas as dependências do Three.js encontram-se salvas na pasta `libs/`.

---

## 🚀 Como Executar

### No Windows:
Basta dar um duplo-clique no arquivo:
```cmd
iniciar_webgis.bat
```
O servidor local iniciará e seu navegador padrão abrirá automaticamente em `http://localhost:8080/index.html`.

### Em qualquer sistema com Python:
```bash
python -m http.server 8080
```
E acesse `http://localhost:8080` no navegador.

---

## 📁 Estrutura do Repositório

```
├── index.html                           # Aplicação WebGIS 3D e Player 360°
├── iniciar_webgis.bat                   # Inicializador rápido para Windows
├── server.ps1                           # Servidor HTTP com suporte a Range 206
├── README.md                            # Documentação do projeto
├── LEIA-ME.txt                          # Guia rápido de utilização
├── libs/                                # Dependências Three.js locais (offline)
├── modelos/
│   └── MAQUETE SERRA DO TABULEIRO.gltf # Modelo 3D da maquete (SRTM + Sentinel-2)
├── Video 360 Pico da Bandeira/
│   ├── SEU_VIDEO_360.mp4               # Vídeo 360° VR 4K do Cambirela / Serra
│   └── Vídeo.html                      # Player 360° original
└── ...                                  # Arquivos SIG de suporte (Shapefiles, GeoTIFF)
```

---

## 🛠️ Tecnologias Utilizadas

- **Three.js (r160)** - Renderização WebGL 3D e controle de câmera esférica.
- **QGIS & QGIS2threejs** - Processamento SIG, recorte de relevo e exportação da maquete.
- **ESA Sentinel-2** - Ortoimagem multiespectral da superfície.
- **SRTM (Shuttle Radar Topography Mission)** - Modelo Digital de Elevação.
- **Git LFS** - Versionamento de grandes arquivos de mídia.

---

Desenvolvido para o **Parque Estadual da Serra do Tabuleiro**, Santa Catarina, Brasil.
