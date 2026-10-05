import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../database/database.dart';
import '../database/library_store.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings.dart';
import '../sources/source_manager.dart';
import '../feed/feed_controller.dart';
import '../feed/feed_screen.dart';
import '../settings/settings_screen.dart';
import '../shortcuts/shortcuts_screen.dart';
import '../sources/sources_screen.dart';
import 'theme.dart';
import 'routes.dart';

class ReelDeckApp extends StatefulWidget {
  const ReelDeckApp({super.key});
  @override
  State<ReelDeckApp> createState() => _ReelDeckAppState();
}

class _ReelDeckAppState extends State<ReelDeckApp> with WidgetsBindingObserver {
  final db = AppDatabase();
  final settings = AppSettings();
  late final SourceManager sources;
  late final FeedController feed;
  late Future<void> _startup;
  bool _awake = false;
  bool _started = false;
  bool _backgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final store = LibraryStore(db);
    sources = SourceManager(store: store);
    feed = FeedController(
      sourceManager: sources,
      store: store,
      settings: settings,
    );
    feed.addListener(_syncWakelock);
    _startup = _initialize();
  }

  Future<void> _initialize() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    await settings.load(File('${directory.path}/settings.json'));
    sources.recursive = settings.recursiveScan;
    sources.autoRefresh = settings.autoRefreshFolders;
    await sources.initialize();
    await feed.initialize();
    _started = true;
    _refreshFolders();
  }

  /// 先按已有索引开始播放，再在后台重扫；当前视频仍在时不打断播放。
  void _refreshFolders() {
    if (_started && settings.autoRefreshFolders) {
      unawaited(sources.rescanAll(quiet: true));
    }
  }

  void _syncWakelock() {
    if (_awake == feed.isPlaying) return;
    _awake = feed.isPlaying;
    WakelockPlus.toggle(enable: _awake);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      feed.suspend();
    }
    // 只有真正退到后台再回来才算重新打开；桌面失焦不触发重扫。
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _backgrounded = true;
    } else if (state == AppLifecycleState.resumed && _backgrounded) {
      _backgrounded = false;
      _refreshFolders();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    feed.removeListener(_syncWakelock);
    WakelockPlus.disable();
    feed.close().then((_) => db.close());
    sources.dispose();
    settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: sources),
      ChangeNotifierProvider.value(value: feed),
    ],
    child: ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'ReelDeck',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        locale: settings.locale == 'system' ? null : Locale(settings.locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: FutureBuilder<void>(
          future: _startup,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('应用初始化失败'),
                      SelectableText('${snapshot.error}'),
                    ],
                  ),
                ),
              );
            }
            // 原生首帧需要 Texture 已挂载；等待 initialize 时也保留 Feed。
            return AbsorbPointer(
              absorbing: snapshot.connectionState != ConnectionState.done,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const FeedScreen(),
                  if (snapshot.connectionState != ConnectionState.done)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          },
        ),
        routes: {
          AppRoutes.settings: (_) => const SettingsScreen(),
          AppRoutes.sources: (_) => const SourcesScreen(),
          AppRoutes.shortcuts: (_) => const ShortcutsScreen(),
        },
      ),
    ),
  );
}
