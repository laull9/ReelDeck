# 构建验收

2026-10-01，提交 `b5b94a85351f4422b25a1cb3fcb722604627cdcc` 的 [GitHub Actions 全矩阵](https://github.com/laull9/ReelDeck/actions/runs/36854716966) 成功结束。后续提交只更新文档。

| 检查 | 结果 |
| --- | --- |
| Flutter 分析 | 无问题 |
| Flutter 测试 | 64 项通过，含窄屏点击与 20,000 项智能随机 |
| Python 构建脚本测试 | 5 项通过 |
| 图标 | 27 个文件的尺寸与像素一致性通过 |
| Windows x64、ARM64 | 编译、全部 PE 架构、运行文件检查和 ZIP 打包通过 |
| Linux x64、ARM64 | 编译、ELF 与动态链接、deb / rpm 打包、deb 安装和 Xvfb 启动通过 |
| macOS x64、ARM64 | 编译、全部 Mach-O 拆分、重新签名与 ZIP 打包通过 |
| Android ARM64、ARMv7 | APK 构建、唯一 ABI、Flutter / Dart AOT / libmpv 检查通过 |

这一轮生成 10 份安装包或压缩包，下载后核对 GitHub artifact 的 SHA-256，并生成文件校验清单。手动任务关闭 `publish_release`，Release 步骤按预期跳过，本次没有新增或更新版本标签和 Release。

本地也完成 macOS release 与 ARM64 打包，以及两份 Android APK 构建。macOS 包内 26 个 Mach-O 文件通过 ARM64 和签名检查；本地 Android 使用已安装的 NDK 27.1.12297006，CI 使用 Flutter 默认 NDK。

构建和测试覆盖代码行为与包结构。真实磁盘重挂载、系统回收站、硬件解码、Android SAF 重启与 Surface 恢复仍按 [TODO](../TODO.md) 做设备验收。Android 产物使用测试签名，macOS 尚未做 Apple 公证。
