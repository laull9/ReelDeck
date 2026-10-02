# ReelDeck

> Pick a folder. Shuffle. Swipe.

ReelDeck 是一个面向本地视频的轻量跨平台随机播放器。

它不做复杂媒体库，不依赖服务器，也不要求用户重新整理文件。用户选择一个本地目录或外置硬盘目录后，ReelDeck 递归发现其中的视频，并以类似 TikTok / Reels 的单视频 Feed 形式随机播放。

目标平台：

- macOS
- Windows
- Android

推荐技术栈：

- Flutter
- media_kit / libmpv
- SQLite / Drift
- 少量平台原生桥接

---

# 1. 产品目标

ReelDeck 只解决一件事：

```text
选择文件夹
→ 递归扫描
→ 随机生成队列
→ Swipe / 快捷键切换视频
```

核心要求：

- 完全本地
- 快速启动
- 真随机
- 单轮不重复
- 喜欢
- 隐藏视频
- 隐藏整个子目录
- 外置硬盘可靠
- TikTok 式上下切换
- 桌面快捷键
- 简洁现代 UI
- 不建立复杂媒体库

---

# 2. 产品原则

## Local First

默认：

```text
No Account
No Cloud
No Server
No Upload
No Analytics
```

视频始终从原始文件位置直接播放。

ReelDeck 不复制、不移动、不修改媒体文件。

---

## Folder First

文件夹就是组织结构。

例如：

```text
Videos/
├── Anime/
├── Camera/
├── Memes/
│   ├── Cats/
│   └── Games/
└── Downloads/
```

ReelDeck 不引入：

```text
Genre
Actor
Album
Series
Metadata Scraper
TMDB
```

---

## Feed First

打开 ReelDeck 的主要界面就是播放器，而不是媒体库。

```text
┌────────────────────────────┐
│                            │
│                            │
│           VIDEO            │
│                            │
│                            │
│                       ♥    │
│                       ⋯    │
│                            │
│ folder/video.mp4           │
│ ━━━━━━━━━━━━━━━━━━━━━━━━   │
└────────────────────────────┘
```

---

# 3. 核心模型

## Source

一个 Source 表示一个用户授权的视频根目录。

```text
Source {
    id
    name

    locator
    lastKnownPath

    platform
    volumeIdentity

    enabled
    recursive

    lastScanAt
}
```

例如：

```text
macOS:
~/Videos

macOS External:
 /Volumes/SSD/Videos

Windows:
E:\Videos

Android:
content://...
```

应用内部禁止直接依赖绝对路径。

---

## Media

```text
Media {
    id

    sourceId
    relativePath

    fileName
    extension

    size
    modifiedAt
}
```

媒体身份由：

```text
sourceId + normalizedRelativePath
```

决定。

实际完整路径由 Source Resolver 动态解析。

---

## MediaState

```text
MediaState {
    mediaId

    favorite
    hidden

    lastPosition
    playCount
    lastPlayedAt
}
```

---

## HiddenRule

用于隐藏整个文件夹：

```text
HiddenRule {
    id

    sourceId
    relativePath

    recursive
}
```

例如：

```text
Source:
SSD

Path:
Memes/Bad

Recursive:
true
```

那么：

```text
Memes/Bad/a.mp4
Memes/Bad/b.mp4
Memes/Bad/sub/c.mp4
```

全部被过滤。

新增文件同样自动隐藏。

---

# 4. 文件扫描

默认：

```text
recursive = true
```

扫描只做低成本操作：

```text
目录遍历
+
扩展名过滤
+
size
+
mtime
```

初始扫描不进行：

```text
ffprobe
完整 hash
缩略图生成
codec 分析
```

这些信息在真正播放文件时按需加载。

支持扩展名：

```text
.mp4
.mkv
.mov
.m4v
.webm
.avi
.mpg
.mpeg
.ts
.m2ts
.flv
.wmv
```

实际能否播放由 libmpv 判断。

---

# 5. 随机系统

ReelDeck 的随机模式不是：

```text
random.nextInt(N)
```

而是：

```text
Eligible Media
      ↓
Random Seed
      ↓
Fisher-Yates Shuffle
      ↓
Queue
```

---

## 单轮无重复

例如：

```text
A B C D E
```

某轮：

```text
D A E B C
```

这一轮结束前不会再次出现：

```text
D
A
E
B
C
```

---

## 每轮不同

播放完成后：

```text
Round N finished
      ↓
new secure random seed
      ↓
reshuffle
      ↓
Round N+1
```

随机种子使用系统安全随机源，而不是仅使用当前时间。

---

## 跨轮防重复

避免：

```text
Round 1 last = C
Round 2 first = C
```

如果发生：

```text
newQueue.first == previousQueue.last
```

交换第一项和随机其他项。

---

## 队列结构

Queue 只保存：

```text
MediaId[]
```

不保存播放器实例和完整媒体对象。

如果文件失效：

```text
resolve MediaId
→ missing
→ skip
```

---

# 6. Feed Scope

随机 Feed 可以作用于不同范围：

```text
All
Favorites
Specific Source
```

以后可以扩展：

```text
Specific Folder
```

但不需要单独建立复杂的播放列表系统。

---

# 7. 喜欢

当前视频可以：

```text
Favorite
Unfavorite
```

Favorite 只修改本地状态。

默认快捷键：

```text
F
```

移动端：

```text
Double Tap
```

可在设置中关闭双击喜欢。

---

# 8. 隐藏

## 隐藏当前视频

```text
H
```

隐藏后：

```text
hidden = true
```

立即移出当前 Feed。

---

## 隐藏当前文件夹

```text
Shift + H
```

或者：

```text
⋯
→ Hide Folder
```

应用生成 HiddenRule，而不是逐个修改目录内所有 Media。

这是必须遵守的实现原则。

---

# 9. 外置硬盘

外部存储是 ReelDeck 的核心场景。

禁止将：

```text
/Volumes/SSD/Videos/a.mp4
```

或者：

```text
E:\Videos\a.mp4
```

作为长期媒体身份。

统一使用：

```text
Source
+
RelativePath
```

---

# 10. macOS 存储

使用：

```text
Security Scoped Bookmark
```

持久化用户目录权限。

流程：

```text
Select Folder
      ↓
create bookmark
      ↓
store bookmark
```

启动：

```text
bookmark
      ↓
resolve
      ↓
startAccessingSecurityScopedResource()
```

如果 Bookmark stale：

```text
resolve
→ regenerate
```

外置卷名变化不应直接导致用户所有状态丢失。

---

# 11. Windows 存储

不能只保存：

```text
E:
```

应尽量保存：

```text
Volume GUID
Volume Serial
Volume Label
Last Known Drive Letter
```

例如：

```text
E:
↓
重新插入
↓
F:
```

只要识别到同一 Volume，SourceId 不变。

因此：

```text
Favorite
Hidden
Queue
```

全部仍然有效。

---

# 12. Android 存储

Android 使用：

```text
Storage Access Framework
```

用户选择：

```text
ACTION_OPEN_DOCUMENT_TREE
```

然后：

```text
takePersistableUriPermission()
```

持久化：

```text
Tree URI
```

而不是依赖传统：

```text
/storage/emulated/0/...
```

路径。

---

# 13. Source Resolver

所有平台路径逻辑统一隐藏在：

```text
SourceResolver
```

接口：

```text
resolveSource()

checkAvailability()

scanSource()

resolveMedia()

openMedia()
```

UI 和播放器禁止直接处理：

```text
/Volumes
E:\
content://
```

---

# 14. 外置盘断开

如果硬盘在播放过程中拔出：

```text
Playback Error
      ↓
Source unavailable
      ↓
Pause
```

界面显示：

```text
External drive disconnected

SSD Videos

[ Retry ]
[ Change Source ]
```

重新插入后：

```text
resolve source
→ resume
```

应用不能崩溃。

---

# 15. 外置 HDD 优化

外置机械硬盘默认启用：

```text
External Drive Optimization
```

策略：

```text
Preload = 1 next video

No automatic thumbnails

No background codec probing

No full hashing
```

避免：

```text
Current
+
Previous
+
Next
+
Thumbnail worker
+
Metadata worker
```

同时随机访问机械盘。

---

# 16. 播放器架构

使用：

```text
media_kit
+
libmpv
```

负责：

```text
Decode
Hardware Acceleration
Seek
Audio
Video Output
Codec Support
```

ReelDeck 不自行开发解码器。

---

# 17. Player Pool

播放器实例数量必须固定。

推荐：

```text
Previous
Current
Next
```

最大三个。

实际上默认只需：

```text
Current
Next
```

Previous 可以在用户反向滑动时重新打开。

---

## 切换流程

当前：

```text
A playing
B preloaded
```

Swipe：

```text
A release / previous
B playing
C preload
```

这样内存不会随媒体数量增长。

---

# 18. 预加载

默认：

```text
Preload next = ON
```

只预加载下一条。

不要预读取完整视频。

只让播放器完成：

```text
open
prepare
buffer small amount
```

---

# 19. Feed 交互

移动端：

```text
Drag Up
→ Next video below

Drag Down
→ Previous video above, or rebound at the beginning

Tap
→ Play / Pause

Double Tap
→ Favorite

Long Press
→ 2x speed

Horizontal Drag
→ Seek
```

---

# 20. 桌面交互

触控板：

```text
Drag Up
→ Next video below

Drag Down
→ Previous video above, or rebound at the beginning
```

滚轮和触控板事件需要：

```text
threshold
cooldown
gesture lock
```

避免一次滑动触发多个视频。

---

# 21. 桌面快捷键

默认：

```text
↓ / J
Next

↑ / K
Previous

Space
Play / Pause

←
Seek -5s

→
Seek +5s

Shift + ←
Seek -15s

Shift + →
Seek +15s

F
Favorite

H
Hide Video

Shift + H
Hide Folder

R
Reshuffle

M
Mute

Enter
Fullscreen

Esc
Exit Fullscreen

I
Toggle Info
```

快捷键未来可以自定义。

---

# 22. 视频显示模式

提供：

```text
Fit
Fill
Original
```

默认：

```text
Fit
```

横屏视频不强制裁成竖屏。

ReelDeck 模仿的是 TikTok 的：

```text
interaction model
```

而不是：

```text
9:16 content format
```

---

# 23. UI

UI 原则：

```text
Content First
Minimal
Dark First
Low Visual Weight
```

主界面只有：

```text
Video
Progress
Filename
Folder
Favorite
More
```

其余控制在鼠标移动或触摸时出现。

---

## 桌面布局

```text
┌────────────────────────────────┐
│ ReelDeck                    ⚙  │
│                                │
│                                │
│             VIDEO              │
│                                │
│                                │
│                          ♥     │
│                          ⋯     │
│                                │
│ folder/video.mp4               │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
└────────────────────────────────┘
```

---

# 24. Minimal Mode

可以隐藏：

```text
Filename
Folder
Buttons
```

只保留：

```text
Video
Progress
```

甚至：

```text
No Overlay
```

---

# 25. 设置

保持极少。

## Playback

```text
Autoplay
Loop Queue
Video Fit
Remember Position
Default Volume
```

## Random

```text
Pure Shuffle
Reshuffle After Round
```

## Storage

```text
Recursive Scan
External Drive Optimization
```

## Interface

```text
Show Filename
Show Folder
Animations
Keyboard Shortcuts
```

---

# 26. 数据库

使用：

```text
SQLite
```

只存状态和索引。

不做复杂媒体数据库。

核心表：

```text
sources
media
media_state
hidden_rules
sessions
```

---

# 27. Session

保存：

```text
PlaybackSession {
    id

    scope
    queue
    currentIndex

    previousMediaId
    createdAt
}
```

这样应用重新打开时可以恢复：

```text
当前视频
当前轮次
当前 Queue
```

无需重新洗牌。

---

# 28. Eligibility

Media 是否进入 Feed：

```text
eligible(media) =

source.enabled
AND
media exists
AND
NOT media.hidden
AND
NOT hiddenFolderMatches(media)
```

Favorites：

```text
eligible(media)
AND
favorite
```

---

# 29. 扫描更新

V1 不需要复杂文件监听器。

刷新时直接：

```text
enumerate directory
      ↓
compare relativePath
      ↓
new / existing / missing
```

对于数万视频仍然足够简单可靠。

后期再增加：

```text
filesystem watcher
```

---

# 30. 文件变化

## 文件删除

```text
Missing
→ mark unavailable
→ skip
```

## 文件重命名

V1：

```text
Old removed
New discovered
```

未来可以通过：

```text
size
mtime
partial fingerprint
```

识别重命名。

---

# 31. Fingerprint

不要默认计算完整 SHA-256。

如果未来需要弱指纹：

```text
size
+
mtime
+
first 64 KiB
+
last 64 KiB
```

足够用于辅助识别。

---

# 32. 删除文件

ReelDeck 首选：

```text
Hide
```

不是 Delete。

文件操作菜单：

```text
Favorite

Hide Video

Hide Folder

Show in Finder / Explorer

Move to Trash
```

Move to Trash 必须确认。

不提供默认永久删除。

---

# 33. 性能目标

已有 Source 再次启动：

```text
< 1 s
```

已预加载视频切换：

```text
接近即时
```

媒体数量：

```text
100
1,000
10,000
100,000
```

不应该影响 Player 内存数量。

---

# 34. 错误策略

ReelDeck 不因为单个视频错误打断 Feed。

```text
Corrupt file
→ skip

Unsupported codec
→ skip

Missing file
→ skip

External drive removed
→ pause source

Decode error
→ skip
```

错误记录可以在：

```text
⋯
→ Playback Error
```

查看。

避免阻塞 Modal。

---

# 35. 应用结构

```text
lib/
├── app/
│
├── feed/
│   ├── feed_screen.dart
│   ├── feed_controller.dart
│   └── gestures.dart
│
├── player/
│   ├── player_manager.dart
│   └── preload_manager.dart
│
├── queue/
│   ├── queue_engine.dart
│   ├── shuffle.dart
│   └── filters.dart
│
├── sources/
│   ├── source.dart
│   ├── scanner.dart
│   ├── source_resolver.dart
│   └── platform/
│
├── state/
│   ├── favorites.dart
│   └── hidden.dart
│
├── database/
│
└── settings/
```

---

# 36. 整体架构

```text
                 Flutter UI
                     │
               Feed Controller
                     │
          ┌──────────┴─────────┐
          │                    │
       Queue Engine       Player Manager
          │                    │
   ┌──────┴──────┐         media_kit
   │             │              │
Shuffle       Filters          mpv
                 │
          ┌──────┴──────┐
          │             │
       SQLite       SourceResolver
                         │
              ┌──────────┼──────────┐
              │          │          │
            macOS     Windows    Android
```

---

# 37. MVP

第一版只实现：

```text
Select Folder

Recursive Scan

Pure Shuffle

Single-round No Repeat

Vertical Feed

Swipe Next / Previous

Keyboard Controls

Play / Pause

Seek

Fit / Fill

Favorite

Hide Video

Hide Folder

External Drive Persistence

Queue Restore

Basic Settings
```

完成这些之后就已经是一款完整可用的 ReelDeck。

---

# 38. V1.1

再增加：

```text
Favorites Feed

Multiple Sources

Show in Finder / Explorer

Move to Trash

Resume Position

Manual Rescan

Minimal Mode
```

---

# 39. V1.2

可以考虑：

```text
Folder Scope

Newest

Oldest

Smart Shuffle

Images

GIF
```

其中：

```text
Pure Shuffle
```

始终是默认随机模式。

---

# 40. Smart Shuffle

未来可选模式。

目标：

避免同一个目录的视频连续大量出现。

例如原始随机：

```text
Cats
Cats
Cats
Anime
Cats
```

Smart Shuffle 可以变成：

```text
Cats
Anime
Games
Cats
Camera
```

但这不再属于严格均匀随机。

因此：

```text
Pure Shuffle
```

和：

```text
Smart Shuffle
```

必须明确区分。

---

# 41. 页面结构

整个应用尽量只保留：

```text
Feed

Sources

Settings
```

Feed Scope：

```text
All
Favorites
Source
```

不要发展成复杂导航体系。

---

# 42. 非目标

ReelDeck 明确不做：

```text
Plex replacement

Jellyfin replacement

Media Server

DLNA

Cloud Sync

Account

Social Feed

Comments

TMDB

Metadata Scraper

Actor / Genre Database

Subtitle Download

Video Editor

Full File Manager
```

---

# 43. 产品判断标准

任何新功能加入前只问一个问题：

> 它是否明显改善“选一个文件夹，然后开始刷视频”？

如果不是，就不应该加入核心产品。

---

# 44. 最终定义

ReelDeck 是一个完全本地的跨平台随机视频 Feed 播放器。

用户选择本地文件夹或外置硬盘后，ReelDeck 递归发现视频，并以每轮不同、单轮不重复的随机顺序进行播放。

用户可以通过：

```text
Swipe
Trackpad
Keyboard
```

快速切换视频。

同时可以：

```text
Favorite

Hide Video

Hide Folder
```

ReelDeck 针对 macOS、Windows 和 Android 分别处理持久化目录授权及外置存储路径变化，因此移动硬盘盘符或挂载位置变化时，已有喜欢、隐藏和播放状态仍能尽可能保持稳定。

ReelDeck 不试图成为另一个媒体管理器。

它只是：

**Pick a folder. Shuffle. Swipe.**