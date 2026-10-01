# Windows 原生播放依赖

基于 media_kit_libs_windows_video 1.0.11 的 Windows 插件，保留上游 MIT 许可。Dart 接口与插件注册名称沿用上游。

上游已发布包固定下载 x64 libmpv 与 ANGLE。本地 CMake 按 Flutter 目标架构选择库：x64 沿用原包；ARM64 使用上游提供的 20241021 aarch64 libmpv，ANGLE 从固定 vcpkg 提交编译。解压在 CMake 配置阶段完成，以免头文件与插件编译发生竞争。

ARM64 构建前运行 `scripts/prepare_windows_arm64.ps1`，同一 shell 中运行 Flutter 构建；CI 会通过 `GITHUB_ENV` 传递依赖位置。打包后检查全部 DLL 的 PE 架构，发现混入 x64 库即失败。

上游来源：[media-kit](https://github.com/media-kit/media-kit/tree/main/libs/windows/media_kit_libs_windows_video)。仅维护架构分支和解包时序；不改解码器。
