import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../shortcuts/shortcut_action.dart';
import '../shortcuts/shortcut_binding.dart';

class AppSettings extends ChangeNotifier {
  File? file;
  Future<void> _writes = Future.value();
  String? error;

  bool autoplay = true;
  bool loopQueue = true;
  String videoFit = 'fit';
  bool rememberPosition = false;
  double defaultVolume = 1.0;
  bool recursiveScan = true;
  bool showFilename = true;
  bool showFolder = true;
  bool showFileSize = true;
  bool showQueueProgress = true;
  bool showVideoFormat = true;
  Map<ShortcutAction, List<ShortcutBinding>> shortcuts =
      ShortcutAction.createDefaultMap();

  Future<void> load(File target) async {
    file = target;
    if (!await target.exists()) return;
    try {
      final data =
          jsonDecode(await target.readAsString()) as Map<String, dynamic>;
      autoplay = data['autoplay'] as bool? ?? true;
      loopQueue = data['loopQueue'] as bool? ?? true;
      videoFit = data['videoFit'] as String? ?? 'fit';
      if (!['fit', 'fill', 'original'].contains(videoFit)) videoFit = 'fit';
      rememberPosition = data['rememberPosition'] as bool? ?? false;
      defaultVolume = (data['defaultVolume'] as num? ?? 1).toDouble().clamp(
        0,
        1,
      );
      recursiveScan = data['recursiveScan'] as bool? ?? true;
      showFilename = data['showFilename'] as bool? ?? true;
      showFolder = data['showFolder'] as bool? ?? true;
      showFileSize = data['showFileSize'] as bool? ?? true;
      showQueueProgress = data['showQueueProgress'] as bool? ?? true;
      showVideoFormat = data['showVideoFormat'] as bool? ?? true;

      if (data['shortcuts'] is Map<String, dynamic>) {
        final map = data['shortcuts'] as Map<String, dynamic>;
        final parsed = <ShortcutAction, List<ShortcutBinding>>{};
        for (final entry in map.entries) {
          final action = ShortcutAction.values.cast<ShortcutAction?>().firstWhere(
            (a) => a?.name == entry.key,
            orElse: () => null,
          );
          if (action != null && entry.value is List) {
            parsed[action] = (entry.value as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => ShortcutBinding.fromJson(e))
                .toList();
          }
        }
        for (final action in ShortcutAction.values) {
          shortcuts[action] = parsed[action] ?? List.from(action.defaultBindings);
        }
      } else {
        shortcuts = ShortcutAction.createDefaultMap();
      }
    } catch (_) {
      error = '设置文件无法读取，已使用默认值';
    }
  }

  Future<void> get flushed => _writes;
  void _save() {
    if (file == null) return;
    final text = jsonEncode({
      'autoplay': autoplay,
      'loopQueue': loopQueue,
      'videoFit': videoFit,
      'rememberPosition': rememberPosition,
      'defaultVolume': defaultVolume,
      'recursiveScan': recursiveScan,
      'showFilename': showFilename,
      'showFolder': showFolder,
      'showFileSize': showFileSize,
      'showQueueProgress': showQueueProgress,
      'showVideoFormat': showVideoFormat,
      'shortcuts': shortcuts.map(
        (k, v) => MapEntry(k.name, v.map((b) => b.toJson()).toList()),
      ),
    });
    _writes = _writes
        .then((_) async {
          final temporary = File('${file!.path}.tmp');
          await temporary.writeAsString(text, flush: true);
          await temporary.rename(file!.path);
        })
        .catchError((Object e) {
          error = '保存设置失败：$e';
        });
  }

  void update({
    bool? autoplay,
    bool? loopQueue,
    String? videoFit,
    bool? rememberPosition,
    double? defaultVolume,
    bool? recursiveScan,
    bool? showFilename,
    bool? showFolder,
    bool? showFileSize,
    bool? showQueueProgress,
    bool? showVideoFormat,
  }) {
    if (autoplay != null) this.autoplay = autoplay;
    if (loopQueue != null) this.loopQueue = loopQueue;
    if (videoFit != null) this.videoFit = videoFit;
    if (rememberPosition != null) this.rememberPosition = rememberPosition;
    if (defaultVolume != null) this.defaultVolume = defaultVolume;
    if (recursiveScan != null) this.recursiveScan = recursiveScan;
    if (showFilename != null) this.showFilename = showFilename;
    if (showFolder != null) this.showFolder = showFolder;
    if (showFileSize != null) this.showFileSize = showFileSize;
    if (showQueueProgress != null) this.showQueueProgress = showQueueProgress;
    if (showVideoFormat != null) this.showVideoFormat = showVideoFormat;
    _save();
    notifyListeners();
  }

  void updateShortcut(ShortcutAction action, List<ShortcutBinding> bindings) {
    shortcuts[action] = List<ShortcutBinding>.from(bindings);
    _save();
    notifyListeners();
  }

  void resetShortcuts() {
    shortcuts = ShortcutAction.createDefaultMap();
    _save();
    notifyListeners();
  }

  ShortcutAction? matchShortcut(KeyEvent event, HardwareKeyboard keyboard) {
    return ShortcutBinding.matchAction(shortcuts, event, keyboard);
  }
}
