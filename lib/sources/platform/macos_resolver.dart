import 'default_resolver.dart';
import '../source.dart';

/// MacOS-specific implementation of [SourceResolver].
///
/// Currently falls back to [DefaultResolver] behavior.
/// TODO: Implement Security Scoped Bookmarks for sandboxed macOS app access.
class MacOSResolver extends DefaultResolver {
  @override
  Future<String?> resolveFullPath(Source source, String relativePath) async {
    // TODO: Use security scoped bookmark to resolve the path if sandboxing is enabled.
    return super.resolveFullPath(source, relativePath);
  }

  @override
  Future<bool> checkAvailability(Source source) async {
    // TODO: Verify security scoped bookmark availability.
    return super.checkAvailability(source);
  }
}
