import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/sources/scanner.dart';
import 'package:path/path.dart' as p;

void main() {
  group('SourceScanner', () {
    late Directory tempDir;
    late SourceScanner scanner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('scanner_test');
      scanner = SourceScanner();
      
      // Create some test files
      await File(p.join(tempDir.path, 'video1.mp4')).create();
      await File(p.join(tempDir.path, 'document.txt')).create();
      
      final subDir = await Directory(p.join(tempDir.path, 'subdir')).create();
      await File(p.join(subDir.path, 'video2.mkv')).create();
      await File(p.join(subDir.path, 'image.jpg')).create();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('finds supported video files recursively', () async {
      final results = await scanner.scan(tempDir.path, recursive: true);
      
      expect(results.length, 2);
      expect(results, contains('video1.mp4'));
      expect(results, contains(p.join('subdir', 'video2.mkv')));
    });

    test('finds supported video files non-recursively', () async {
      final results = await scanner.scan(tempDir.path, recursive: false);
      
      expect(results.length, 1);
      expect(results, contains('video1.mp4'));
    });
    
    test('returns empty list for non-existent directory', () async {
      final nonExistentPath = p.join(tempDir.path, 'does_not_exist');
      final results = await scanner.scan(nonExistentPath);
      
      expect(results, isEmpty);
    });
  });
}
