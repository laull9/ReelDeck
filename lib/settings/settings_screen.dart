import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../feed/feed_controller.dart';
import '../feed/widgets/playback_errors.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSectionHeader('播放'),
          SwitchListTile(
            title: const Text('切换后自动播放'),
            value: settings.autoplay,
            onChanged: (val) => settings.update(autoplay: val),
          ),
          SwitchListTile(
            title: const Text('循环播放队列'),
            value: settings.loopQueue,
            onChanged: (val) => settings.update(loopQueue: val),
          ),
          ListTile(
            title: const Text('画面适配'),
            trailing: DropdownButton<String>(
              value: settings.videoFit,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'fit', child: Text('完整显示')),
                DropdownMenuItem(value: 'fill', child: Text('填满画面')),
                DropdownMenuItem(value: 'original', child: Text('原始尺寸')),
              ],
              onChanged: (val) {
                if (val != null) settings.update(videoFit: val);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('记住播放位置'),
            value: settings.rememberPosition,
            onChanged: (val) => settings.update(rememberPosition: val),
          ),
          ListTile(
            title: const Text('默认音量'),
            subtitle: Slider(
              value: settings.defaultVolume,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => settings.update(defaultVolume: val),
            ),
            trailing: Text('${(settings.defaultVolume * 100).round()}%'),
          ),

          _buildSectionHeader('队列'),
          ListTile(
            title: const Text('播放顺序'),
            subtitle: const Text('智能随机尽量交错目录；时间顺序按文件修改时间'),
            trailing: DropdownButton<String>(
              value: settings.queueOrder,
              items: const [
                DropdownMenuItem(value: 'shuffle', child: Text('纯随机')),
                DropdownMenuItem(value: 'smart', child: Text('智能随机')),
                DropdownMenuItem(value: 'newest', child: Text('最新优先')),
                DropdownMenuItem(value: 'oldest', child: Text('最旧优先')),
              ],
              onChanged: (value) => settings.update(queueOrder: value),
            ),
          ),
          SwitchListTile(
            title: const Text('每轮结束重新随机'),
            subtitle: const Text('关闭后重复当前顺序，时间排序始终保持顺序'),
            value: settings.reshuffleAfterRound,
            onChanged: (value) => settings.update(reshuffleAfterRound: value),
          ),
          SwitchListTile(
            title: const Text('播放图片与 GIF'),
            subtitle: const Text('支持 JPG、PNG、WebP、BMP、GIF；刷新目录后加入索引'),
            value: settings.includeImages,
            onChanged: (value) => settings.update(includeImages: value),
          ),
          ListTile(
            title: const Text('图片停留时间'),
            subtitle: Slider(
              value: settings.imageSeconds.toDouble().clamp(1, 60),
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (value) =>
                  settings.update(imageSeconds: value.round()),
            ),
            trailing: Text('${settings.imageSeconds} 秒'),
          ),
          _buildSectionHeader('目录'),
          ListTile(
            title: const Text('管理视频目录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.sources),
          ),
          SwitchListTile(
            title: const Text('新目录默认扫描子目录'),
            value: settings.recursiveScan,
            onChanged: (val) => settings.update(recursiveScan: val),
          ),

          SwitchListTile(
            title: const Text('预加载下一条视频'),
            subtitle: const Text('桌面最多两个播放器；Android 保持单解码器'),
            value: settings.preloadNext,
            onChanged: (value) => settings.update(preloadNext: value),
          ),
          SwitchListTile(
            title: const Text('外置机械硬盘优化'),
            subtitle: const Text('等当前视频准备完成后再预加载，减少同时读取'),
            value: settings.externalDriveOptimization,
            onChanged: (value) =>
                settings.update(externalDriveOptimization: value),
          ),
          _buildSectionHeader('显示'),
          ListTile(
            title: const Text('浮层模式'),
            subtitle: const Text('轻触或移动鼠标唤出控制'),
            trailing: DropdownButton<String>(
              value: settings.overlayMode,
              items: const [
                DropdownMenuItem(value: 'full', child: Text('完整信息')),
                DropdownMenuItem(value: 'progress', child: Text('仅进度')),
                DropdownMenuItem(value: 'none', child: Text('无浮层')),
              ],
              onChanged: (value) => settings.update(overlayMode: value),
            ),
          ),
          SwitchListTile(
            title: const Text('切换动画'),
            value: settings.animations,
            onChanged: (value) => settings.update(animations: value),
          ),
          SwitchListTile(
            title: const Text('双击收藏'),
            value: settings.doubleTapFavorite,
            onChanged: (value) => settings.update(doubleTapFavorite: value),
          ),
          SwitchListTile(
            title: const Text('显示文件名'),
            value: settings.showFilename,
            onChanged: (val) => settings.update(showFilename: val),
          ),
          SwitchListTile(
            title: const Text('显示目录'),
            value: settings.showFolder,
            onChanged: (val) => settings.update(showFolder: val),
          ),
          SwitchListTile(
            title: const Text('显示随机队列总数与进度'),
            subtitle: const Text('在顶部栏显示当前位置与总视频数 (如 12 / 158)'),
            value: settings.showQueueProgress,
            onChanged: (val) => settings.update(showQueueProgress: val),
          ),
          SwitchListTile(
            title: const Text('显示文件大小'),
            subtitle: const Text('在视频信息区显示文件大小 (如 45.2 MB)'),
            value: settings.showFileSize,
            onChanged: (val) => settings.update(showFileSize: val),
          ),
          SwitchListTile(
            title: const Text('显示视频格式扩展名'),
            value: settings.showVideoFormat,
            onChanged: (val) => settings.update(showVideoFormat: val),
          ),

          _buildSectionHeader('快捷键'),
          SwitchListTile(
            title: const Text('启用键盘快捷键'),
            value: settings.keyboardEnabled,
            onChanged: (value) => settings.update(keyboardEnabled: value),
          ),
          ListTile(
            title: const Text('快捷键设置'),
            subtitle: const Text('配置播放控制、翻页与收藏等桌面快捷键'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.shortcuts),
          ),

          ListTile(
            title: const Text('播放错误记录'),
            subtitle: const Text('本机保留最近 100 条'),
            onTap: () =>
                showPlaybackErrors(context, context.read<FeedController>()),
          ),
          if (settings.error != null) ListTile(title: Text(settings.error!)),
          _buildSectionHeader('关于'),
          const ListTile(
            title: Text('ReelDeck'),
            subtitle: Text('本地视频随机播放器'),
            trailing: Text('v0.3.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF23DFA1),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
