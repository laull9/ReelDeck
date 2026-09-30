import 'package:drift/drift.dart';

@DataClassName('SourceEntry')
class Sources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get locator => text()();
  TextColumn get lastKnownPath => text()();
  TextColumn get platform => text()();
  TextColumn get volumeIdentity => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get recursive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScanAt => dateTime().nullable()();
}

@DataClassName('MediaEntry')
class Media extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId => integer().references(Sources, #id)();
  TextColumn get relativePath => text()();
  TextColumn get fileName => text()();
  TextColumn get extension => text()();
  IntColumn get size => integer()();
  DateTimeColumn get modifiedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {sourceId, relativePath},
  ];
}

@DataClassName('MediaStateEntry')
class MediaStates extends Table {
  IntColumn get mediaId => integer().references(Media, #id)();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  IntColumn get lastPosition => integer().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {mediaId};
}

@DataClassName('HiddenRuleEntry')
class HiddenRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId => integer().references(Sources, #id)();
  TextColumn get relativePath => text()();
  BoolColumn get recursive => boolean().withDefault(const Constant(true))();
}

@DataClassName('SessionEntry')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get scope => text()();
  TextColumn get queue => text()(); // JSON string
  IntColumn get currentIndex => integer()();
  IntColumn get previousMediaId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
