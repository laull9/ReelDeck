// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dao.dart';

// ignore_for_file: type=lint
mixin _$MediaDaoMixin on DatabaseAccessor<AppDatabase> {
  $SourcesTable get sources => attachedDatabase.sources;
  $MediaTable get media => attachedDatabase.media;
  $MediaStatesTable get mediaStates => attachedDatabase.mediaStates;
  MediaDaoManager get managers => MediaDaoManager(this);
}

class MediaDaoManager {
  final _$MediaDaoMixin _db;
  MediaDaoManager(this._db);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db.attachedDatabase, _db.sources);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db.attachedDatabase, _db.media);
  $$MediaStatesTableTableManager get mediaStates =>
      $$MediaStatesTableTableManager(_db.attachedDatabase, _db.mediaStates);
}
