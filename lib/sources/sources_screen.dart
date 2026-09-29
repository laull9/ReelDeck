import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'source_manager.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<SourceManager>();
    final sources = manager.sources;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sources'),
      ),
      body: sources.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey.withAlpha(128)),
                  const SizedBox(height: 16),
                  const Text(
                    'No sources added.\nTap + to add a folder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                return Dismissible(
                  key: ValueKey(source.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => manager.removeSource(source.id),
                  child: ListTile(
                    title: Text(source.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.lastKnownPath,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          source.lastScanAt != null
                              ? 'Last scanned: ${_formatDate(source.lastScanAt!)}'
                              : 'Not scanned yet',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Switch(
                      value: source.enabled,
                      onChanged: (_) => manager.toggleSource(source.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => manager.pickAndAddFolder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
