import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../feed/feed_controller.dart';
import '../l10n/app_localizations.dart';
import 'source_manager.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final manager = context.watch<SourceManager>();
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.videoSources),
        actions: [
          IconButton(
            tooltip: l10n.rescan,
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
                ? Center(child: Text(l10n.emptySourcesHint))
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
                            '${source.lastKnownPath}\n${manager.allMedia.where((m) => m.sourceId == source.id).length} ${l10n.items}',
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
                                    title: Text(
                                      '${l10n.remove} ${source.name}?',
                                    ),
                                    content: Text(
                                      l10n.confirmRemoveSource,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(l10n.remove),
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
                                child: Text(l10n.includeSubfolders),
                              ),
                              PopupMenuItem(
                                value: 'scan',
                                child: Text(l10n.rescan),
                              ),
                              PopupMenuItem(
                                value: 'remove',
                                child: Text(l10n.remove),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.visibility),
                        title: Text(l10n.restoreHidden),
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
        label: Text(l10n.addFolder),
      ),
    );
  }
}
