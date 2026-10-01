import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../feed/feed_controller.dart';
import 'source_manager.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final manager = context.watch<SourceManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频目录'),
        actions: [
          IconButton(
            tooltip: '重新扫描',
            onPressed: manager.isScanning ? null : manager.rescanAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (manager.isScanning) const LinearProgressIndicator(),
          if (manager.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                manager.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: manager.sources.isEmpty
                ? const Center(child: Text('添加本地目录或外置硬盘目录'))
                : ListView(
                    children: [
                      ...manager.sources.map(
                        (source) => ListTile(
                          leading: Switch(
                            value: source.enabled,
                            onChanged: manager.isScanning
                                ? null
                                : (_) => manager.toggleSource(source.id),
                          ),
                          title: Text(source.name),
                          subtitle: Text(
                            '${source.lastKnownPath}\n${manager.allMedia.where((m) => m.sourceId == source.id).length} 个媒体',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            enabled: !manager.isScanning,
                            onSelected: (action) async {
                              if (action == 'recursive') {
                                await manager.setRecursive(
                                  source.id,
                                  !source.recursive,
                                );
                              }
                              if (action == 'scan') {
                                await manager.scanSource(source);
                              }
                              if (action == 'authorize') {
                                await manager.pickAndAddFolder(
                                  replaceId: source.id,
                                );
                              }
                              if (action == 'remove' && context.mounted) {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('移除 ${source.name}？'),
                                    content: const Text(
                                      '清除该目录的索引、收藏和隐藏记录。原视频文件保持不变。',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('移除'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await manager.removeSource(source.id);
                                }
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'recursive',
                                child: Text(
                                  source.recursive ? '关闭子目录扫描' : '开启子目录扫描',
                                ),
                              ),
                              PopupMenuItem(value: 'scan', child: Text('重新扫描')),
                              PopupMenuItem(
                                value: 'authorize',
                                child: Text('重新授权 / 迁移目录'),
                              ),
                              PopupMenuItem(
                                value: 'remove',
                                child: Text('移除目录'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.visibility),
                        title: const Text('恢复所有隐藏项'),
                        subtitle: const Text('包含单个视频和目录规则'),
                        onTap: () =>
                            context.read<FeedController>().resetHidden(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: manager.isScanning ? null : manager.pickAndAddFolder,
        icon: const Icon(Icons.add),
        label: const Text('添加目录'),
      ),
    );
  }
}
