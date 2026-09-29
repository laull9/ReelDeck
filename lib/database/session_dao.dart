import 'package:drift/drift.dart';
import 'database.dart';
import 'tables.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<SessionEntry?> getLatestSession() =>
      (select(sessions)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
        ..limit(1))
          .getSingleOrNull();

  Future<int> saveSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<void> deleteSession(int id) =>
      (delete(sessions)..where((t) => t.id.equals(id))).go();
}
