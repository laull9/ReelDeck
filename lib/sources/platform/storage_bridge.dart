import 'package:flutter/services.dart';

class StorageBridge {
  static const channel = MethodChannel('reeldeck/storage');

  static Future<Map<String, dynamic>?> pick() async {
    final value = await channel.invokeMapMethod<String, dynamic>('pick');
    return value;
  }

  static Future<Map<String, dynamic>?> resolve(String locator) =>
      channel.invokeMapMethod<String, dynamic>('resolve', {'locator': locator});

  static Future<List<Map<String, dynamic>>> scan(
    String locator,
    bool recursive,
  ) async {
    final result = await channel.invokeListMethod<dynamic>('scan', {
      'locator': locator,
      'recursive': recursive,
    });
    return (result ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<String?> media(String locator, String path) =>
      channel.invokeMethod<String>('media', {'locator': locator, 'path': path});
}
