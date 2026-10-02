<div align="center">
  <img src="assets/icon/app_icon.png" width="144" alt="Icono de ReelDeck" />
  <h1>ReelDeck</h1>
  <p>Elige una carpeta. Mezcla. Desliza.</p>
  <p>
    <a href="README.md">English</a> · 
    <a href="README_zh.md">简体中文</a> · 
    <a href="README_ja.md">日本語</a> · 
    <a href="README_es.md">Español</a> · 
    <a href="README_fr.md">Français</a>
  </p>
  <p>
    <a href="https://github.com/laull9/ReelDeck/actions/workflows/release.yml"><img src="https://github.com/laull9/ReelDeck/actions/workflows/release.yml/badge.svg" alt="Estado de compilación" /></a>
    <img src="https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter" alt="Flutter 3.47.5" />
    <img src="https://img.shields.io/badge/Almacenamiento-Totalmente%20Local-23DFA1" alt="Totalmente Local" />
  </p>
  <p><a href="https://github.com/laull9/ReelDeck/releases">Descargas</a> · <a href="DESIGN.md">Diseño de producto</a> · <a href="docs/releases.md">Compilación y lanzamiento</a> · <a href="TODO.md">Verificación</a></p>
</div>

ReelDeck reproduce tus archivos originales directamente. Admite carpetas locales, discos externos y carpetas autorizadas de Android (SAF), creando un índice ligero y reproduciendo en rondas sin repeticiones. Sin cuentas, sin sincronización en la nube y sin recopilación de datos.

## Características

- **Reproducción aleatoria**: Mezcla criptográficamente segura Fisher–Yates; sin repetición por ronda y evita repetir inmediatamente el último video.
- **Precarga fluida**: Búfer circular de 3 reproductores (anterior y siguiente) para un cambio inmediato sin pantallas negras ni parpadeos.
- **Decodificación optimizada**: Perfiles de aceleración por hardware (`auto`, `auto-safe`, `no`) y optimización de demuxer para una búsqueda instantánea.
- **Alcance de reproducción**: Todo, favoritos, una sola carpeta o subcarpeta. Los elementos ocultos se mantienen excluidos incluso al agregar nuevos archivos.
- **Orden de cola**: Aleatorio, Inteligente (alternando carpetas), Más recientes primero, Más antiguos primero.
- **Control de video**: Reproducir/pausar, barra de progreso interactiva, velocidad 2x al mantener presionado, silencio, pantalla completa y 3 modos de ajuste de video.
- **Reanudación**: Restaura la cola actual, la posición, favoritos y videos ocultos al reiniciar la aplicación.
- **Imágenes y GIF**: Soporte opcional con temporizador configurable, pausa y barra de avance.
- **Gestión de fuentes**: Múltiples fuentes, reescaneo manual y configuración recursiva por carpeta. Manejo seguro de discos desconectados.
- **Acciones de archivo**: Mostrar en el explorador de archivos y mover a la papelera del sistema en escritorio (en Android se recomienda ocultar).
- **Interfaz limpia**: Modos de información completa, solo barra o sin interfaz. Atajos de teclado totalmente configurables.
- **Internacionalización**: Detección automática del idioma del sistema o selección manual en ajustes (Inglés, Chino simplificado, Japonés, Español, Francés).

Formatos de video soportados: MP4, MKV, MOV, M4V, WebM, AVI, MPG, MPEG, TS, M2TS, FLV, WMV. Imágenes: JPG, JPEG, PNG, WebP, BMP, GIF (hasta 64 MiB por archivo).

## Descarga e instalación

Descarga el paquete correspondiente desde [Releases](https://github.com/laull9/ReelDeck/releases):

| Plataforma | x64 | ARM64 |
| --- | --- | --- |
| Windows | `ReelDeck-windows-x64.zip` | `ReelDeck-windows-arm64.zip` |
| macOS | `ReelDeck-macos-x64.zip` | `ReelDeck-macos-arm64.zip` |
| Linux deb | `ReelDeck-linux-x64.deb` | `ReelDeck-linux-arm64.deb` |
| Linux rpm | `ReelDeck-linux-x64.rpm` | `ReelDeck-linux-arm64.rpm` |
| Android | ARMv7: `ReelDeck-android-armv7.apk` | `ReelDeck-android-arm64.apk` |

En Windows, instale [Microsoft Visual C++ v14 Redistributable](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist), descomprima la carpeta y ejecute `reel_deck.exe`. En macOS, arrastre `ReelDeck.app` a Aplicaciones.

En Linux (Ubuntu 24.04):

```sh
# Debian / Ubuntu
sudo apt install ./ReelDeck-linux-arm64.deb

# Fedora / RPM
sudo dnf install ./ReelDeck-linux-arm64.rpm
```

Android requiere versión 7.0 (API 24) o superior.

## Uso

Abra la aplicación y añada una carpeta multimedia. La reproducción comenzará tan pronto como termine el escaneo.

Deslice hacia abajo para el siguiente video, deslice hacia arriba para el anterior. Toque para reproducir/pausar, doble toque para favoritos, mantenga presionado para 2x de velocidad.

| Atajo predeterminado | Acción |
| --- | --- |
| `↓` / `J` | Siguiente video |
| `↑` / `K` | Video anterior |
| `Espacio` | Reproducir / Pausar |
| `←` / `→` | Retroceder / Avanzar 5s |
| `Shift + ←` / `Shift + →` | Retroceder / Avanzar 15s |
| `F` | Alternar favorito |
| `H` / `Shift + H` | Ocultar video / Ocultar carpeta |
| `R` | Reordenar cola |
| `M` | Silenciar |
| `Enter` / `Esc` | Pantalla completa |
| `I` | Alternar información |

## Desarrollo local

Utiliza Flutter 3.47.5 / Dart 3.13.4, media_kit / libmpv, Drift / SQLite, Provider y canales de plataforma nativos.

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run -d macos
```

Generación de código Drift:

```sh
dart run build_runner build --delete-conflicting-outputs
```
