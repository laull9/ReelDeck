import 'package:drift/drift.dart';
import 'database.dart';
import 'tables.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media, MediaStates, Sources])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Future<int> insertMedia(MediaCompanion item) => into(media).insert(item);

  Future<void> insertMediaBatch(List<MediaCompanion> items) async {
    await batch((batch) {
      batch.insertAll(media, items, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<MediaEntry>> getMediaBySource(int sourceId) =>
      (select(media)..where((t) => t.sourceId.equals(sourceId))).get();

  Future<List<MediaEntry>> getAllMedia() => select(media).get();

  Future<MediaEntry?> getMediaById(int id) =>
      (select(media)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteMediaBySource(int sourceId) =>
      (delete(media)..where((t) => t.sourceId.equals(sourceId))).go();

  Future<void> deleteMediaById(int id) =>
      (delete(media)..where((t) => t.id.equals(id))).go();

  Future<List<int>> getAllMediaIds() async {
    final query = selectOnly(media)..addColumns([media.id]);
    return query.map((row) => row.read(media.id)!).get();
  }

  Future<List<int>> getEligibleMediaIds() async {
    // not hidden, source enabled
    final query = selectOnly(media)
      ..addColumns([media.id])
      ..join([
        leftOuterJoin(mediaStates, mediaStates.mediaId.equalsExp(media.id)),
        innerJoin(sources, sources.id.equalsExp(media.sourceId)),
      ])
      ..where(
          (mediaStates.hidden.isNull() | mediaStates.hidden.equals(false)) &
          sources.enabled.equals(true));

    return query.map((row) => row.read(media.id)!).get();
  }

  Future<List<int>> getFavoriteMediaIds() async {
    final query = selectOnly(media)
      ..addColumns([media.id])
      ..join([
        innerJoin(mediaStates, mediaStates.mediaId.equalsExp(media.id)),
      ])
      ..where(mediaStates.favorite.equals(true));

    return query.map((row) => row.read(media.id)!).get();
  }
}
