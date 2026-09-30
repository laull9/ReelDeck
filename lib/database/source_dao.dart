import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'source_dao.g.dart';

@DriftAccessor(tables: [Sources])
class SourceDao extends DatabaseAccessor<AppDatabase> with _$SourceDaoMixin {
  SourceDao(super.db);

  Future<List<SourceEntry>> getAllSources() => select(sources).get();

  Future<SourceEntry?> getSourceById(int id) =>
      (select(sources)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertSource(SourcesCompanion source) =>
      into(sources).insert(source);

  Future<void> updateSource(SourceEntry source) =>
      update(sources).replace(source);

  Future<void> deleteSource(int id) =>
      (delete(sources)..where((t) => t.id.equals(id))).go();

  Stream<List<SourceEntry>> watchAllSources() => select(sources).watch();
}
