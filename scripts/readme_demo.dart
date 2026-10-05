import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:provider/provider.dart';
import 'package:reel_deck/app/routes.dart';
import 'package:reel_deck/app/theme.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/l10n/app_localizations.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/settings/settings_screen.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

/// README 演示录制：手机尺寸的真实 Feed，逐帧截图写入应用沙盒临时目录。
/// 由 scripts/record_readme_demo.py 调用，使用内存数据库，不读写用户数据。
const phone = Size(360, 720);
const fps = 12;
var _boundary = GlobalKey();
var _pointer = 500;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final root = Directory('${Directory.systemTemp.path}/reeldeck-demo');
  final media = Directory('${root.path}/Open Movies');
  for (final locale in ['en', 'zh', 'ja', 'es', 'fr']) {
    await _record(locale, media, Directory('${root.path}/$locale'));
    debugPrint('DEMO $locale DONE');
  }
  exit(0);
}

Future<void> _record(String locale, Directory media, Directory output) async {
  // GlobalKey 会把旧子树连同导航栈搬进新树，每种语言换新 key。
  _boundary = GlobalKey();
  await output.create(recursive: true);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final store = LibraryStore(db);
  final sources = SourceManager(store: store);
  final settings = AppSettings()
    ..update(
      locale: locale,
      autoplay: true,
      defaultVolume: 0,
      videoFit: 'fill',
      rememberPosition: false,
    );
  final feed = FeedController(
    sourceManager: sources,
    store: store,
    settings: settings,
  );
  final source = Source(
    id: 1,
    name: 'Open Movies',
    locator: media.path,
    lastKnownPath: media.path,
    platform: 'test',
  );
  await store.saveSource(source);
  sources.addSource(source);
  await sources.scanSource(source);
  final ids = [
    'Big Buck Bunny.mp4',
    'Sintel.mp4',
    'Tears of Steel.mp4',
  ].map((name) => sources.allMedia.firstWhere((m) => m.fileName == name).id);

  runApp(
    // 每种语言重建整棵树，不沿用上一轮的导航栈。
    ColoredBox(
      key: ValueKey(locale),
      color: Colors.black,
      child: Center(
        child: FittedBox(
          child: SizedBox.fromSize(
            size: phone,
            child: MediaQuery(
              data: const MediaQueryData(size: phone),
              child: RepaintBoundary(
                key: _boundary,
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(value: settings),
                    ChangeNotifierProvider.value(value: sources),
                    ChangeNotifierProvider.value(value: feed),
                  ],
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.dark(),
                    locale: Locale(locale),
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    home: const FeedScreen(),
                    routes: {AppRoutes.settings: (_) => const SettingsScreen()},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await feed.initialize();
  feed.queue.restore(ids.toList(), 0);
  await feed.retry();
  await feed.settled;
  await Future<void>.delayed(const Duration(milliseconds: 600));

  final frames = await File('${output.path}/frames.rgba')
      .open(mode: FileMode.write);
  final times = <int>[];
  final clock = Stopwatch()..start();
  var recording = true;
  final capture = () async {
    while (recording) {
      final started = clock.elapsedMilliseconds;
      final bytes = await _frame();
      if (bytes != null) {
        await frames.writeFrom(bytes);
        times.add(started);
      }
      final wait = 1000 ~/ fps - (clock.elapsedMilliseconds - started);
      if (wait > 0) await Future<void>.delayed(Duration(milliseconds: wait));
    }
  }();

  final l10n = AppLocalizations(Locale(locale));
  Future<void> at(int ms) async {
    final wait = ms - clock.elapsedMilliseconds;
    if (wait > 0) await Future<void>.delayed(Duration(milliseconds: wait));
  }

  await _hover(const Offset(180, 360));
  await at(1300);
  await _hover(const Offset(200, 380));
  await at(2200);
  await _drag(const Offset(180, 520), const Offset(180, 200));
  await at(4300);
  await _hover(const Offset(180, 360));
  await at(4800);
  await _drag(const Offset(180, 520), const Offset(180, 200));
  await at(7000);
  await _tap(
    await _center((w) => w is Icon && w.icon == Icons.favorite_border),
  );
  await at(8000);
  await _tap(await _center((w) => w is DropdownButton<String>));
  await at(9100);
  await _tap(
    await _center((w) => w is Text && w.data == l10n.favorites, last: true),
  );
  await at(10300);
  await _hover(const Offset(180, 360));
  await _tap(await _center((w) => w is Icon && w.icon == Icons.settings));
  await at(11800);
  await _drag(
    const Offset(180, 600),
    const Offset(180, 240),
    duration: const Duration(milliseconds: 700),
  );
  await at(14000);

  recording = false;
  await capture;
  await frames.close();
  await File('${output.path}/frames.txt').writeAsString(
    '${phone.width.toInt()}x${phone.height.toInt()}\n${times.join('\n')}\n',
  );
  await feed.close();
  sources.dispose();
  settings.dispose();
  await db.close();
}

Future<List<int>?> _frame() async {
  // 窗口被遮挡或锁屏时系统不再发出 vsync，等不到正常帧才主动驱动一帧。
  final drawn = WidgetsBinding.instance.endOfFrame;
  final vsync = await drawn
      .then((_) => true)
      .timeout(const Duration(milliseconds: 200), onTimeout: () => false);
  if (!vsync) {
    SchedulerBinding.instance.scheduleWarmUpFrame();
    await WidgetsBinding.instance.endOfFrame;
  }
  final boundary =
      _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final image = await boundary.toImage();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// 在手机画面坐标系中查找控件中心，转换为窗口坐标。
Future<Offset> _center(bool Function(Widget) test, {bool last = false}) async {
  for (var i = 0; i < 20; i++) {
    final found = _find(test, last: last);
    if (found != null) return found;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('演示控件未找到');
}

Offset? _find(bool Function(Widget) test, {bool last = false}) {
  Element? found;
  void visit(Element element) {
    if (!last && found != null) return;
    if (test(element.widget)) found = element;
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement!.visitChildren(visit);
  final box = found?.renderObject as RenderBox?;
  if (box == null) return null;
  return box.localToGlobal(box.size.center(Offset.zero));
}

Offset _global(Offset local) {
  final box = _boundary.currentContext!.findRenderObject()! as RenderBox;
  return box.localToGlobal(local);
}

Future<void> _hover(Offset local) async {
  GestureBinding.instance.handlePointerEvent(
    PointerHoverEvent(kind: PointerDeviceKind.mouse, position: _global(local)),
  );
}

Future<void> _tap(Offset position) async {
  final pointer = _pointer++;
  final binding = GestureBinding.instance;
  binding.handlePointerEvent(
    PointerDownEvent(pointer: pointer, position: position),
  );
  await Future<void>.delayed(const Duration(milliseconds: 60));
  binding.handlePointerEvent(
    PointerUpEvent(pointer: pointer, position: position),
  );
}

Future<void> _drag(
  Offset from,
  Offset to, {
  Duration duration = const Duration(milliseconds: 220),
}) async {
  final pointer = _pointer++;
  final binding = GestureBinding.instance;
  final start = _global(from), end = _global(to);
  binding.handlePointerEvent(
    PointerDownEvent(pointer: pointer, position: start),
  );
  const steps = 12;
  var last = start;
  for (var i = 1; i <= steps; i++) {
    await Future<void>.delayed(duration ~/ steps);
    final next = Offset.lerp(start, end, i / steps)!;
    binding.handlePointerEvent(
      PointerMoveEvent(pointer: pointer, position: next, delta: next - last),
    );
    last = next;
  }
  binding.handlePointerEvent(PointerUpEvent(pointer: pointer, position: end));
}
