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

          _buildSectionHeader('关于'),
          const ListTile(
            title: Text('ReelDeck'),
            subtitle: Text('本地视频随机播放器'),
            trailing: Text('v0.1.0'),
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
