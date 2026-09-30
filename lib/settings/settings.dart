import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  File? file;
  Future<void> _writes = Future.value();
  String? error;
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

  bool autoplay = true;
  bool loopQueue = true;
  String videoFit = 'fit';
  bool rememberPosition = false;
  double defaultVolume = 1.0;
  bool recursiveScan = true;
  bool showFilename = true;
  bool showFolder = true;

  void update({
    bool? autoplay,
    bool? loopQueue,
    String? videoFit,
    bool? rememberPosition,
    double? defaultVolume,
    bool? recursiveScan,
    bool? showFilename,
    bool? showFolder,
  }) {
    if (autoplay != null) this.autoplay = autoplay;
    if (loopQueue != null) this.loopQueue = loopQueue;
    if (videoFit != null) this.videoFit = videoFit;
    if (rememberPosition != null) this.rememberPosition = rememberPosition;
    if (defaultVolume != null) this.defaultVolume = defaultVolume;
    if (recursiveScan != null) this.recursiveScan = recursiveScan;
    if (showFilename != null) this.showFilename = showFilename;
    if (showFolder != null) this.showFolder = showFolder;
    _save();
    notifyListeners();
  }
}
