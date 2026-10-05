import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:provider/provider.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

/// 短视频连续快速切换：播放结束、接近结尾的进度与滑动交错，检查画面不停在黑屏。
Future<void> runStressSmoke(Map<String, Uint8List> fixtures) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final directory = await Directory.systemTemp.createTemp('reeldeck-stress');
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
  final random = Random(const int.fromEnvironment('SEED', defaultValue: 7));
  var exitCode = 0;
  try {
    for (final entry in fixtures.entries) {
      await File('${directory.path}/${entry.key}.mp4')
          .writeAsBytes(entry.value);
    }
    final source = Source(
      id: 1,
      name: '压力验收',
      locator: directory.path,
      lastKnownPath: directory.path,
      platform: 'test',
    );
    await store.saveSource(source);
    sources.addSource(source);
    await sources.scanSource(source);
    final colorOf = {
      for (final media in sources.allMedia)
        media.id: media.fileName.split('-').first,
    };
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
    await feed.settled;

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
        final r = bytes!.getUint8(offset);
        final g = bytes.getUint8(offset + 1);
        final b = bytes.getUint8(offset + 2);
        if (r > 180 && g < 80 && b < 80) return 'red';
        if (g > 180 && r < 80 && b < 80) return 'green';
        if (b > 180 && r < 80 && g < 80) return 'blue';
        if (r < 25 && g < 25 && b < 25) return 'black';
        return '$r/$g/$b';
      } finally {
        image.dispose();
      }
    }

    void navigate(bool next) {
      final box = boundaryKey.currentContext!.findRenderObject()! as RenderBox;
      final origin = box.localToGlobal(box.size.center(Offset.zero));
      GestureBinding.instance.handlePointerEvent(
        PointerScrollEvent(
          position: origin,
          scrollDelta: Offset(0, next ? 80 : -80),
        ),
      );
    }

    Future<void> check(String label) async {
      int? id;
      var pixel = '';
      var before = Duration.zero, after = Duration.zero;
      // 正常样本 4 秒内应稳定显示；损坏样本给 20 秒，等待跳过或出错提示。
      for (var attempt = 0; attempt < 20; attempt++) {
        await feed.settled.timeout(
          const Duration(seconds: 40),
          onTimeout: () => throw StateError('$label 操作队列卡住'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (feed.error != null) {
          // 出错提示可见即可，模拟点击跳过。
          await feed.next();
          continue;
        }
        id = feed.displayedMediaId;
        pixel = await sample().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw StateError('$label 截图卡住'),
        );
        before = feed.player?.position ?? Duration.zero;
        await Future<void>.delayed(const Duration(milliseconds: 400));
        after = feed.player?.position ?? Duration.zero;
        final stable = !feed.busy && feed.displayedMediaId == id;
        final bad = colorOf[id] == 'bad';
        if (stable && id != null && after != before) {
          if (bad || pixel == colorOf[id]) return;
        }
        if (!bad && attempt >= 3 && stable) break;
      }
      throw StateError(
        '$label 停住：pixel=$pixel expect=${colorOf[id]} id=$id '
        'current=${feed.currentMediaId} busy=${feed.busy} '
        'playing=${feed.isPlaying} pos=$before->$after '
        'error=${feed.error}',
      );
    }

    await check('初始');
    const rounds = int.fromEnvironment('ROUNDS', defaultValue: 120);
    for (var i = 0; i < rounds; i++) {
      // 部分媒体保存接近结尾的进度，交接后立即结束。
      if (random.nextInt(4) == 0) {
        final ids = colorOf.keys.toList();
        await db.stateDao.updatePosition(
          ids[random.nextInt(ids.length)],
          2600 + random.nextInt(500),
        );
      }
      navigate(random.nextInt(5) != 0);
      await Future<void>.delayed(
        Duration(
          milliseconds: random.nextInt(4) == 0 ? 2600 : random.nextInt(450),
        ),
      );
      if (i % 6 == 5) {
        await check('第 $i 次');
        debugPrint('STRESS $i PASS');
      }
    }
    debugPrint('STRESS PASS');
  } catch (error, stack) {
    exitCode = 1;
    debugPrint('STRESS FAIL $error\n$stack');
  } finally {
    await feed.close();
    sources.dispose();
    settings.dispose();
    await db.close();
    await directory.delete(recursive: true);
  }
  exit(exitCode);
}
