import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reel_deck/l10n/app_localizations.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/settings/settings_screen.dart';

Future<void> _pump(WidgetTester tester, Size size, String locale) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: MaterialApp(
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'fr', 'es', 'ja', 'zh']) {
    testWidgets('手机宽度 $locale 下拉设置标题不被挤成单列', (tester) async {
      await _pump(tester, const Size(360, 2400), locale);
      final l10n = AppLocalizations(Locale(locale));
      for (final title in [
        l10n.videoFit,
        l10n.decoderMode,
        l10n.queueOrder,
        l10n.overlayMode,
      ]) {
        final finder = find.text(title);
        await tester.scrollUntilVisible(finder, 200);
        // 标题独占一行，不再与右侧选择框争宽度。
        expect(tester.getSize(finder).width, greaterThan(200), reason: title);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('宽屏下拉框保持在标题右侧', (tester) async {
    await _pump(tester, const Size(1000, 1600), 'en');
    final l10n = AppLocalizations(const Locale('en'));
    final title = tester.getCenter(find.text(l10n.decoderMode));
    final value = tester.getCenter(find.text(l10n.decoderAuto));
    expect(value.dx, greaterThan(title.dx));
    expect((value.dy - title.dy).abs(), lessThan(4));
    expect(tester.takeException(), isNull);
  });

  test('自动刷新目录默认开启，关闭后持久化', () async {
    final directory = await Directory.systemTemp.createTemp('reeldeck-auto');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/settings.json');
    await file.writeAsString('{}');
    final settings = AppSettings();
    await settings.load(file);
    expect(settings.autoRefreshFolders, true);
    settings.update(autoRefreshFolders: false);
    await settings.flushed;
    final reloaded = AppSettings();
    await reloaded.load(file);
    expect(reloaded.autoRefreshFolders, false);
  });
}
