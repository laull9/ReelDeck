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
  String queueOrder = 'shuffle';
  bool reshuffleAfterRound = true;
  bool includeImages = false;
  int imageSeconds = 8;
  String overlayMode = 'full';
  bool animations = true;
  bool doubleTapFavorite = true;
  bool keyboardEnabled = true;
  bool preloadNext = true;
  bool externalDriveOptimization = true;
  bool loopQueue = true;
  String videoFit = 'fit';
  bool rememberPosition = true;
  double defaultVolume = 1.0;
  bool recursiveScan = true;
  bool showFilename = true;
  bool showFolder = true;
  bool showFileSize = true;
  bool showQueueProgress = true;
  bool showVideoFormat = true;
  String locale = 'system';
  String decoderMode = 'auto';
  Map<ShortcutAction, List<ShortcutBinding>> shortcuts =
      ShortcutAction.createDefaultMap();

  Future<void> load(File target) async {
    file = target;
    if (!await target.exists()) return;
    try {
      final data =
          jsonDecode(await target.readAsString()) as Map<String, dynamic>;
      autoplay = data['autoplay'] as bool? ?? true;
      queueOrder = data['queueOrder'] as String? ?? 'shuffle';
      if (!['shuffle', 'smart', 'newest', 'oldest'].contains(queueOrder)) {
        queueOrder = 'shuffle';
      }
      reshuffleAfterRound = data['reshuffleAfterRound'] as bool? ?? true;
      includeImages = data['includeImages'] as bool? ?? false;
      imageSeconds = (data['imageSeconds'] as int? ?? 8).clamp(1, 300);
      overlayMode = data['overlayMode'] as String? ?? 'full';
      if (!['full', 'progress', 'none'].contains(overlayMode)) {
        overlayMode = 'full';
      }
      animations = data['animations'] as bool? ?? true;
      doubleTapFavorite = data['doubleTapFavorite'] as bool? ?? true;
      keyboardEnabled = data['keyboardEnabled'] as bool? ?? true;
      preloadNext = data['preloadNext'] as bool? ?? true;
      externalDriveOptimization =
          data['externalDriveOptimization'] as bool? ?? true;
      loopQueue = data['loopQueue'] as bool? ?? true;
      videoFit = data['videoFit'] as String? ?? 'fit';
      if (!['fit', 'fill', 'original'].contains(videoFit)) videoFit = 'fit';
      rememberPosition = data['rememberPosition'] as bool? ?? true;
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
      locale = data['locale'] as String? ?? 'system';
      if (!['system', 'en', 'zh', 'ja', 'es', 'fr'].contains(locale)) {
        locale = 'system';
      }
      decoderMode = data['decoderMode'] as String? ?? 'auto';
      if (!['auto', 'auto-safe', 'no'].contains(decoderMode)) {
        decoderMode = 'auto';
      }

      if (data['shortcuts'] is Map<String, dynamic>) {
        final map = data['shortcuts'] as Map<String, dynamic>;
        final parsed = <ShortcutAction, List<ShortcutBinding>>{};
        for (final entry in map.entries) {
          final action = ShortcutAction.values
              .cast<ShortcutAction?>()
              .firstWhere((a) => a?.name == entry.key, orElse: () => null);
          if (action != null && entry.value is List) {
            parsed[action] = (entry.value as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => ShortcutBinding.fromJson(e))
                .toList();
          }
        }
        for (final action in ShortcutAction.values) {
          shortcuts[action] =
              parsed[action] ?? List.from(action.defaultBindings);
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
      'queueOrder': queueOrder,
      'reshuffleAfterRound': reshuffleAfterRound,
      'includeImages': includeImages,
      'imageSeconds': imageSeconds,
      'overlayMode': overlayMode,
      'animations': animations,
      'doubleTapFavorite': doubleTapFavorite,
      'keyboardEnabled': keyboardEnabled,
      'preloadNext': preloadNext,
      'externalDriveOptimization': externalDriveOptimization,
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
      'locale': locale,
      'decoderMode': decoderMode,
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
    String? queueOrder,
    bool? reshuffleAfterRound,
    bool? includeImages,
    int? imageSeconds,
    String? overlayMode,
    bool? animations,
    bool? doubleTapFavorite,
    bool? keyboardEnabled,
    bool? preloadNext,
    bool? externalDriveOptimization,
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
    String? locale,
    String? decoderMode,
  }) {
    if (autoplay != null) this.autoplay = autoplay;
    if (queueOrder != null &&
        ['shuffle', 'smart', 'newest', 'oldest'].contains(queueOrder)) {
      this.queueOrder = queueOrder;
    }
    if (reshuffleAfterRound != null) {
      this.reshuffleAfterRound = reshuffleAfterRound;
    }
    if (includeImages != null) this.includeImages = includeImages;
    if (imageSeconds != null) this.imageSeconds = imageSeconds.clamp(1, 300);
    if (overlayMode != null &&
        ['full', 'progress', 'none'].contains(overlayMode)) {
      this.overlayMode = overlayMode;
    }
    if (animations != null) this.animations = animations;
    if (doubleTapFavorite != null) this.doubleTapFavorite = doubleTapFavorite;
    if (keyboardEnabled != null) this.keyboardEnabled = keyboardEnabled;
    if (preloadNext != null) this.preloadNext = preloadNext;
    if (externalDriveOptimization != null) {
      this.externalDriveOptimization = externalDriveOptimization;
    }
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
    if (locale != null &&
        ['system', 'en', 'zh', 'ja', 'es', 'fr'].contains(locale)) {
      this.locale = locale;
    }
    if (decoderMode != null &&
        ['auto', 'auto-safe', 'no'].contains(decoderMode)) {
      this.decoderMode = decoderMode;
    }
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
