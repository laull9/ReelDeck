import 'dart:io';

import 'package:path/path.dart' as p;

/// Scans source directories for playable media files.
class SourceScanner {
  /// File extensions recognized as supported video formats.
  static const Set<String> supportedExtensions = {
    'mp4',
    'mkv',
    'mov',
    'm4v',
    'webm',
    'avi',
    'mpg',
    'mpeg',
    'ts',
    'm2ts',
    'flv',
    'wmv',
  };

  /// Scans the directory at [rootPath] for files matching [supportedExtensions].
  ///
  /// Uses [Directory.list] to traverse files (recursively if [recursive] is true).
  /// Returns a list of relative paths relative to [rootPath].
  Future<List<String>> scan(String rootPath, {bool recursive = true}) async {
    final dir = Directory(rootPath);
    if (!await dir.exists()) {
      return [];
    }

    final relativePaths = <String>[];
    await for (final entity in dir.list(
      recursive: recursive,
      followLinks: false,
    )) {
      if (entity is File) {
        final ext = p
            .extension(entity.path)
            .toLowerCase()
            .replaceFirst('.', '');
        if (supportedExtensions.contains(ext)) {
          relativePaths.add(p.relative(entity.path, from: rootPath));
        }
      }
    }

    return relativePaths;
  }
}
