import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'source_dao.dart';
import 'media_dao.dart';
import 'state_dao.dart';
import 'session_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Sources, Media, MediaStates, HiddenRules, Sessions],
  daos: [SourceDao, MediaDao, StateDao, SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'reel_deck', 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
