import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../sources/source_manager.dart';
import '../feed_controller.dart';

class ScopePicker extends StatelessWidget {
  final FeedController feed;
  final SourceManager sources;
  const ScopePicker({super.key, required this.feed, required this.sources});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'all', child: Text(l10n.allVideos)),
      DropdownMenuItem(value: 'favorites', child: Text(l10n.favorites)),
      ...sources.sources.map(
        (s) => DropdownMenuItem(
          value: 'source:${s.id}',
          child: Text(s.name, overflow: TextOverflow.ellipsis),
        ),
      ),
      if (feed.scope.startsWith('folder:'))
        DropdownMenuItem(
          value: feed.scope,
          child: Text(
            feed.scope.substring(feed.scope.indexOf(':', 7) + 1),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      DropdownMenuItem(value: 'choose-folder', child: Text(l10n.chooseFolderEllipsis)),
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: items.any((item) => item.value == feed.scope)
            ? feed.scope
            : 'all',
        items: items,
        onChanged: (value) async {
          if (value == 'choose-folder') {
            final scope = await showDialog<String>(
              context: context,
              builder: (_) => _FolderDialog(sources: sources),
            );
            if (scope != null) await feed.setScope(scope);
          } else if (value != null) {
            await feed.setScope(value);
          }
        },
      ),
    );
  }
}

class _FolderDialog extends StatefulWidget {
  final SourceManager sources;
  const _FolderDialog({required this.sources});
  @override
  State<_FolderDialog> createState() => _FolderDialogState();
}

class _FolderDialogState extends State<_FolderDialog> {
  late final List<(String, String)> _folders;
  String _query = '';
  @override
  void initState() {
    super.initState();
    final folders = <String, String>{};
    for (final media in widget.sources.allMedia) {
      var folder = p.posix.dirname(media.relativePath.replaceAll('\\', '/'));
      final source = widget.sources.getSourceForMedia(media);
      if (source?.enabled != true) continue;
      while (true) {
        folders['folder:${media.sourceId}:$folder'] =
            '${source!.name} / $folder';
        if (folder == '.') break;
        folder = p.posix.dirname(folder);
      }
    }
    _folders = folders.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _folders
        .where((f) => f.$2.toLowerCase().contains(_query))
        .toList();
    return AlertDialog(
      title: Text(l10n.chooseFolder),
      content: SizedBox(
        width: 480,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (value) =>
                  setState(() => _query = value.toLowerCase()),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(l10n.noMatchingFolders))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filtered[index].$2),
                        onTap: () => Navigator.pop(context, filtered[index].$1),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
