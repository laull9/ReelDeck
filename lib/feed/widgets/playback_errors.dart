import 'package:flutter/material.dart';

import '../feed_controller.dart';

Future<void> showPlaybackErrors(BuildContext context, FeedController feed) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('播放错误'),
        content: SizedBox(
          width: 560,
          height: 360,
          child: feed.errorLog.entries.isEmpty
              ? const Center(child: Text('还没有播放错误记录'))
              : ListView.builder(
                  itemCount: feed.errorLog.entries.length,
                  itemBuilder: (_, index) {
                    final entry = feed.errorLog.entries[index];
                    return ListTile(
                      title: Text(entry['name'] ?? ''),
                      subtitle: SelectableText(
                        '${entry['time']}\n${entry['message']}',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              feed.errorLog.clear();
              Navigator.pop(context);
            },
            child: const Text('清空记录'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
