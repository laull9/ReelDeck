import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    debugPrint('MediaKit initialization note: $e');
  }
  runApp(const ReelDeckApp());
}
