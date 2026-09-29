# ReelDeck 开发进度

## 已完成 (MVP)
- [x] 项目骨架搭建与 Git 初始化 (Flutter 3.47.5 / macOS, Windows, Android)
- [x] 数据存储层 (Drift SQLite)
  - [x] Sources, Media, MediaStates, HiddenRules, Sessions 表定义
  - [x] SourceDao, MediaDao, StateDao, SessionDao 实现与内存测试
- [x] 播放器服务层 (media_kit)
  - [x] PlayerService 接口与流式监听
  - [x] MediaKitPlayerService 实现
  - [x] 双播放器 PlayerPool（当前/下一个预加载与切换）
  - [x] VideoPlayerWidget 封装
- [x] 目录与视频源扫描 (Sources)
  - [x] 递归遍历与常见视频格式过滤
  - [x] 跨平台路径解析器 (DefaultResolver, MacOSResolver 桩)
  - [x] SourceManager 状态管理与目录选择 (file_picker)
  - [x] 媒体源管理界面 (SourcesScreen)
- [x] 随机队列与过滤 (Queue)
  - [x] Fisher-Yates 真随机打乱算法
  - [x] 单轮无重复与跨轮防重
  - [x] 隐藏项与隐藏目录过滤
- [x] 播放 Feed 界面 (Feed UI)
  - [x] 垂直滑动手势与触控板支持
  - [x] 桌面全键盘快捷键绑定 (J/K, H, F, R, 空格, 方向键等)
  - [x] 浮层信息 (VideoOverlay)、进度条 (ProgressBar)、操作按钮 (ActionButtons)
  - [x] 空状态提示 (EmptyState) 与源断开提示 (SourceUnavailable)
- [x] 全局路由与设置
  - [x] MaterialApp M3 深色主题
  - [x] 设置界面 (SettingsScreen)
  - [x] 全局 MultiProvider 状态注入
- [x] 自动化测试
  - [x] 24 项单元测试与 Widget 测试全部通过
  - [x] 代码静态分析零告警

## 待推进 (V1.1 / 后续优化)
- [ ] macOS Security-Scoped Bookmarks 原生通道接入
- [ ] Windows Volume GUID / 卷标持久化识别
- [ ] 播放历史与断点续播位置恢复
- [ ] 收藏夹独立 Feed 筛选视图
