// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_dao.dart';

// ignore_for_file: type=lint
mixin _$StateDaoMixin on DatabaseAccessor<AppDatabase> {
  $SourcesTable get sources => attachedDatabase.sources;
  $MediaTable get media => attachedDatabase.media;
  $MediaStatesTable get mediaStates => attachedDatabase.mediaStates;
  StateDaoManager get managers => StateDaoManager(this);
}

class StateDaoManager {
  final _$StateDaoMixin _db;
  StateDaoManager(this._db);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db.attachedDatabase, _db.sources);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db.attachedDatabase, _db.media);
  $$MediaStatesTableTableManager get mediaStates =>
      $$MediaStatesTableTableManager(_db.attachedDatabase, _db.mediaStates);
}
