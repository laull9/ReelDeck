import 'package:flutter/material.dart';

import '../feed/feed_screen.dart';
import 'theme.dart';

class ReelDeckApp extends StatelessWidget {
  const ReelDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelDeck',
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const FeedScreen(),
    );
  }
}
