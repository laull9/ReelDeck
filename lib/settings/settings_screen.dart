import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
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

          _buildSectionHeader('显示'),
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
          ListTile(
            title: const Text('快捷键设置'),
            subtitle: const Text('配置播放控制、翻页与收藏等桌面快捷键'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.shortcuts),
          ),

          _buildSectionHeader('关于'),
          const ListTile(
            title: Text('ReelDeck'),
            subtitle: Text('本地视频随机播放器'),
            trailing: Text('v0.2.0'),
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
          color: Colors.deepPurpleAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
