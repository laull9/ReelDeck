<div align="center">
  <img src="assets/icon/app_icon.png" width="144" alt="ReelDeck 图标" />
  <h1>ReelDeck</h1>
  <p>选一个本地目录，开始随机刷视频。</p>
  <p>
    <a href="README.md">English</a> · 
    <a href="README_zh.md">简体中文</a> · 
    <a href="README_ja.md">日本語</a> · 
    <a href="README_es.md">Español</a> · 
    <a href="README_fr.md">Français</a>
  </p>
  <p>
    <a href="https://github.com/laull9/ReelDeck/actions/workflows/release.yml"><img src="https://github.com/laull9/ReelDeck/actions/workflows/release.yml/badge.svg" alt="构建状态" /></a>
    <img src="https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter" alt="Flutter 3.47.5" />
    <img src="https://img.shields.io/badge/存储-完全本地-23DFA1" alt="完全本地" />
  </p>
  <p><a href="https://github.com/laull9/ReelDeck/releases">下载</a> · <a href="DESIGN.md">产品设计</a> · <a href="docs/releases.md">构建与发布</a> · <a href="TODO.md">设备验收</a></p>
</div>

ReelDeck 直接播放原文件。支持本机目录、移动硬盘和 Android 授权目录，递归建立轻量索引，再按一轮不重复的顺序播放。没有账号、云同步、上传或使用统计。

## 功能

- **随机播放**：默认用系统安全随机源生成 Fisher–Yates 队列；单轮不重复，重新洗牌时避免上一轮末条立即重现。
- **平滑预加载**：采用前后双向三播放器环形池，提前加载前一个和后一个视频，滑动切换零黑屏、无旧画面闪烁。
- **解码优化**：集成高效硬件解码配置（支持 Auto、Auto-Safe 及纯软解），优化 Seek 首帧响应与探测解析耗时。
- **播放范围**：全部、收藏、单个来源、子目录。隐藏视频或整个目录后，新增文件也遵守隐藏规则。
- **播放顺序**：纯随机、智能随机、最新优先、最旧优先。智能随机尽量交错父目录；时间排序采用文件修改时间。
- **视频控制**：播放、暂停、拖动进度、临时倍速、静音、全屏，以及完整显示、填满画面、原始尺寸三种显示方式。
- **继续播放**：保存当前队列、播放位置、收藏和隐藏记录。关闭再打开，接着当前一轮播放。
- **图片与 GIF**：在设置中开启，按停留时间播放，也能暂停或拖动计时进度。默认只播放视频。
- **目录维护**：多个来源、手动重扫、每个来源独立选择递归扫描。目录断开时暂停，重连后可重试；单个坏文件自动跳过。
- **文件操作**：桌面端在文件管理器中定位、确认后移入系统回收站。Android SAF 没有统一回收站，请使用隐藏或文档提供方的文件管理器。
- **精简显示**：完整信息、仅进度、无浮层。移动鼠标或轻触唤出控制；支持关闭动画、双击收藏和键盘控制，快捷键可自定义。
- **多语言支持**：跟随系统语言自动匹配，也支持在设置中手动切换（支持英语、简体中文、日语、西班牙语、法语）。

视频格式包括 MP4、MKV、MOV、M4V、WebM、AVI、MPG、MPEG、TS、M2TS、FLV、WMV；实际解码能力由 libmpv 决定。图片支持 JPG、JPEG、PNG、WebP、BMP、GIF，单张读取上限 64 MiB。

桌面端采用 3 播放器双向预载缓冲；Android 单播放器模式平滑过渡。扫描只读取路径、文件大小和修改时间，不生成缩略图，不进行后台编码探测或完整哈希。

## 下载与安装

从 [Releases](https://github.com/laull9/ReelDeck/releases) 选择设备架构。表中的文件名对应当前工作流；旧版本的资产名称会有所不同。

| 平台 | x64 | ARM64 |
| --- | --- | --- |
| Windows | `ReelDeck-windows-x64.zip` | `ReelDeck-windows-arm64.zip` |
| macOS | `ReelDeck-macos-x64.zip` | `ReelDeck-macos-arm64.zip` |
| Linux deb | `ReelDeck-linux-x64.deb` | `ReelDeck-linux-arm64.deb` |
| Linux rpm | `ReelDeck-linux-x64.rpm` | `ReelDeck-linux-arm64.rpm` |
| Android | ARMv7：`ReelDeck-android-armv7.apk` | `ReelDeck-android-arm64.apk` |

Windows 安装对应架构的 [Microsoft Visual C++ v14 运行库](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist)，解压整个目录后运行 `reel_deck.exe`，保留同目录的 DLL 与 `data`。macOS 解压后将 `ReelDeck.app` 拖入应用程序目录；CI 使用本地签名，尚未做 Apple 公证。

Linux 包在 Ubuntu 24.04 编译。deb 面向 Ubuntu 24.04 / Debian 13，rpm 面向具有相应 GTK3、libmpv 和 glibc 依赖的发行版；具体安装兼容性见 [设备验收记录](TODO.md)。

```sh
# Debian / Ubuntu
sudo apt install ./ReelDeck-linux-arm64.deb

# Fedora 等 RPM 发行版
sudo dnf install ./ReelDeck-linux-arm64.rpm
```

Android 需要 Android 7.0（API 24）或更新系统。老 ARM 设备选择 ARMv7 包，它不表示支持 Android 6 或更早系统。没有配置正式签名的构建在文件名加入 `-test-signed`；测试密钥不保证跨次构建一致。

v0.3.0 开始使用固定 Android 发布密钥。此前安装过测试签名包的设备，需要先卸载旧包再安装；卸载会清除应用内的目录授权、队列和收藏记录，原始媒体文件不受影响。

## 使用

打开应用，添加一个媒体目录。Android 会打开系统目录授权选择器；桌面端可选择本机或外置盘目录。扫描结束即可播放。

下滑下一条，上滑上一条；点击播放或暂停，双击收藏，长按临时 2 倍速，水平拖动快进或后退。进度条支持连续拖动。顶部范围选择器可切换收藏、来源和子目录，“更多”菜单提供隐藏与文件操作。

| 默认快捷键 | 操作 |
| --- | --- |
| `↓` / `J` | 下一条 |
| `↑` / `K` | 上一条 |
| `Space` | 播放 / 暂停 |
| `←` / `→` | 后退 / 快进 5 秒 |
| `Shift + ←` / `Shift + →` | 后退 / 快进 15 秒 |
| `F` | 收藏 / 取消收藏 |
| `H` / `Shift + H` | 隐藏视频 / 隐藏所在目录 |
| `R` | 重新排列队列 |
| `M` | 静音 |
| `Enter` / `Esc` | 进入 / 退出全屏 |
| `I` | 切换信息显示 |

在设置中自定义快捷键。暂停或进入设置页时保存进度；播放错误保留最近 100 条，可在设置或“更多”菜单中查看和清空。

## 本地开发

使用 Flutter 3.47.5 / Dart 3.13.4。项目采用 media_kit / libmpv、Drift / SQLite、Provider，以及各平台原生存储桥接。构建桌面应用需要对应系统的工具链。

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run -d macos
```

Linux 开发机需要 `clang`、`cmake`、`ninja-build`、`pkg-config`、`libgtk-3-dev`、`libmpv-dev`、`libepoxy-dev` 和 `liblzma-dev`。Windows ARM64 的 ANGLE 准备步骤、Android 签名配置和所有打包命令见 [构建与发布](docs/releases.md)。

数据库定义变更后生成 Drift 代码：

```sh
dart run build_runner build --delete-conflicting-outputs
```

应用只保存目录授权、媒体索引、收藏、隐藏规则、会话、设置与错误日志。媒体身份使用来源 ID 和相对路径。macOS 通过安全作用域书签保留授权；Windows 使用卷 GUID，Linux 使用可获得的卷 UUID，Android 使用 SAF 树 URI。

## 项目文档

| 文档 | 内容 |
| --- | --- |
| [DESIGN](DESIGN.md) | 产品边界、交互与数据模型 |
| [实施约定](docs/implementation.md) | 第二、第三版功能与验收约束 |
| [播放维护](docs/playback.md) | 播放器、预加载、首帧和进度恢复 |
| [构建与发布](docs/releases.md) | CI 矩阵、签名、打包与校验 |
| [图标资源](assets/icon/README.md) | 母图、平台尺寸与重生成 |
| [构建验收](docs/verification.md) | 测试、全矩阵构建与产物校验记录 |
| [TODO](TODO.md) | 尚待设备验证的项目 |

项目图标使用提供的透明 PNG。SVG 文件嵌入同一图像，平台图标由脚本统一生成。第三方 Windows 原生依赖的许可和本地修改说明保存在 [vendor](vendor/media_kit_libs_windows_video/README.md)。
