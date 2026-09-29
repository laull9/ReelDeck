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

/// Represents a specific media file within a source.
class Media {
  /// Unique identifier for the media item.
  final int id;

  /// Identifier of the source containing this media.
  final int sourceId;

  /// Path to the media file, relative to the source's root.
  final String relativePath;

  /// Name of the media file, including extension.
  final String fileName;

  /// Extension of the media file, without the leading dot.
  final String extension;

  /// Size of the media file in bytes.
  final int size;

  /// Timestamp of the media file's last modification.
  final DateTime modifiedAt;

  const Media({
    required this.id,
    required this.sourceId,
    required this.relativePath,
    required this.fileName,
    required this.extension,
    required this.size,
    required this.modifiedAt,
  });

  /// Creates a copy of this [Media] with the given fields replaced by new values.
  Media copyWith({
    int? id,
    int? sourceId,
    String? relativePath,
    String? fileName,
    String? extension,
    int? size,
    DateTime? modifiedAt,
  }) {
    return Media(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      relativePath: relativePath ?? this.relativePath,
      fileName: fileName ?? this.fileName,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
