import 'dart:convert';
import 'dart:io';

class PlaybackErrorLog {
  final List<Map<String, String>> entries = [];
  File? _file;
  Future<void> _writes = Future.value();
  Future<void> get flushed => _writes;

  Future<void> load(File? file) async {
    _file = file;
    if (file == null || !await file.exists()) return;
    try {
      final rows = jsonDecode(await file.readAsString()) as List;
      entries.addAll(
        rows.take(100).map((row) => Map<String, String>.from(row as Map)),
      );
    } catch (_) {
      // 损坏的日志不阻止播放器启动。
    }
  }

  void add(String message, String name) {
    entries.insert(0, {
      'time': DateTime.now().toIso8601String(),
      'name': name,
      'message': message,
    });
    if (entries.length > 100) entries.removeRange(100, entries.length);
    _save();
  }

  void clear() {
    entries.clear();
    _save();
  }

  void _save() {
    final file = _file;
    if (file == null) return;
    final data = jsonEncode(entries);
    _writes = _writes
        .then((_) async {
          final temp = File('${file.path}.tmp');
          await temp.writeAsString(data, flush: true);
          await temp.rename(file.path);
        })
        .catchError((Object _) {});
  }
}
