// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_dao.dart';

// ignore_for_file: type=lint
mixin _$SourceDaoMixin on DatabaseAccessor<AppDatabase> {
  $SourcesTable get sources => attachedDatabase.sources;
  SourceDaoManager get managers => SourceDaoManager(this);
}

class SourceDaoManager {
  final _$SourceDaoMixin _db;
  SourceDaoManager(this._db);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db.attachedDatabase, _db.sources);
}
