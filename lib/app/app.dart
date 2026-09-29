import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings.dart';
import '../state/favorites.dart';
import '../state/hidden.dart';
import '../sources/source_manager.dart';
import '../feed/feed_controller.dart';
import '../feed/feed_screen.dart';
import '../settings/settings_screen.dart';
import '../sources/sources_screen.dart';
import 'theme.dart';
import 'routes.dart';

class ReelDeckApp extends StatelessWidget {
  const ReelDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => FavoritesManager()),
        ChangeNotifierProvider(create: (_) => HiddenManager()),
        ChangeNotifierProvider(create: (_) => SourceManager()),
        ChangeNotifierProxyProvider<SourceManager, FeedController>(
          create: (ctx) => FeedController(
            sourceManager: ctx.read<SourceManager>(),
          ),
          update: (ctx, sourceManager, prev) {
            final controller = prev ?? FeedController(sourceManager: sourceManager);
            // If media list changes, sync to controller
            if (sourceManager.allMedia.isNotEmpty &&
                controller.queue.queue.isEmpty) {
              controller.loadMediaList(sourceManager.allMedia);
            }
            return controller;
          },
        ),
      ],
      child: Consumer<AppSettings>(
        builder: (context, settings, _) => MaterialApp(
          title: 'ReelDeck',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          initialRoute: AppRoutes.feed,
          routes: {
            AppRoutes.feed: (context) => const FeedScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.sources: (context) => const SourcesScreen(),
          },
        ),
      ),
    );
  }
}
