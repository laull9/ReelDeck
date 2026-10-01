<div align="center">
  <img src="assets/icon/app_icon.png" width="144" alt="ReelDeck Icon" />
  <h1>ReelDeck</h1>
  <p>Pick a folder. Shuffle. Swipe.</p>
  <p>
    <a href="README.md">English</a> · 
    <a href="README_zh.md">简体中文</a> · 
    <a href="README_ja.md">日本語</a> · 
    <a href="README_es.md">Español</a> · 
    <a href="README_fr.md">Français</a>
  </p>
  <p>
    <a href="https://github.com/laull9/ReelDeck/actions/workflows/release.yml"><img src="https://github.com/laull9/ReelDeck/actions/workflows/release.yml/badge.svg" alt="Build Status" /></a>
    <img src="https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter" alt="Flutter 3.47.5" />
    <img src="https://img.shields.io/badge/Storage-Fully%20Local-23DFA1" alt="Fully Local" />
  </p>
  <p><a href="https://github.com/laull9/ReelDeck/releases">Downloads</a> · <a href="DESIGN.md">Product Design</a> · <a href="docs/releases.md">Build & Release</a> · <a href="TODO.md">Device Verification</a></p>
</div>

ReelDeck plays your original files directly. It supports local drives, external disks, and Android Storage Access Framework (SAF) folders, building a lightweight recursive index and playing media in non-repeating rounds. No accounts, no cloud sync, no uploads, and no analytics.

## Features

- **Shuffled Playback**: Cryptographically secure Fisher–Yates shuffle by default; non-repeating per round, preventing the last video from replaying immediately on reshuffle.
- **Smooth Preloading**: 3-player ring buffer preloads adjacent items (previous and next), ensuring seamless transitions without black screens or frame flickering.
- **Optimized Decoding**: Hardware acceleration profiles (`auto`, `auto-safe`, `no`) with streamlined demuxer probing and instant seek-to-zero frame detection.
- **Playback Scope**: All media, favorites, single folder, or subfolder. Hidden videos or entire folders stay excluded even as new files are added.
- **Queue Order**: Random, Smart Random (interleaving directories), Newest First, Oldest First.
- **Video Controls**: Play/pause, scrub progress bar, temporary 2x speed hold, mute, fullscreen, and 3 display modes (Fit, Fill/Cover, Original Size).
- **Resume Where You Left Off**: Restores current queue, position, favorites, and hidden states on app restart.
- **Images & GIFs**: Optional photo and GIF support with customizable display timer, pause, and seekable progress bar.
- **Folder Management**: Multi-source folders, manual rescan, and per-folder recursive options. Gracefully handles unmounted drives and skips broken media files.
- **File Actions**: Reveal in desktop file manager, confirm to move to system trash. (Android SAF uses folder-level hide).
- **Clean UI**: Full info, progress bar only, or no overlay. Touch or mouse movement brings up controls; customizable keyboard shortcuts.
- **Internationalization**: Follows system locale automatically or can be configured in settings (English, Simplified Chinese, Japanese, Spanish, French).

Supported video formats include MP4, MKV, MOV, M4V, WebM, AVI, MPG, MPEG, TS, M2TS, FLV, WMV (backed by libmpv). Supported image formats include JPG, JPEG, PNG, WebP, BMP, GIF (up to 64 MiB each).

Desktop platforms use a 3-player bidirectional preloading pool; Android runs in a smooth single-player mode. Scanning only indexes paths, file sizes, and modification timestamps—no background thumbnailing or hashing.

## Download & Installation

Pick the build matching your architecture from [Releases](https://github.com/laull9/ReelDeck/releases):

| Platform | x64 | ARM64 |
| --- | --- | --- |
| Windows | `ReelDeck-windows-x64.zip` | `ReelDeck-windows-arm64.zip` |
| macOS | `ReelDeck-macos-x64.zip` | `ReelDeck-macos-arm64.zip` |
| Linux deb | `ReelDeck-linux-x64.deb` | `ReelDeck-linux-arm64.deb` |
| Linux rpm | `ReelDeck-linux-x64.rpm` | `ReelDeck-linux-arm64.rpm` |
| Android | ARMv7: `ReelDeck-android-armv7.apk` | `ReelDeck-android-arm64.apk` |

On Windows, install the [Microsoft Visual C++ v14 Redistributable](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist), extract the entire folder, and run `reel_deck.exe`. On macOS, drag `ReelDeck.app` into Applications.

Linux packages are built on Ubuntu 24.04:

```sh
# Debian / Ubuntu
sudo apt install ./ReelDeck-linux-arm64.deb

# Fedora / RHEL
sudo dnf install ./ReelDeck-linux-arm64.rpm
```

Android requires Android 7.0 (API 24) or newer.

## Usage

Launch the app and add a video directory. On Android, select a folder through SAF; on desktop, pick any local or external volume. Playback starts as soon as scanning finishes.

Swipe up for next, swipe down for previous. Tap to toggle play/pause, double tap to favorite, long press for 2x speed, drag horizontally to scrub.

| Default Shortcut | Action |
| --- | --- |
| `↓` / `J` | Next video |
| `↑` / `K` | Previous video |
| `Space` | Play / Pause |
| `←` / `→` | Seek backward / forward 5s |
| `Shift + ←` / `Shift + →` | Seek backward / forward 15s |
| `F` | Toggle favorite |
| `H` / `Shift + H` | Hide video / Hide folder |
| `R` | Reshuffle queue |
| `M` | Toggle mute |
| `Enter` / `Esc` | Enter / Exit fullscreen |
| `I` | Toggle overlay info |

Configure shortcuts in Settings. Position is saved automatically on pause or when opening settings; playback errors keep the last 100 entries.

## Development

Built with Flutter 3.47.5 / Dart 3.13.4, using media_kit / libmpv, Drift / SQLite, Provider, and native platform channels.

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run -d macos
```

Code generation for Drift database tables:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Documentation

| Document | Description |
| --- | --- |
| [DESIGN](DESIGN.md) | Architecture, interactions, and data model |
| [Implementation](docs/implementation.md) | Conventions and acceptance criteria |
| [Playback](docs/playback.md) | Players, preloading, and state restoration |
| [Build & Release](docs/releases.md) | CI matrix, signing, packaging, and checksums |
| [App Icon](assets/icon/README.md) | Source artwork and generation scripts |
| [Verification](docs/verification.md) | Test runs and verification log |
| [TODO](TODO.md) | Device verification tracking |
