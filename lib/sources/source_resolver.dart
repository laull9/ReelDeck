import 'source.dart';

/// Abstract contract for resolving platform-specific paths and source availability.
abstract class SourceResolver {
  /// Resolves the full filesystem path for [relativePath] within the given [source].
  ///
  /// Returns `null` if the path cannot be resolved or the source is unavailable.
  Future<String?> resolveFullPath(Source source, String relativePath);

  /// Checks whether the given [source] is currently accessible on this system.
  Future<bool> checkAvailability(Source source);
}
