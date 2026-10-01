import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../feed_controller.dart';

Future<void> showPlaybackErrors(BuildContext context, FeedController feed) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.playbackErrors),
      content: SizedBox(
        width: 560,
        height: 360,
        child: feed.errorLog.entries.isEmpty
            ? Center(child: Text(l10n.noPlaybackErrors))
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
          child: Text(l10n.clearLog),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
