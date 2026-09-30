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

  Future<void> setFavorite(int mediaId, bool favorite) async {
    final existing = await getState(mediaId);
    if (existing != null) {
      await update(mediaStates).replace(existing.copyWith(favorite: favorite));
    } else {
      await into(mediaStates).insert(
        MediaStatesCompanion.insert(
          mediaId: Value(mediaId),
          favorite: Value(favorite),
        ),
      );
    }
  }

  Future<void> setHidden(int mediaId, bool hidden) async {
    final existing = await getState(mediaId);
    if (existing != null) {
      await update(mediaStates).replace(existing.copyWith(hidden: hidden));
    } else {
      await into(mediaStates).insert(
        MediaStatesCompanion.insert(
          mediaId: Value(mediaId),
          hidden: Value(hidden),
        ),
      );
    }
  }

  Future<void> updatePosition(int mediaId, int positionMs) async {
    final existing = await getState(mediaId);
    if (existing != null) {
      await update(mediaStates).replace(
        existing.copyWith(
          lastPosition: Value(positionMs),
          lastPlayedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(mediaStates).insert(
        MediaStatesCompanion.insert(
          mediaId: Value(mediaId),
          lastPosition: Value(positionMs),
          lastPlayedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> incrementPlayCount(int mediaId) async {
    final existing = await getState(mediaId);
    if (existing != null) {
      await update(mediaStates).replace(
        existing.copyWith(
          playCount: existing.playCount + 1,
          lastPlayedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(mediaStates).insert(
        MediaStatesCompanion.insert(
          mediaId: Value(mediaId),
          playCount: const Value(1),
          lastPlayedAt: Value(DateTime.now()),
        ),
      );
    }
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
