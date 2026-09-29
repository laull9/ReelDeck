import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/sources/source_manager.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/scanner.dart';
import 'package:reel_deck/sources/source_resolver.dart';
import 'package:path/path.dart' as p;

class MockScanner implements SourceScanner {
  final List<String> mockPaths;
  MockScanner(this.mockPaths);

  @override
  Future<List<String>> scan(String rootPath, {bool recursive = true}) async {
    return mockPaths;
  }
}

class MockResolver implements SourceResolver {
  bool isAvailable = true;
  
  @override
  Future<String?> resolveFullPath(Source source, String relativePath) async {
    return p.join(source.lastKnownPath, relativePath);
  }
  
  @override
  Future<bool> checkAvailability(Source source) async {
    return isAvailable;
  }
}

void main() {
  group('SourceManager', () {
    late SourceManager manager;
    late MockScanner scanner;
    late MockResolver resolver;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('source_manager_test');
      scanner = MockScanner(['video1.mp4', p.join('subdir', 'video2.mkv')]);
      resolver = MockResolver();
      manager = SourceManager(scanner: scanner, resolver: resolver);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('scanSource updates media list', () async {
      final source = Source(
        id: 1,
        name: 'Test Source',
        locator: tempDir.path,
        lastKnownPath: tempDir.path,
        platform: 'test',
      );

      // Create physical files so size/modified stats work
      await File(p.join(tempDir.path, 'video1.mp4')).create();
      final subDir = await Directory(p.join(tempDir.path, 'subdir')).create();
      await File(p.join(subDir.path, 'video2.mkv')).create();

      // Manager starts empty
      expect(manager.allMedia, isEmpty);
      
      // Inject the source to manager's internal state
      manager.addSource(source);
      expect(manager.sources.length, 1);
      
      await manager.scanSource(source);

      expect(manager.allMedia.length, 2);
      final m1 = manager.allMedia.firstWhere((m) => m.fileName == 'video1.mp4');
      expect(m1.extension, 'mp4');
      expect(m1.relativePath, 'video1.mp4');

      final m2 = manager.allMedia.firstWhere((m) => m.fileName == 'video2.mkv');
      expect(m2.extension, 'mkv');
      expect(m2.relativePath, p.join('subdir', 'video2.mkv'));
      
      // Check lastScanAt is updated
      expect(manager.sources.first.lastScanAt, isNotNull);
    });

    test('removeSource removes source and media', () async {
      final source = Source(
        id: 1,
        name: 'Test Source',
        locator: tempDir.path,
        lastKnownPath: tempDir.path,
        platform: 'test',
      );
      manager.addSource(source);
      
      await File(p.join(tempDir.path, 'video1.mp4')).create();
      await manager.scanSource(source);
      
      expect(manager.sources, isNotEmpty);
      expect(manager.allMedia, isNotEmpty);
      
      manager.removeSource(source.id);
      
      expect(manager.sources, isEmpty);
      expect(manager.allMedia, isEmpty);
    });

    test('toggleSource enables/disables source', () async {
      final source = Source(
        id: 1,
        name: 'Test',
        locator: 'path',
        lastKnownPath: 'path',
        platform: 'test',
        enabled: true,
      );
      manager.addSource(source);
      
      expect(manager.sources.first.enabled, true);
      
      manager.toggleSource(1);
      expect(manager.sources.first.enabled, false);
      
      manager.toggleSource(1);
      expect(manager.sources.first.enabled, true);
    });
  });
}
