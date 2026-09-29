// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SourcesTable extends Sources with TableInfo<$SourcesTable, SourceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  @override
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastKnownPathMeta = const VerificationMeta(
    'lastKnownPath',
  );
  @override
  late final GeneratedColumn<String> lastKnownPath = GeneratedColumn<String>(
    'last_known_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeIdentityMeta = const VerificationMeta(
    'volumeIdentity',
  );
  @override
  late final GeneratedColumn<String> volumeIdentity = GeneratedColumn<String>(
    'volume_identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _recursiveMeta = const VerificationMeta(
    'recursive',
  );
  @override
  late final GeneratedColumn<bool> recursive = GeneratedColumn<bool>(
    'recursive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recursive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastScanAtMeta = const VerificationMeta(
    'lastScanAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastScanAt = GeneratedColumn<DateTime>(
    'last_scan_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    locator,
    lastKnownPath,
    platform,
    volumeIdentity,
    enabled,
    recursive,
    lastScanAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorMeta);
    }
    if (data.containsKey('last_known_path')) {
      context.handle(
        _lastKnownPathMeta,
        lastKnownPath.isAcceptableOrUnknown(
          data['last_known_path']!,
          _lastKnownPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastKnownPathMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('volume_identity')) {
      context.handle(
        _volumeIdentityMeta,
        volumeIdentity.isAcceptableOrUnknown(
          data['volume_identity']!,
          _volumeIdentityMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('recursive')) {
      context.handle(
        _recursiveMeta,
        recursive.isAcceptableOrUnknown(data['recursive']!, _recursiveMeta),
      );
    }
    if (data.containsKey('last_scan_at')) {
      context.handle(
        _lastScanAtMeta,
        lastScanAt.isAcceptableOrUnknown(
          data['last_scan_at']!,
          _lastScanAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      )!,
      lastKnownPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_known_path'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      volumeIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_identity'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      recursive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recursive'],
      )!,
      lastScanAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_scan_at'],
      ),
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class SourceEntry extends DataClass implements Insertable<SourceEntry> {
  final int id;
  final String name;
  final String locator;
  final String lastKnownPath;
  final String platform;
  final String? volumeIdentity;
  final bool enabled;
  final bool recursive;
  final DateTime? lastScanAt;
  const SourceEntry({
    required this.id,
    required this.name,
    required this.locator,
    required this.lastKnownPath,
    required this.platform,
    this.volumeIdentity,
    required this.enabled,
    required this.recursive,
    this.lastScanAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['locator'] = Variable<String>(locator);
    map['last_known_path'] = Variable<String>(lastKnownPath);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || volumeIdentity != null) {
      map['volume_identity'] = Variable<String>(volumeIdentity);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['recursive'] = Variable<bool>(recursive);
    if (!nullToAbsent || lastScanAt != null) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt);
    }
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      name: Value(name),
      locator: Value(locator),
      lastKnownPath: Value(lastKnownPath),
      platform: Value(platform),
      volumeIdentity: volumeIdentity == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeIdentity),
      enabled: Value(enabled),
      recursive: Value(recursive),
      lastScanAt: lastScanAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanAt),
    );
  }

  factory SourceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      locator: serializer.fromJson<String>(json['locator']),
      lastKnownPath: serializer.fromJson<String>(json['lastKnownPath']),
      platform: serializer.fromJson<String>(json['platform']),
      volumeIdentity: serializer.fromJson<String?>(json['volumeIdentity']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      recursive: serializer.fromJson<bool>(json['recursive']),
      lastScanAt: serializer.fromJson<DateTime?>(json['lastScanAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'locator': serializer.toJson<String>(locator),
      'lastKnownPath': serializer.toJson<String>(lastKnownPath),
      'platform': serializer.toJson<String>(platform),
      'volumeIdentity': serializer.toJson<String?>(volumeIdentity),
      'enabled': serializer.toJson<bool>(enabled),
      'recursive': serializer.toJson<bool>(recursive),
      'lastScanAt': serializer.toJson<DateTime?>(lastScanAt),
    };
  }

  SourceEntry copyWith({
    int? id,
    String? name,
    String? locator,
    String? lastKnownPath,
    String? platform,
    Value<String?> volumeIdentity = const Value.absent(),
    bool? enabled,
    bool? recursive,
    Value<DateTime?> lastScanAt = const Value.absent(),
  }) => SourceEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    locator: locator ?? this.locator,
    lastKnownPath: lastKnownPath ?? this.lastKnownPath,
    platform: platform ?? this.platform,
    volumeIdentity: volumeIdentity.present
        ? volumeIdentity.value
        : this.volumeIdentity,
    enabled: enabled ?? this.enabled,
    recursive: recursive ?? this.recursive,
    lastScanAt: lastScanAt.present ? lastScanAt.value : this.lastScanAt,
  );
  SourceEntry copyWithCompanion(SourcesCompanion data) {
    return SourceEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      locator: data.locator.present ? data.locator.value : this.locator,
      lastKnownPath: data.lastKnownPath.present
          ? data.lastKnownPath.value
          : this.lastKnownPath,
      platform: data.platform.present ? data.platform.value : this.platform,
      volumeIdentity: data.volumeIdentity.present
          ? data.volumeIdentity.value
          : this.volumeIdentity,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      recursive: data.recursive.present ? data.recursive.value : this.recursive,
      lastScanAt: data.lastScanAt.present
          ? data.lastScanAt.value
          : this.lastScanAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('locator: $locator, ')
          ..write('lastKnownPath: $lastKnownPath, ')
          ..write('platform: $platform, ')
          ..write('volumeIdentity: $volumeIdentity, ')
          ..write('enabled: $enabled, ')
          ..write('recursive: $recursive, ')
          ..write('lastScanAt: $lastScanAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    locator,
    lastKnownPath,
    platform,
    volumeIdentity,
    enabled,
    recursive,
    lastScanAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.locator == this.locator &&
          other.lastKnownPath == this.lastKnownPath &&
          other.platform == this.platform &&
          other.volumeIdentity == this.volumeIdentity &&
          other.enabled == this.enabled &&
          other.recursive == this.recursive &&
          other.lastScanAt == this.lastScanAt);
}

class SourcesCompanion extends UpdateCompanion<SourceEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> locator;
  final Value<String> lastKnownPath;
  final Value<String> platform;
  final Value<String?> volumeIdentity;
  final Value<bool> enabled;
  final Value<bool> recursive;
  final Value<DateTime?> lastScanAt;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.locator = const Value.absent(),
    this.lastKnownPath = const Value.absent(),
    this.platform = const Value.absent(),
    this.volumeIdentity = const Value.absent(),
    this.enabled = const Value.absent(),
    this.recursive = const Value.absent(),
    this.lastScanAt = const Value.absent(),
  });
  SourcesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String locator,
    required String lastKnownPath,
    required String platform,
    this.volumeIdentity = const Value.absent(),
    this.enabled = const Value.absent(),
    this.recursive = const Value.absent(),
    this.lastScanAt = const Value.absent(),
  }) : name = Value(name),
       locator = Value(locator),
       lastKnownPath = Value(lastKnownPath),
       platform = Value(platform);
  static Insertable<SourceEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? locator,
    Expression<String>? lastKnownPath,
    Expression<String>? platform,
    Expression<String>? volumeIdentity,
    Expression<bool>? enabled,
    Expression<bool>? recursive,
    Expression<DateTime>? lastScanAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (locator != null) 'locator': locator,
      if (lastKnownPath != null) 'last_known_path': lastKnownPath,
      if (platform != null) 'platform': platform,
      if (volumeIdentity != null) 'volume_identity': volumeIdentity,
      if (enabled != null) 'enabled': enabled,
      if (recursive != null) 'recursive': recursive,
      if (lastScanAt != null) 'last_scan_at': lastScanAt,
    });
  }

  SourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? locator,
    Value<String>? lastKnownPath,
    Value<String>? platform,
    Value<String?>? volumeIdentity,
    Value<bool>? enabled,
    Value<bool>? recursive,
    Value<DateTime?>? lastScanAt,
  }) {
    return SourcesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    if (lastKnownPath.present) {
      map['last_known_path'] = Variable<String>(lastKnownPath.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (volumeIdentity.present) {
      map['volume_identity'] = Variable<String>(volumeIdentity.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (recursive.present) {
      map['recursive'] = Variable<bool>(recursive.value);
    }
    if (lastScanAt.present) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('locator: $locator, ')
          ..write('lastKnownPath: $lastKnownPath, ')
          ..write('platform: $platform, ')
          ..write('volumeIdentity: $volumeIdentity, ')
          ..write('enabled: $enabled, ')
          ..write('recursive: $recursive, ')
          ..write('lastScanAt: $lastScanAt')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id)',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    relativePath,
    fileName,
    extension,
    size,
    modifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    } else if (isInserting) {
      context.missing(_extensionMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, relativePath},
  ];
  @override
  MediaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      )!,
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }
}

class MediaEntry extends DataClass implements Insertable<MediaEntry> {
  final int id;
  final int sourceId;
  final String relativePath;
  final String fileName;
  final String extension;
  final int size;
  final DateTime modifiedAt;
  const MediaEntry({
    required this.id,
    required this.sourceId,
    required this.relativePath,
    required this.fileName,
    required this.extension,
    required this.size,
    required this.modifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_id'] = Variable<int>(sourceId);
    map['relative_path'] = Variable<String>(relativePath);
    map['file_name'] = Variable<String>(fileName);
    map['extension'] = Variable<String>(extension);
    map['size'] = Variable<int>(size);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      relativePath: Value(relativePath),
      fileName: Value(fileName),
      extension: Value(extension),
      size: Value(size),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory MediaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaEntry(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      extension: serializer.fromJson<String>(json['extension']),
      size: serializer.fromJson<int>(json['size']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int>(sourceId),
      'relativePath': serializer.toJson<String>(relativePath),
      'fileName': serializer.toJson<String>(fileName),
      'extension': serializer.toJson<String>(extension),
      'size': serializer.toJson<int>(size),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  MediaEntry copyWith({
    int? id,
    int? sourceId,
    String? relativePath,
    String? fileName,
    String? extension,
    int? size,
    DateTime? modifiedAt,
  }) => MediaEntry(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    relativePath: relativePath ?? this.relativePath,
    fileName: fileName ?? this.fileName,
    extension: extension ?? this.extension,
    size: size ?? this.size,
    modifiedAt: modifiedAt ?? this.modifiedAt,
  );
  MediaEntry copyWithCompanion(MediaCompanion data) {
    return MediaEntry(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      extension: data.extension.present ? data.extension.value : this.extension,
      size: data.size.present ? data.size.value : this.size,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaEntry(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileName: $fileName, ')
          ..write('extension: $extension, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    relativePath,
    fileName,
    extension,
    size,
    modifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaEntry &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.relativePath == this.relativePath &&
          other.fileName == this.fileName &&
          other.extension == this.extension &&
          other.size == this.size &&
          other.modifiedAt == this.modifiedAt);
}

class MediaCompanion extends UpdateCompanion<MediaEntry> {
  final Value<int> id;
  final Value<int> sourceId;
  final Value<String> relativePath;
  final Value<String> fileName;
  final Value<String> extension;
  final Value<int> size;
  final Value<DateTime> modifiedAt;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.extension = const Value.absent(),
    this.size = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  });
  MediaCompanion.insert({
    this.id = const Value.absent(),
    required int sourceId,
    required String relativePath,
    required String fileName,
    required String extension,
    required int size,
    required DateTime modifiedAt,
  }) : sourceId = Value(sourceId),
       relativePath = Value(relativePath),
       fileName = Value(fileName),
       extension = Value(extension),
       size = Value(size),
       modifiedAt = Value(modifiedAt);
  static Insertable<MediaEntry> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<String>? relativePath,
    Expression<String>? fileName,
    Expression<String>? extension,
    Expression<int>? size,
    Expression<DateTime>? modifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (relativePath != null) 'relative_path': relativePath,
      if (fileName != null) 'file_name': fileName,
      if (extension != null) 'extension': extension,
      if (size != null) 'size': size,
      if (modifiedAt != null) 'modified_at': modifiedAt,
    });
  }

  MediaCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceId,
    Value<String>? relativePath,
    Value<String>? fileName,
    Value<String>? extension,
    Value<int>? size,
    Value<DateTime>? modifiedAt,
  }) {
    return MediaCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      relativePath: relativePath ?? this.relativePath,
      fileName: fileName ?? this.fileName,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileName: $fileName, ')
          ..write('extension: $extension, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }
}

class $MediaStatesTable extends MediaStates
    with TableInfo<$MediaStatesTable, MediaStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media (id)',
    ),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPositionMeta = const VerificationMeta(
    'lastPosition',
  );
  @override
  late final GeneratedColumn<int> lastPosition = GeneratedColumn<int>(
    'last_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    favorite,
    hidden,
    lastPosition,
    playCount,
    lastPlayedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaStateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('last_position')) {
      context.handle(
        _lastPositionMeta,
        lastPosition.isAcceptableOrUnknown(
          data['last_position']!,
          _lastPositionMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  MediaStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaStateEntry(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_id'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      lastPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
    );
  }

  @override
  $MediaStatesTable createAlias(String alias) {
    return $MediaStatesTable(attachedDatabase, alias);
  }
}

class MediaStateEntry extends DataClass implements Insertable<MediaStateEntry> {
  final int mediaId;
  final bool favorite;
  final bool hidden;
  final int? lastPosition;
  final int playCount;
  final DateTime? lastPlayedAt;
  const MediaStateEntry({
    required this.mediaId,
    required this.favorite,
    required this.hidden,
    this.lastPosition,
    required this.playCount,
    this.lastPlayedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<int>(mediaId);
    map['favorite'] = Variable<bool>(favorite);
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || lastPosition != null) {
      map['last_position'] = Variable<int>(lastPosition);
    }
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    return map;
  }

  MediaStatesCompanion toCompanion(bool nullToAbsent) {
    return MediaStatesCompanion(
      mediaId: Value(mediaId),
      favorite: Value(favorite),
      hidden: Value(hidden),
      lastPosition: lastPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPosition),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
    );
  }

  factory MediaStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaStateEntry(
      mediaId: serializer.fromJson<int>(json['mediaId']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      lastPosition: serializer.fromJson<int?>(json['lastPosition']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<int>(mediaId),
      'favorite': serializer.toJson<bool>(favorite),
      'hidden': serializer.toJson<bool>(hidden),
      'lastPosition': serializer.toJson<int?>(lastPosition),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
    };
  }

  MediaStateEntry copyWith({
    int? mediaId,
    bool? favorite,
    bool? hidden,
    Value<int?> lastPosition = const Value.absent(),
    int? playCount,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
  }) => MediaStateEntry(
    mediaId: mediaId ?? this.mediaId,
    favorite: favorite ?? this.favorite,
    hidden: hidden ?? this.hidden,
    lastPosition: lastPosition.present ? lastPosition.value : this.lastPosition,
    playCount: playCount ?? this.playCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
  );
  MediaStateEntry copyWithCompanion(MediaStatesCompanion data) {
    return MediaStateEntry(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      lastPosition: data.lastPosition.present
          ? data.lastPosition.value
          : this.lastPosition,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaStateEntry(')
          ..write('mediaId: $mediaId, ')
          ..write('favorite: $favorite, ')
          ..write('hidden: $hidden, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    favorite,
    hidden,
    lastPosition,
    playCount,
    lastPlayedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaStateEntry &&
          other.mediaId == this.mediaId &&
          other.favorite == this.favorite &&
          other.hidden == this.hidden &&
          other.lastPosition == this.lastPosition &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt);
}

class MediaStatesCompanion extends UpdateCompanion<MediaStateEntry> {
  final Value<int> mediaId;
  final Value<bool> favorite;
  final Value<bool> hidden;
  final Value<int?> lastPosition;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayedAt;
  const MediaStatesCompanion({
    this.mediaId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.hidden = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
  });
  MediaStatesCompanion.insert({
    this.mediaId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.hidden = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
  });
  static Insertable<MediaStateEntry> custom({
    Expression<int>? mediaId,
    Expression<bool>? favorite,
    Expression<bool>? hidden,
    Expression<int>? lastPosition,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayedAt,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (favorite != null) 'favorite': favorite,
      if (hidden != null) 'hidden': hidden,
      if (lastPosition != null) 'last_position': lastPosition,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
    });
  }

  MediaStatesCompanion copyWith({
    Value<int>? mediaId,
    Value<bool>? favorite,
    Value<bool>? hidden,
    Value<int?>? lastPosition,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayedAt,
  }) {
    return MediaStatesCompanion(
      mediaId: mediaId ?? this.mediaId,
      favorite: favorite ?? this.favorite,
      hidden: hidden ?? this.hidden,
      lastPosition: lastPosition ?? this.lastPosition,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (lastPosition.present) {
      map['last_position'] = Variable<int>(lastPosition.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaStatesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('favorite: $favorite, ')
          ..write('hidden: $hidden, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }
}

class $HiddenRulesTable extends HiddenRules
    with TableInfo<$HiddenRulesTable, HiddenRuleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id)',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recursiveMeta = const VerificationMeta(
    'recursive',
  );
  @override
  late final GeneratedColumn<bool> recursive = GeneratedColumn<bool>(
    'recursive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recursive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, sourceId, relativePath, recursive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<HiddenRuleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('recursive')) {
      context.handle(
        _recursiveMeta,
        recursive.isAcceptableOrUnknown(data['recursive']!, _recursiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HiddenRuleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenRuleEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      recursive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recursive'],
      )!,
    );
  }

  @override
  $HiddenRulesTable createAlias(String alias) {
    return $HiddenRulesTable(attachedDatabase, alias);
  }
}

class HiddenRuleEntry extends DataClass implements Insertable<HiddenRuleEntry> {
  final int id;
  final int sourceId;
  final String relativePath;
  final bool recursive;
  const HiddenRuleEntry({
    required this.id,
    required this.sourceId,
    required this.relativePath,
    required this.recursive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_id'] = Variable<int>(sourceId);
    map['relative_path'] = Variable<String>(relativePath);
    map['recursive'] = Variable<bool>(recursive);
    return map;
  }

  HiddenRulesCompanion toCompanion(bool nullToAbsent) {
    return HiddenRulesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      relativePath: Value(relativePath),
      recursive: Value(recursive),
    );
  }

  factory HiddenRuleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenRuleEntry(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      recursive: serializer.fromJson<bool>(json['recursive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int>(sourceId),
      'relativePath': serializer.toJson<String>(relativePath),
      'recursive': serializer.toJson<bool>(recursive),
    };
  }

  HiddenRuleEntry copyWith({
    int? id,
    int? sourceId,
    String? relativePath,
    bool? recursive,
  }) => HiddenRuleEntry(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    relativePath: relativePath ?? this.relativePath,
    recursive: recursive ?? this.recursive,
  );
  HiddenRuleEntry copyWithCompanion(HiddenRulesCompanion data) {
    return HiddenRuleEntry(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      recursive: data.recursive.present ? data.recursive.value : this.recursive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HiddenRuleEntry(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('relativePath: $relativePath, ')
          ..write('recursive: $recursive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceId, relativePath, recursive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HiddenRuleEntry &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.relativePath == this.relativePath &&
          other.recursive == this.recursive);
}

class HiddenRulesCompanion extends UpdateCompanion<HiddenRuleEntry> {
  final Value<int> id;
  final Value<int> sourceId;
  final Value<String> relativePath;
  final Value<bool> recursive;
  const HiddenRulesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.recursive = const Value.absent(),
  });
  HiddenRulesCompanion.insert({
    this.id = const Value.absent(),
    required int sourceId,
    required String relativePath,
    this.recursive = const Value.absent(),
  }) : sourceId = Value(sourceId),
       relativePath = Value(relativePath);
  static Insertable<HiddenRuleEntry> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<String>? relativePath,
    Expression<bool>? recursive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (relativePath != null) 'relative_path': relativePath,
      if (recursive != null) 'recursive': recursive,
    });
  }

  HiddenRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceId,
    Value<String>? relativePath,
    Value<bool>? recursive,
  }) {
    return HiddenRulesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      relativePath: relativePath ?? this.relativePath,
      recursive: recursive ?? this.recursive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (recursive.present) {
      map['recursive'] = Variable<bool>(recursive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenRulesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('relativePath: $relativePath, ')
          ..write('recursive: $recursive')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queueMeta = const VerificationMeta('queue');
  @override
  late final GeneratedColumn<String> queue = GeneratedColumn<String>(
    'queue',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousMediaIdMeta = const VerificationMeta(
    'previousMediaId',
  );
  @override
  late final GeneratedColumn<int> previousMediaId = GeneratedColumn<int>(
    'previous_media_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    queue,
    currentIndex,
    previousMediaId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('queue')) {
      context.handle(
        _queueMeta,
        queue.isAcceptableOrUnknown(data['queue']!, _queueMeta),
      );
    } else if (isInserting) {
      context.missing(_queueMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentIndexMeta);
    }
    if (data.containsKey('previous_media_id')) {
      context.handle(
        _previousMediaIdMeta,
        previousMediaId.isAcceptableOrUnknown(
          data['previous_media_id']!,
          _previousMediaIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      queue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      previousMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_media_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionEntry extends DataClass implements Insertable<SessionEntry> {
  final int id;
  final String scope;
  final String queue;
  final int currentIndex;
  final int? previousMediaId;
  final DateTime createdAt;
  const SessionEntry({
    required this.id,
    required this.scope,
    required this.queue,
    required this.currentIndex,
    this.previousMediaId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope'] = Variable<String>(scope);
    map['queue'] = Variable<String>(queue);
    map['current_index'] = Variable<int>(currentIndex);
    if (!nullToAbsent || previousMediaId != null) {
      map['previous_media_id'] = Variable<int>(previousMediaId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      scope: Value(scope),
      queue: Value(queue),
      currentIndex: Value(currentIndex),
      previousMediaId: previousMediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousMediaId),
      createdAt: Value(createdAt),
    );
  }

  factory SessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEntry(
      id: serializer.fromJson<int>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      queue: serializer.fromJson<String>(json['queue']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      previousMediaId: serializer.fromJson<int?>(json['previousMediaId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scope': serializer.toJson<String>(scope),
      'queue': serializer.toJson<String>(queue),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'previousMediaId': serializer.toJson<int?>(previousMediaId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionEntry copyWith({
    int? id,
    String? scope,
    String? queue,
    int? currentIndex,
    Value<int?> previousMediaId = const Value.absent(),
    DateTime? createdAt,
  }) => SessionEntry(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    queue: queue ?? this.queue,
    currentIndex: currentIndex ?? this.currentIndex,
    previousMediaId: previousMediaId.present
        ? previousMediaId.value
        : this.previousMediaId,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionEntry copyWithCompanion(SessionsCompanion data) {
    return SessionEntry(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      queue: data.queue.present ? data.queue.value : this.queue,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      previousMediaId: data.previousMediaId.present
          ? data.previousMediaId.value
          : this.previousMediaId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntry(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('queue: $queue, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('previousMediaId: $previousMediaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scope, queue, currentIndex, previousMediaId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEntry &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.queue == this.queue &&
          other.currentIndex == this.currentIndex &&
          other.previousMediaId == this.previousMediaId &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<SessionEntry> {
  final Value<int> id;
  final Value<String> scope;
  final Value<String> queue;
  final Value<int> currentIndex;
  final Value<int?> previousMediaId;
  final Value<DateTime> createdAt;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.queue = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.previousMediaId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String scope,
    required String queue,
    required int currentIndex,
    this.previousMediaId = const Value.absent(),
    required DateTime createdAt,
  }) : scope = Value(scope),
       queue = Value(queue),
       currentIndex = Value(currentIndex),
       createdAt = Value(createdAt);
  static Insertable<SessionEntry> custom({
    Expression<int>? id,
    Expression<String>? scope,
    Expression<String>? queue,
    Expression<int>? currentIndex,
    Expression<int>? previousMediaId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (queue != null) 'queue': queue,
      if (currentIndex != null) 'current_index': currentIndex,
      if (previousMediaId != null) 'previous_media_id': previousMediaId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? scope,
    Value<String>? queue,
    Value<int>? currentIndex,
    Value<int?>? previousMediaId,
    Value<DateTime>? createdAt,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      previousMediaId: previousMediaId ?? this.previousMediaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (queue.present) {
      map['queue'] = Variable<String>(queue.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (previousMediaId.present) {
      map['previous_media_id'] = Variable<int>(previousMediaId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('queue: $queue, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('previousMediaId: $previousMediaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $MediaTable media = $MediaTable(this);
  late final $MediaStatesTable mediaStates = $MediaStatesTable(this);
  late final $HiddenRulesTable hiddenRules = $HiddenRulesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final SourceDao sourceDao = SourceDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  late final StateDao stateDao = StateDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sources,
    media,
    mediaStates,
    hiddenRules,
    sessions,
  ];
}

typedef $$SourcesTableCreateCompanionBuilder = SourcesCompanion Function({
  Value<int> id,
  required String name,
  required String locator,
  required String lastKnownPath,
  required String platform,
  Value<String?> volumeIdentity,
  Value<bool> enabled,
  Value<bool> recursive,
  Value<DateTime?> lastScanAt,
});
typedef $$SourcesTableUpdateCompanionBuilder = SourcesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> locator,
  Value<String> lastKnownPath,
  Value<String> platform,
  Value<String?> volumeIdentity,
  Value<bool> enabled,
  Value<bool> recursive,
  Value<DateTime?> lastScanAt,
});

final class $$SourcesTableReferences
    extends BaseReferences<_$AppDatabase, $SourcesTable, SourceEntry> {
  $$SourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MediaTable, List<MediaEntry>> _mediaRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.media,
    aliasName: 'sources__id__media__source_id',
  );

  $$MediaTableProcessedTableManager get mediaRefs {
    final manager = $$MediaTableTableManager(
      $_db,
      $_db.media,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HiddenRulesTable, List<HiddenRuleEntry>>
  _hiddenRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hiddenRules,
    aliasName: 'sources__id__hidden_rules__source_id',
  );

  $$HiddenRulesTableProcessedTableManager get hiddenRulesRefs {
    final manager = $$HiddenRulesTableTableManager(
      $_db,
      $_db.hiddenRules,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hiddenRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastKnownPath => $composableBuilder(
    column: $table.lastKnownPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeIdentity => $composableBuilder(
    column: $table.volumeIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mediaRefs(
    Expression<bool> Function($$MediaTableFilterComposer f) f,
  ) {
    final $$MediaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaTableFilterComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> hiddenRulesRefs(
    Expression<bool> Function($$HiddenRulesTableFilterComposer f) f,
  ) {
    final $$HiddenRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hiddenRules,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HiddenRulesTableFilterComposer(
            $db: $db,
            $table: $db.hiddenRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastKnownPath => $composableBuilder(
    column: $table.lastKnownPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeIdentity => $composableBuilder(
    column: $table.volumeIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  GeneratedColumn<String> get lastKnownPath => $composableBuilder(
    column: $table.lastKnownPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get volumeIdentity => $composableBuilder(
    column: $table.volumeIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get recursive =>
      $composableBuilder(column: $table.recursive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastScanAt => $composableBuilder(
    column: $table.lastScanAt,
    builder: (column) => column,
  );

  Expression<T> mediaRefs<T extends Object>(
    Expression<T> Function($$MediaTableAnnotationComposer a) f,
  ) {
    final $$MediaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaTableAnnotationComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> hiddenRulesRefs<T extends Object>(
    Expression<T> Function($$HiddenRulesTableAnnotationComposer a) f,
  ) {
    final $$HiddenRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hiddenRules,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HiddenRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.hiddenRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcesTable,
          SourceEntry,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (SourceEntry, $$SourcesTableReferences),
          SourceEntry,
          PrefetchHooks Function({bool mediaRefs, bool hiddenRulesRefs})
        > {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> locator = const Value.absent(),
                Value<String> lastKnownPath = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> volumeIdentity = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> recursive = const Value.absent(),
                Value<DateTime?> lastScanAt = const Value.absent(),
              }) => SourcesCompanion(
                id: id,
                name: name,
                locator: locator,
                lastKnownPath: lastKnownPath,
                platform: platform,
                volumeIdentity: volumeIdentity,
                enabled: enabled,
                recursive: recursive,
                lastScanAt: lastScanAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String locator,
                required String lastKnownPath,
                required String platform,
                Value<String?> volumeIdentity = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> recursive = const Value.absent(),
                Value<DateTime?> lastScanAt = const Value.absent(),
              }) => SourcesCompanion.insert(
                id: id,
                name: name,
                locator: locator,
                lastKnownPath: lastKnownPath,
                platform: platform,
                volumeIdentity: volumeIdentity,
                enabled: enabled,
                recursive: recursive,
                lastScanAt: lastScanAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourcesTable, SourceEntry>(table),
                  $$SourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mediaRefs = false, hiddenRulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mediaRefs) db.media,
                    if (hiddenRulesRefs) db.hiddenRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mediaRefs)
                        await $_getPrefetchedData<
                          SourceEntry,
                          $SourcesTable,
                          MediaEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._mediaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(db, table, p0).mediaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (hiddenRulesRefs)
                        await $_getPrefetchedData<
                          SourceEntry,
                          $SourcesTable,
                          HiddenRuleEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._hiddenRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).hiddenRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcesTable,
      SourceEntry,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (SourceEntry, $$SourcesTableReferences),
      SourceEntry,
      PrefetchHooks Function({bool mediaRefs, bool hiddenRulesRefs})
    >;
typedef $$MediaTableCreateCompanionBuilder = MediaCompanion Function({
  Value<int> id,
  required int sourceId,
  required String relativePath,
  required String fileName,
  required String extension,
  required int size,
  required DateTime modifiedAt,
});
typedef $$MediaTableUpdateCompanionBuilder = MediaCompanion Function({
  Value<int> id,
  Value<int> sourceId,
  Value<String> relativePath,
  Value<String> fileName,
  Value<String> extension,
  Value<int> size,
  Value<DateTime> modifiedAt,
});

final class $$MediaTableReferences
    extends BaseReferences<_$AppDatabase, $MediaTable, MediaEntry> {
  $$MediaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('media__source_id__sources__id');

  $$SourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MediaStatesTable, List<MediaStateEntry>>
  _mediaStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaStates,
    aliasName: 'media__id__media_states__media_id',
  );

  $$MediaStatesTableProcessedTableManager get mediaStatesRefs {
    final manager = $$MediaStatesTableTableManager(
      $_db,
      $_db.mediaStates,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> mediaStatesRefs(
    Expression<bool> Function($$MediaStatesTableFilterComposer f) f,
  ) {
    final $$MediaStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaStates,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaStatesTableFilterComposer(
            $db: $db,
            $table: $db.mediaStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> mediaStatesRefs<T extends Object>(
    Expression<T> Function($$MediaStatesTableAnnotationComposer a) f,
  ) {
    final $$MediaStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaStates,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaTable,
          MediaEntry,
          $$MediaTableFilterComposer,
          $$MediaTableOrderingComposer,
          $$MediaTableAnnotationComposer,
          $$MediaTableCreateCompanionBuilder,
          $$MediaTableUpdateCompanionBuilder,
          (MediaEntry, $$MediaTableReferences),
          MediaEntry,
          PrefetchHooks Function({bool sourceId, bool mediaStatesRefs})
        > {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
              }) => MediaCompanion(
                id: id,
                sourceId: sourceId,
                relativePath: relativePath,
                fileName: fileName,
                extension: extension,
                size: size,
                modifiedAt: modifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceId,
                required String relativePath,
                required String fileName,
                required String extension,
                required int size,
                required DateTime modifiedAt,
              }) => MediaCompanion.insert(
                id: id,
                sourceId: sourceId,
                relativePath: relativePath,
                fileName: fileName,
                extension: extension,
                size: size,
                modifiedAt: modifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaTable, MediaEntry>(table),
                  $$MediaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false, mediaStatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mediaStatesRefs) db.mediaStates],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$MediaTableReferences._sourceIdTable(
                          db,
                        ),
                        referencedColumn: $$MediaTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaStatesRefs)
                    await $_getPrefetchedData<
                      MediaEntry,
                      $MediaTable,
                      MediaStateEntry
                    >(
                      currentTable: table,
                      referencedTable: $$MediaTableReferences
                          ._mediaStatesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MediaTableReferences(db, table, p0).mediaStatesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mediaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaTable,
      MediaEntry,
      $$MediaTableFilterComposer,
      $$MediaTableOrderingComposer,
      $$MediaTableAnnotationComposer,
      $$MediaTableCreateCompanionBuilder,
      $$MediaTableUpdateCompanionBuilder,
      (MediaEntry, $$MediaTableReferences),
      MediaEntry,
      PrefetchHooks Function({bool sourceId, bool mediaStatesRefs})
    >;
typedef $$MediaStatesTableCreateCompanionBuilder =
    MediaStatesCompanion Function({
      Value<int> mediaId,
      Value<bool> favorite,
      Value<bool> hidden,
      Value<int?> lastPosition,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
    });
typedef $$MediaStatesTableUpdateCompanionBuilder =
    MediaStatesCompanion Function({
      Value<int> mediaId,
      Value<bool> favorite,
      Value<bool> hidden,
      Value<int?> lastPosition,
      Value<int> playCount,
      Value<DateTime?> lastPlayedAt,
    });

final class $$MediaStatesTableReferences
    extends BaseReferences<_$AppDatabase, $MediaStatesTable, MediaStateEntry> {
  $$MediaStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaTable _mediaIdTable(_$AppDatabase db) =>
      db.media.createAlias('media_states__media_id__media__id');

  $$MediaTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<int>('media_id')!;

    final manager = $$MediaTableTableManager(
      $_db,
      $_db.media,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaStatesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaStatesTable> {
  $$MediaStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaTableFilterComposer get mediaId {
    final $$MediaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaTableFilterComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaStatesTable> {
  $$MediaStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaTableOrderingComposer get mediaId {
    final $$MediaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaTableOrderingComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaStatesTable> {
  $$MediaStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  $$MediaTableAnnotationComposer get mediaId {
    final $$MediaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaTableAnnotationComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaStatesTable,
          MediaStateEntry,
          $$MediaStatesTableFilterComposer,
          $$MediaStatesTableOrderingComposer,
          $$MediaStatesTableAnnotationComposer,
          $$MediaStatesTableCreateCompanionBuilder,
          $$MediaStatesTableUpdateCompanionBuilder,
          (MediaStateEntry, $$MediaStatesTableReferences),
          MediaStateEntry,
          PrefetchHooks Function({bool mediaId})
        > {
  $$MediaStatesTableTableManager(_$AppDatabase db, $MediaStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> mediaId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> lastPosition = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
              }) => MediaStatesCompanion(
                mediaId: mediaId,
                favorite: favorite,
                hidden: hidden,
                lastPosition: lastPosition,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> mediaId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> lastPosition = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
              }) => MediaStatesCompanion.insert(
                mediaId: mediaId,
                favorite: favorite,
                hidden: hidden,
                lastPosition: lastPosition,
                playCount: playCount,
                lastPlayedAt: lastPlayedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaStatesTable, MediaStateEntry>(table),
                  $$MediaStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.mediaId,
                        referencedTable: $$MediaStatesTableReferences
                            ._mediaIdTable(db),
                        referencedColumn: $$MediaStatesTableReferences
                            ._mediaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaStatesTable,
      MediaStateEntry,
      $$MediaStatesTableFilterComposer,
      $$MediaStatesTableOrderingComposer,
      $$MediaStatesTableAnnotationComposer,
      $$MediaStatesTableCreateCompanionBuilder,
      $$MediaStatesTableUpdateCompanionBuilder,
      (MediaStateEntry, $$MediaStatesTableReferences),
      MediaStateEntry,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$HiddenRulesTableCreateCompanionBuilder =
    HiddenRulesCompanion Function({
      Value<int> id,
      required int sourceId,
      required String relativePath,
      Value<bool> recursive,
    });
typedef $$HiddenRulesTableUpdateCompanionBuilder =
    HiddenRulesCompanion Function({
      Value<int> id,
      Value<int> sourceId,
      Value<String> relativePath,
      Value<bool> recursive,
    });

final class $$HiddenRulesTableReferences
    extends BaseReferences<_$AppDatabase, $HiddenRulesTable, HiddenRuleEntry> {
  $$HiddenRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('hidden_rules__source_id__sources__id');

  $$SourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HiddenRulesTableFilterComposer
    extends Composer<_$AppDatabase, $HiddenRulesTable> {
  $$HiddenRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnFilters(column),
  );

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HiddenRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $HiddenRulesTable> {
  $$HiddenRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HiddenRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HiddenRulesTable> {
  $$HiddenRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get recursive =>
      $composableBuilder(column: $table.recursive, builder: (column) => column);

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HiddenRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HiddenRulesTable,
          HiddenRuleEntry,
          $$HiddenRulesTableFilterComposer,
          $$HiddenRulesTableOrderingComposer,
          $$HiddenRulesTableAnnotationComposer,
          $$HiddenRulesTableCreateCompanionBuilder,
          $$HiddenRulesTableUpdateCompanionBuilder,
          (HiddenRuleEntry, $$HiddenRulesTableReferences),
          HiddenRuleEntry,
          PrefetchHooks Function({bool sourceId})
        > {
  $$HiddenRulesTableTableManager(_$AppDatabase db, $HiddenRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HiddenRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HiddenRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HiddenRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<bool> recursive = const Value.absent(),
              }) => HiddenRulesCompanion(
                id: id,
                sourceId: sourceId,
                relativePath: relativePath,
                recursive: recursive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceId,
                required String relativePath,
                Value<bool> recursive = const Value.absent(),
              }) => HiddenRulesCompanion.insert(
                id: id,
                sourceId: sourceId,
                relativePath: relativePath,
                recursive: recursive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HiddenRulesTable, HiddenRuleEntry>(table),
                  $$HiddenRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$HiddenRulesTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$HiddenRulesTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HiddenRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HiddenRulesTable,
      HiddenRuleEntry,
      $$HiddenRulesTableFilterComposer,
      $$HiddenRulesTableOrderingComposer,
      $$HiddenRulesTableAnnotationComposer,
      $$HiddenRulesTableCreateCompanionBuilder,
      $$HiddenRulesTableUpdateCompanionBuilder,
      (HiddenRuleEntry, $$HiddenRulesTableReferences),
      HiddenRuleEntry,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String scope,
  required String queue,
  required int currentIndex,
  Value<int?> previousMediaId,
  required DateTime createdAt,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> scope,
  Value<String> queue,
  Value<int> currentIndex,
  Value<int?> previousMediaId,
  Value<DateTime> createdAt,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queue => $composableBuilder(
    column: $table.queue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousMediaId => $composableBuilder(
    column: $table.previousMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queue => $composableBuilder(
    column: $table.queue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousMediaId => $composableBuilder(
    column: $table.previousMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get queue =>
      $composableBuilder(column: $table.queue, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previousMediaId => $composableBuilder(
    column: $table.previousMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionEntry,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            SessionEntry,
            BaseReferences<_$AppDatabase, $SessionsTable, SessionEntry>,
          ),
          SessionEntry,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> queue = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int?> previousMediaId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                scope: scope,
                queue: queue,
                currentIndex: currentIndex,
                previousMediaId: previousMediaId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scope,
                required String queue,
                required int currentIndex,
                Value<int?> previousMediaId = const Value.absent(),
                required DateTime createdAt,
              }) => SessionsCompanion.insert(
                id: id,
                scope: scope,
                queue: queue,
                currentIndex: currentIndex,
                previousMediaId: previousMediaId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionEntry>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, SessionEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionEntry,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (
        SessionEntry,
        BaseReferences<_$AppDatabase, $SessionsTable, SessionEntry>,
      ),
      SessionEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$MediaStatesTableTableManager get mediaStates =>
      $$MediaStatesTableTableManager(_db, _db.mediaStates);
  $$HiddenRulesTableTableManager get hiddenRules =>
      $$HiddenRulesTableTableManager(_db, _db.hiddenRules);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
