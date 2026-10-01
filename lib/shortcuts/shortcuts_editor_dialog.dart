import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'shortcut_action.dart';
import 'shortcut_binding.dart';

class ShortcutEditorDialog extends StatefulWidget {
  final ShortcutAction action;
  final ShortcutBinding? initialBinding;
  final Map<ShortcutAction, List<ShortcutBinding>> existingShortcuts;

  const ShortcutEditorDialog({
    super.key,
    required this.action,
    this.initialBinding,
    required this.existingShortcuts,
  });

  static Future<ShortcutBinding?> show(
    BuildContext context, {
    required ShortcutAction action,
    ShortcutBinding? initialBinding,
    required Map<ShortcutAction, List<ShortcutBinding>> existingShortcuts,
  }) {
    return showDialog<ShortcutBinding>(
      context: context,
      builder: (context) => ShortcutEditorDialog(
        action: action,
        initialBinding: initialBinding,
        existingShortcuts: existingShortcuts,
      ),
    );
  }

  @override
  State<ShortcutEditorDialog> createState() => _ShortcutEditorDialogState();
}

class _ShortcutEditorDialogState extends State<ShortcutEditorDialog> {
  final FocusNode _focusNode = FocusNode();
  ShortcutBinding? _capturedBinding;
  String? _conflictActionName;

  @override
  void initState() {
    super.initState();
    _capturedBinding = widget.initialBinding;
    if (_capturedBinding != null) {
      _checkConflict(_capturedBinding!);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _checkConflict(ShortcutBinding binding) {
    String? conflict;
    for (final entry in widget.existingShortcuts.entries) {
      if (entry.key == widget.action) continue;
      if (entry.value.contains(binding)) {
        conflict = entry.key.label;
        break;
      }
    }
    setState(() {
      _conflictActionName = conflict;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (ShortcutBinding.isModifierKey(key)) {
      return KeyEventResult.handled;
    }

    final keyboard = HardwareKeyboard.instance;
    final binding = ShortcutBinding.fromKey(
      key,
      isShift: keyboard.isShiftPressed,
      isControl: keyboard.isControlPressed,
      isAlt: keyboard.isAltPressed,
      isMeta: keyboard.isMetaPressed,
    );

    setState(() {
      _capturedBinding = binding;
    });
    _checkConflict(binding);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text('${l10n.editShortcut}：${widget.action.label}'),
      content: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.action.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _conflictActionName != null
                        ? Colors.amber
                        : Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _capturedBinding != null
                          ? _capturedBinding!.displayString()
                          : l10n.pressKeyToRecord,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _capturedBinding != null
                            ? Colors.white
                            : Colors.white38,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Shift, Ctrl, Alt, Cmd / Win',
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              if (_conflictActionName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$_conflictActionName',
                        style: const TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _capturedBinding != null
              ? () => Navigator.pop(context, _capturedBinding)
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
