import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:provider/provider.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_gestures.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

/// 红、绿、蓝视频分别标记三个文件，逐帧读取实际 Feed 的渲染结果。
Future<void> runTransitionSmoke(Map<String, Uint8List> fixtures) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final directory = await Directory.systemTemp.createTemp(
    'reeldeck-transition',
  );
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final store = LibraryStore(db);
  final sources = SourceManager(store: store);
  final settings = AppSettings()
    ..update(autoplay: true, defaultVolume: 0, overlayMode: 'none');
  final feed = FeedController(
    sourceManager: sources,
    store: store,
    settings: settings,
  );
  final boundaryKey = GlobalKey();
  var exitCode = 0;
  try {
    for (final entry in fixtures.entries) {
      await File('${directory.path}/${entry.key}.mp4')
          .writeAsBytes(entry.value);
    }
    final source = Source(
      id: 1,
      name: '颜色验收',
      locator: directory.path,
      lastKnownPath: directory.path,
      platform: 'test',
    );
    await store.saveSource(source);
    sources.addSource(source);
    await sources.scanSource(source);
    final ids = fixtures.keys
        .map(
          (name) => sources.allMedia
              .firstWhere((media) => media.fileName == '$name.mp4')
              .id,
        )
        .toList();
    for (final id in ids) {
      await db.stateDao.updatePosition(id, 7000);
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: feed),
          ChangeNotifierProvider.value(value: sources),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: MaterialApp(
          home: RepaintBoundary(key: boundaryKey, child: const FeedScreen()),
        ),
      ),
    );
    await feed.initialize();
    feed.queue.restore(ids, 0);
    await feed.retry();
    await feed.settled;
    await Future<void>.delayed(const Duration(milliseconds: 150));

    Future<String> sample() async {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 0.15);
      try {
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final offset =
            ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
        final red = bytes!.getUint8(offset);
        final green = bytes.getUint8(offset + 1);
        final blue = bytes.getUint8(offset + 2);
        if (red > 180 && green < 80 && blue < 80) return 'red';
        if (green > 180 && red < 80 && blue < 80) return 'green';
        if (blue > 180 && red < 80 && green < 80) return 'blue';
        if (red < 25 && green < 25 && blue < 25) return 'black';
        return '$red/$green/$blue';
      } finally {
        image.dispose();
      }
    }

    FeedGestureHandlerState handler() {
      FeedGestureHandlerState? found;
      void visit(Element element) {
        if (element is StatefulElement &&
            element.state is FeedGestureHandlerState) {
          found = element.state as FeedGestureHandlerState;
        }
        element.visitChildren(visit);
      }

      visit(WidgetsBinding.instance.rootElement!);
      return found!;
    }

    final initial = await sample();
    if (initial != 'red') throw StateError('初始 Texture 未显示红帧：$initial');
    debugPrint('TRANSITION initial red PASS');

    Future<void> switchAndCheck({
      required bool next,
      required int id,
      required String oldColor,
      required String color,
    }) async {
      if (next) {
        handler().animateNext();
      } else {
        handler().animatePrevious();
      }
      var oldLeft = false;
      var targetShown = false;
      var samples = 0;
      final colors = <String>[];
      final watch = Stopwatch()..start();
      while (watch.elapsed < const Duration(seconds: 8)) {
        final pixel = await sample();
        samples++;
        colors.add(pixel);
        if (oldLeft && pixel == oldColor) {
          throw StateError('旧帧闪回：$oldColor -> ${colors.join(",")}');
        }
        if (pixel != oldColor) oldLeft = true;
        if (pixel == color && feed.currentMediaId == id && !feed.busy) {
          targetShown = true;
          if (samples > 18) break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
      if (!targetShown || feed.currentMediaId != id || feed.error != null) {
        throw StateError('未交接到 $color：${feed.error} ${colors.join(",")}');
      }
      await feed.settled;
      for (var i = 0; i < 5; i++) {
        if (await sample() != color) throw StateError('交接后帧颜色改变');
      }
      debugPrint('TRANSITION $oldColor -> $color samples=$samples PASS');
    }

    await switchAndCheck(
      next: true,
      id: ids[1],
      oldColor: 'red',
      color: 'green',
    );
    await switchAndCheck(
      next: false,
      id: ids[0],
      oldColor: 'green',
      color: 'red',
    );
    await switchAndCheck(
      next: true,
      id: ids[1],
      oldColor: 'red',
      color: 'green',
    );
    await switchAndCheck(
      next: true,
      id: ids[2],
      oldColor: 'green',
      color: 'blue',
    );
    final last = feed.currentMediaId;
    await feed.next();
    await feed.settled;
    await feed.previous();
    await feed.settled;
    if (feed.currentMediaId != last) throw StateError('跨轮返回失败');
    if (await sample() != 'blue') throw StateError('跨轮返回画面错误');
    debugPrint('TRANSITION loop previous PASS');
    debugPrint('TRANSITION PASS');
  } catch (error, stack) {
    exitCode = 1;
    debugPrint('TRANSITION FAIL $error\n$stack');
  } finally {
    await feed.close();
    sources.dispose();
    settings.dispose();
    await db.close();
    await directory.delete(recursive: true);
  }
  exit(exitCode);
}
