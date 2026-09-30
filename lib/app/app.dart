import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../database/library_store.dart';
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
    _startup = _initialize();
  }

  Future<void> _initialize() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    await settings.load(File('${directory.path}/settings.json'));
    sources.recursive = settings.recursiveScan;
    await sources.initialize();
    await feed.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      feed.suspend();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    child: MaterialApp(
      title: 'ReelDeck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
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
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const FeedScreen();
        },
      ),
      routes: {
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.sources: (_) => const SourcesScreen(),
        AppRoutes.shortcuts: (_) => const ShortcutsScreen(),
      },
    ),
  );
}
