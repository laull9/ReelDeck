# 构建验收

2026-10-01，提交 `b5b94a85351f4422b25a1cb3fcb722604627cdcc` 的 [GitHub Actions 全矩阵](https://github.com/laull9/ReelDeck/actions/runs/36854716966) 成功结束。这一轮验证在滑动修复之前完成，Android 使用测试签名。

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

## v0.3.0 滑动修复

切换手势改为旧视频离场后打开目标视频，目标画面从零偏移显示。新增逐帧回归测试，模拟画面先切换、后台预加载两秒后才结束，检查整个等待过程和结束后的 15 帧位置。旧实现无法通过该测试，修复后通过；关闭动画和重复切换也覆盖。

本地 Flutter 分析无问题，66 项 Flutter 测试、5 项打包脚本测试、27 个图标文件检查通过。macOS release 构建完成，ARM64 包的 26 个 Mach-O 和签名检查通过。固定 Android 发布密钥已配置，标签构建将重新生成全部平台产物。

## v0.4.0 播放恢复修复

2026-10-02，本机 macOS release 模式复现并修复了长 GOP 视频恢复进度时的加载超时。原实现请求第 7 秒却停在第 0 秒，12 秒后报告画面未就绪。修复后，同一 160 × 90 H.264 样本约 217 ms 完成打开，并正常前进到第 9 秒，实际解码路径为 VideoToolbox。

随后运行 `scripts/playback_smoke.dart`，320 × 180 H.264、4K H.264、4K HEVC 的打开等待分别为 182 ms、1260 ms、561 ms，全部使用 VideoToolbox；各播放观察窗口内 `decoder-frame-drop-count=0`。非关键帧跳转、第 17 秒预加载交接、纯软解、过期进度、完整 Feed 启动、四次连续切换、暂停时更改解码模式均通过。样本为合成纯色视频，数值只记录本次运行，不代表真实视频的性能增幅。

新增与更新的回归测试覆盖共享超时预算、原生属性查询不返回、解码超时结束加载、解码模式更改保留进度，以及预加载与交接、关闭的并发顺序。Flutter 回归检查同时覆盖滑到在途预加载目标时只打开一次。后台软解预加载的交接策略也在 macOS 原生环境通过。Android、Windows、Linux 设备验收与复杂视频性能测量仍待完成。


同轮和跨轮的四次已预加载 Feed 交接分别为 1 ms、0 ms、2 ms、3 ms，全部复用备用播放器，未出现 `busy` 加载状态。下一轮顺序在最后一条播放期间准备，避免循环边界重新打开未预加载文件。最终静态分析无问题，74 项 Flutter 测试、5 项打包脚本测试通过；Android ARM64 / ARMv7 release APK 构建完成。本地 Android 构建使用已安装的 NDK 27.1.12297006。实际滑动动画仍有原有的 180 ms 时长，上述数字只计算动画之后的播放器交接，且要求预加载已经完成。预加载尚未完成时继续接管在途任务，不重复打开目标文件。

正常应用入口的 macOS release 构建完成，Apple Silicon 修复包保存在 `dist/playback-fix/ReelDeck-macos-arm64.zip`。包内 26 个 Mach-O 文件全部通过 ARM64 与签名检查。该文件在更新 v0.4.1 版本号前生成，保留 v0.4.0 的版本信息。v0.4.1 的安装包由标签发布工作流构建；本次按用户要求不监控远程 CI，远程 Release 与产物结果尚未验证。

## v0.4.1 滑动问题的本地修复

2026-10-02，新增回归测试复现了等待播放器交接时旧画面归位的问题，旧实现无法通过。修复统一了拖动和滚轮方向，累积触控板小幅滚动，允许立即反向返回，并保留上一轮顺序。打开期间忽略旧播放器的播放结束事件，避免切换后又跳过目标。

80 项 Flutter 测试通过。macOS release 下运行实际 Feed，并用渲染截图读取红、绿、蓝视频的中心像素。红→绿、绿→红、红→绿、绿→蓝分别读取 19、19、19、11 次，旧颜色离场后没有在采样中再次出现；交接后各追加五次目标颜色检查。跨轮返回恢复了原来的最后一条及其蓝色画面。自动播放开启，样本含 4K H.264 和 4K HEVC。这些结果覆盖本次运行与采样，不能代替其他设备和视频文件的验收。

本次修复按用户要求覆盖发布 v0.4.1，发布构建号增至 6。按此前要求不监控远程 CI；Android、Windows、Linux 的实际滑动与画面验收仍列在 TODO。

正常应用入口的 macOS release 构建完成，Apple Silicon 修复包位于 `dist/swipe-fix/ReelDeck-macos-arm64.zip`，版本信息为 0.4.1+5。包内 26 个 Mach-O 文件通过 ARM64 与签名检查。Android ARM64 和 ARMv7 release APK 也构建通过，本地使用 NDK 27.1.12297006；尚未进行 Android 实际画面验收。
