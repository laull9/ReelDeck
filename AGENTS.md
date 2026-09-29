# AGENTS.md

## 技术栈

- 跨平台框架: Flutter 3.47.5 (Dart 3.13.4)
- 视频解码播放: media_kit / media_kit_video / libmpv
- 本地数据库: Drift / SQLite (sqlite3_flutter_libs)
- 状态管理: Provider
- 文件与目录选择: file_picker
- 目标平台: macOS, Windows, Android

## 注意事项

- 单文件不超过500行，超出时拆分
- 注意测试完备
- 不过度设计，保持简洁高效