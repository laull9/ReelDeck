import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:media_kit/ffi/ffi.dart';
import 'package:media_kit/generated/libmpv/bindings.dart' as mpv;
import 'package:media_kit/media_kit.dart';
// media_kit 1.2.6 的 getProperty 在调用线程执行同步 FFI。
// ignore: implementation_imports
import 'package:media_kit/src/player/native/core/native_library.dart';

/// 属性查询离开 UI isolate；释放句柄前等待查询真正退出，避免超时后的悬空访问。
class NativeProperties {
  NativeProperties(this.player);

  final NativePlayer player;
  final Set<Future<String>> _reads = {};
  bool _closed = false;

  Future<void> set(String name, String value) =>
      player.command(['set', name, value]).timeout(const Duration(seconds: 12));

  Future<String> get(String name) async {
    if (_closed) throw StateError('播放器已关闭');
    final handle = await player.handle;
    if (_closed) throw StateError('播放器已关闭');
    final task = compute(_readProperty, (NativeLibrary.path, handle, name));
    _reads.add(task);
    try {
      return await task;
    } finally {
      _reads.remove(task);
    }
  }

  Future<void> close() async {
    _closed = true;
    await Future.wait([
      for (final read in _reads.toList())
        read.then<void>((_) {}, onError: (Object _) {}),
    ]);
  }
}

String _readProperty((String, int, String) request) {
  final api = mpv.MPV(DynamicLibrary.open(request.$1));
  final name = request.$3.toNativeUtf8();
  final handle = Pointer<mpv.mpv_handle>.fromAddress(request.$2);
  try {
    final value = api.mpv_get_property_string(handle, name.cast());
    if (value == nullptr) return '';
    try {
      return value.cast<Utf8>().toDartString();
    } finally {
      api.mpv_free(value.cast());
    }
  } finally {
    calloc.free(name);
  }
}
