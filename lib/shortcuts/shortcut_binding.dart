import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'shortcut_action.dart';

@immutable
class ShortcutBinding {
  final int keyId;
  final String keyLabel;
  final bool isShift;
  final bool isControl;
  final bool isAlt;
  final bool isMeta;

  const ShortcutBinding({
    required this.keyId,
    required this.keyLabel,
    this.isShift = false,
    this.isControl = false,
    this.isAlt = false,
    this.isMeta = false,
  });

  factory ShortcutBinding.fromKey(
    LogicalKeyboardKey key, {
    bool isShift = false,
    bool isControl = false,
    bool isAlt = false,
    bool isMeta = false,
  }) {
    return ShortcutBinding(
      keyId: key.keyId,
      keyLabel: keyDisplayName(key),
      isShift: isShift,
      isControl: isControl,
      isAlt: isAlt,
      isMeta: isMeta,
    );
  }

  static bool isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  static String keyDisplayName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.arrowDown) return '↓';
    if (key == LogicalKeyboardKey.arrowUp) return '↑';
    if (key == LogicalKeyboardKey.arrowLeft) return '←';
    if (key == LogicalKeyboardKey.arrowRight) return '→';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.delete) return 'Delete';
    if (key.keyLabel.trim().isNotEmpty) return key.keyLabel.toUpperCase();
    return key.debugName ?? 'Key';
  }

  bool matches(KeyEvent event, HardwareKeyboard keyboard) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey.keyId != keyId) return false;
    if (keyboard.isShiftPressed != isShift) return false;
    if (keyboard.isControlPressed != isControl) return false;
    if (keyboard.isAltPressed != isAlt) return false;
    if (keyboard.isMetaPressed != isMeta) return false;
    return true;
  }

  String displayString({bool? isMacOS}) {
    final mac = isMacOS ?? (defaultTargetPlatform == TargetPlatform.macOS);
    final parts = <String>[];
    if (isControl) parts.add(mac ? 'Control' : 'Ctrl');
    if (isAlt) parts.add(mac ? 'Option' : 'Alt');
    if (isShift) parts.add('Shift');
    if (isMeta) parts.add(mac ? 'Cmd' : 'Win');
    parts.add(keyLabel);
    return parts.join(' + ');
  }

  Map<String, dynamic> toJson() => {
    'keyId': keyId,
    'keyLabel': keyLabel,
    'isShift': isShift,
    'isControl': isControl,
    'isAlt': isAlt,
    'isMeta': isMeta,
  };

  factory ShortcutBinding.fromJson(Map<String, dynamic> json) {
    return ShortcutBinding(
      keyId: json['keyId'] as int,
      keyLabel: json['keyLabel'] as String? ?? 'Key',
      isShift: json['isShift'] as bool? ?? false,
      isControl: json['isControl'] as bool? ?? false,
      isAlt: json['isAlt'] as bool? ?? false,
      isMeta: json['isMeta'] as bool? ?? false,
    );
  }

  static ShortcutAction? matchAction(
    Map<ShortcutAction, List<ShortcutBinding>> shortcuts,
    KeyEvent event,
    HardwareKeyboard keyboard,
  ) {
    for (final entry in shortcuts.entries) {
      for (final binding in entry.value) {
        if (binding.matches(event, keyboard)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortcutBinding &&
          runtimeType == other.runtimeType &&
          keyId == other.keyId &&
          isShift == other.isShift &&
          isControl == other.isControl &&
          isAlt == other.isAlt &&
          isMeta == other.isMeta;

  @override
  int get hashCode => Object.hash(keyId, isShift, isControl, isAlt, isMeta);
}
