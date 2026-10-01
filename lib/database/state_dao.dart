import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'state_dao.g.dart';

@DriftAccessor(tables: [MediaStates])
class StateDao extends DatabaseAccessor<AppDatabase> with _$StateDaoMixin {
  StateDao(super.db);

  Future<MediaStateEntry?> getState(int mediaId) => (select(
    mediaStates,
  )..where((t) => t.mediaId.equals(mediaId))).getSingleOrNull();

  Future<void> upsertState(MediaStatesCompanion state) =>
      into(mediaStates).insertOnConflictUpdate(state);

  Future<void> setFavorite(int mediaId, bool favorite) => upsertState(
    MediaStatesCompanion.insert(
      mediaId: Value(mediaId),
      favorite: Value(favorite),
    ),
  );

  Future<void> setHidden(int mediaId, bool hidden) => upsertState(
    MediaStatesCompanion.insert(mediaId: Value(mediaId), hidden: Value(hidden)),
  );

  Future<void> updatePosition(int mediaId, int positionMs) => upsertState(
    MediaStatesCompanion.insert(
      mediaId: Value(mediaId),
      lastPosition: Value(positionMs),
      lastPlayedAt: Value(DateTime.now()),
    ),
  );

  Future<void> incrementPlayCount(int mediaId) async {
    await into(mediaStates).insert(
      MediaStatesCompanion.insert(
        mediaId: Value(mediaId),
        playCount: const Value(1),
        lastPlayedAt: Value(DateTime.now()),
      ),
      onConflict: DoUpdate(
        (old) => MediaStatesCompanion.custom(
          playCount: old.playCount + const Constant(1),
          lastPlayedAt: Variable(DateTime.now()),
        ),
      ),
    );
  }

  Future<Set<int>> getHiddenMediaIds() async {
    final query = selectOnly(mediaStates)
      ..addColumns([mediaStates.mediaId])
      ..where(mediaStates.hidden.equals(true));
    final results = await query
        .map((row) => row.read(mediaStates.mediaId)!)
        .get();
    return results.toSet();
  }

  Future<Set<int>> getFavoriteIds() async {
    final query = selectOnly(mediaStates)
      ..addColumns([mediaStates.mediaId])
      ..where(mediaStates.favorite.equals(true));
    final results = await query
        .map((row) => row.read(mediaStates.mediaId)!)
        .get();
    return results.toSet();
  }
}
