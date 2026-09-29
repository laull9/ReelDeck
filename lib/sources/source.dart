/// Represents a user-authorized root video directory or source.
class Source {
  /// Unique identifier for the source.
  final int id;

  /// Human-readable display name for the source.
  final String name;

  /// Platform-specific locator or bookmark.
  final String locator;

  /// Last known filesystem path for the source.
  final String lastKnownPath;

  /// Target platform identifier (e.g. 'macos', 'windows', 'android').
  final String platform;

  /// Unique hardware or volume identity for external drives, if available.
  final String? volumeIdentity;

  /// Whether scanning and playback from this source are enabled.
  final bool enabled;

  /// Whether directories within this source should be scanned recursively.
  final bool recursive;

  /// Timestamp of the most recent completed scan.
  final DateTime? lastScanAt;

  const Source({
    required this.id,
    required this.name,
    required this.locator,
    required this.lastKnownPath,
    required this.platform,
    this.volumeIdentity,
    this.enabled = true,
    this.recursive = true,
    this.lastScanAt,
  });

  /// Creates a copy of this [Source] with the given fields replaced by new values.
  Source copyWith({
    int? id,
    String? name,
    String? locator,
    String? lastKnownPath,
    String? platform,
    String? volumeIdentity,
    bool? enabled,
    bool? recursive,
    DateTime? lastScanAt,
  }) {
    return Source(
      id: id ?? this.id,
      name: name ?? this.name,
      locator: locator ?? this.locator,
      lastKnownPath: lastKnownPath ?? this.lastKnownPath,
      platform: platform ?? this.platform,
      volumeIdentity: volumeIdentity ?? this.volumeIdentity,
      enabled: enabled ?? this.enabled,
      recursive: recursive ?? this.recursive,
      lastScanAt: lastScanAt ?? this.lastScanAt,
    );
  }
}
