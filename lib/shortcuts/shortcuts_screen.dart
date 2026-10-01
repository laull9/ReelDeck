import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings.dart';
import 'shortcut_action.dart';
import 'shortcut_binding.dart';
import 'shortcuts_editor_dialog.dart';

class ShortcutsScreen extends StatelessWidget {
  const ShortcutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final shortcuts = settings.shortcuts;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shortcutsSettings),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmReset(context, settings),
            icon: const Icon(Icons.restore, size: 18),
            label: Text(l10n.resetDefaults),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          for (final category in ShortcutActionCategory.values) ...[
            _buildCategoryHeader(category.label),
            ...ShortcutAction.values
                .where((a) => a.category == category)
                .map((action) => _buildActionTile(
                      context,
                      settings,
                      action,
                      shortcuts[action] ?? const [],
                    )),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    AppSettings settings,
    ShortcutAction action,
    List<ShortcutBinding> bindings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withAlpha(120),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action.description,
                        style: TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '添加快捷键',
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _addShortcut(context, settings, action),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (bindings.isEmpty)
                  Text(
                    '未设置快捷键',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white30,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                for (final binding in bindings)
                  InputChip(
                    label: Text(binding.displayString()),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      final updated = List<ShortcutBinding>.from(bindings)
                        ..remove(binding);
                      settings.updateShortcut(action, updated);
                    },
                    onPressed: () => _editShortcut(
                      context,
                      settings,
                      action,
                      binding,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addShortcut(
    BuildContext context,
    AppSettings settings,
    ShortcutAction action,
  ) async {
    final result = await ShortcutEditorDialog.show(
      context,
      action: action,
      existingShortcuts: settings.shortcuts,
    );
    if (result != null) {
      final current = settings.shortcuts[action] ?? const [];
      if (!current.contains(result)) {
        final updated = List<ShortcutBinding>.from(current)..add(result);
        settings.updateShortcut(action, updated);
      }
    }
  }

  Future<void> _editShortcut(
    BuildContext context,
    AppSettings settings,
    ShortcutAction action,
    ShortcutBinding target,
  ) async {
    final result = await ShortcutEditorDialog.show(
      context,
      action: action,
      initialBinding: target,
      existingShortcuts: settings.shortcuts,
    );
    if (result != null) {
      final current = settings.shortcuts[action] ?? const [];
      final updated = List<ShortcutBinding>.from(current);
      final index = updated.indexOf(target);
      if (index != -1) {
        updated[index] = result;
      } else {
        updated.add(result);
      }
      settings.updateShortcut(action, updated);
    }
  }

  Future<void> _confirmReset(BuildContext context, AppSettings settings) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetShortcutsTitle),
        content: Text(l10n.resetShortcutsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmReset),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      settings.resetShortcuts();
    }
  }
}
