# 构建与发布

工作流固定 Flutter 3.47.5。PR 运行分析、Flutter 测试、图标一致性和打包脚本测试；推送 main、版本标签或手动触发时构建全部平台。手动构建默认只上传 artifacts。

## 构建矩阵

| 目标 | Runner | 输出 |
| --- | --- | --- |
| Windows x64 | windows-2022 | zip |
| Windows ARM64 | windows-11-arm，原生 ARM64 SDK | zip |
| Linux x64 | ubuntu-24.04 | deb、rpm |
| Linux ARM64 | ubuntu-24.04-arm | deb、rpm |
| macOS x64 | macos-15-intel | zip |
| macOS ARM64 | macos-15 | zip |
| Android ARMv7、ARM64 | ubuntu-24.04、Java 17 | 两份 APK |

GitHub 的 [runner 列表](https://github.com/actions/runner-images) 与 Flutter 的 [平台支持表](https://docs.flutter.dev/reference/supported-platforms) 记录平台变化。这里的架构指产物，不单由 runner 名称决定。

## 本地命令

```sh
# macOS：构建后按架构拆分，同时检查全部 Mach-O 与签名
flutter build macos --release
python3 scripts/package_macos.py --app build/macos/Build/Products/Release/ReelDeck.app --arch arm64

# Android：两份独立 APK
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
python3 scripts/package_android.py

# Linux：原生架构的主机上构建
flutter build linux --release --target-platform linux-arm64
python3 scripts/verify_arch.py build/linux/arm64/release/bundle arm64
python3 scripts/package_linux.py --bundle build/linux/arm64/release/bundle --arch arm64 --version 0.3.0
```

Windows 运行 `flutter build windows --release`，目标由 Dart SDK 架构决定。ARM64 使用原生 Windows ARM64、ARM64 Dart SDK 和 MSVC ARM64 编译工具，在同一 PowerShell 中先运行 `scripts/prepare_windows_arm64.ps1`，再构建。工作流在编译前验证 Dart SDK 架构。本地 Windows 播放库按目标下载 libmpv；ARM64 ANGLE 从固定 vcpkg 提交编译。详细约定见 [依赖说明](../vendor/media_kit_libs_windows_video/README.md)。

## Android 签名

仓库 secrets 使用以下名称：

| 名称 | 内容 |
| --- | --- |
| ANDROID_KEYSTORE_BASE64 | keystore 的 Base64 内容 |
| ANDROID_STORE_PASSWORD | keystore 密码 |
| ANDROID_KEY_PASSWORD | 密钥密码 |
| ANDROID_KEY_ALIAS | 密钥别名 |

四项必须一起配置。脚本不输出密钥和密码，生成的 `android/key.properties` 与 keystore 已加入忽略规则。没有 secrets 时生成测试签名 APK，名称带 `-test-signed`。发布正式版本前配置稳定密钥，以便后续覆盖安装。

开发机遇到损坏的 NDK 安装时，可临时选择已有完整版本：

```sh
ORG_GRADLE_PROJECT_reeldeckNdkVersion=27.1.12297006 flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

覆盖同时应用于应用和 JNI 插件。CI 没有设置这项，采用 Flutter 的默认 NDK。

## Release 约束

版本标签必须采用 `v` 加 pubspec 版本，如 `v0.3.0`。手动发布必须给出已存在、且指向本次提交的标签；工作流不自动创建标签，也不使用写死的默认版本。

四组构建任务全部成功后才汇总 10 个文件，生成 `SHA256SUMS` 并上传。Windows 检查整个目录中的 PE 架构和必需 DLL；Linux 检查 ELF 架构、动态链接、deb 安装和启动；macOS 拆分并检查全部 Mach-O 后重新本地签名；Android 检查 APK 的唯一 ABI 与 Flutter、Dart AOT、libmpv 库。

macOS 的本地签名用于保持包内签名一致，未包含 Developer ID 与公证。CI 中的 Linux 启动检查使用 Xvfb，只覆盖安装和启动，不代替硬件解码与外置卷测试。设备验收记录见 [TODO](../TODO.md)。

## 版本记录

[v0.5.0](versions/v0.5.0.md) 修复坏视频黑屏卡死，增加目录自动刷新与窄屏换行排版，播放控制按钮居中。

[v0.4.1](versions/v0.4.1.md) 修复进度恢复时的加载超时，并提前准备下一条视频与下一轮首项。
