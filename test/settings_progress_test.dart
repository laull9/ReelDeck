import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/settings/settings.dart';

void main() {
  test('首次启动及缺少字段的旧设置默认记住进度，显式关闭仍保留', () async {
    final directory = await Directory.systemTemp.createTemp(
      'reeldeck-settings',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/settings.json');
    final settings = AppSettings();
    expect(settings.rememberPosition, true);
    await file.writeAsString('{}');
    await settings.load(file);
    expect(settings.rememberPosition, true);
    settings.update(rememberPosition: false);
    await settings.flushed;
    final reloaded = AppSettings();
    await reloaded.load(file);
    expect(reloaded.rememberPosition, false);
  });
}
