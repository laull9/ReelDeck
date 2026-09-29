import 'dart:io';
import 'package:path/path.dart' as p;
import '../source.dart';
import '../source_resolver.dart';

/// Default implementation of [SourceResolver] that works on desktop via direct file paths.
class DefaultResolver implements SourceResolver {
  @override
  Future<String?> resolveFullPath(Source source, String relativePath) async {
    final fullPath = p.join(source.lastKnownPath, relativePath);
    return fullPath;
  }

  @override
  Future<bool> checkAvailability(Source source) async {
    return Directory(source.lastKnownPath).exists();
  }
}
