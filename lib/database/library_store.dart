import 'package:drift/drift.dart';

import 'database.dart';
import '../sources/source.dart' as model;

class LibraryStore {
  final AppDatabase db;
  LibraryStore(this.db);

  Future<List<model.Source>> sources() async =>
      (await db.sourceDao.getAllSources())
          .map(
            (s) => model.Source(
              id: s.id,
              name: s.name,
              locator: s.locator,
              lastKnownPath: s.lastKnownPath,
              platform: s.platform,
              volumeIdentity: s.volumeIdentity,
              enabled: s.enabled,
              recursive: s.recursive,
              lastScanAt: s.lastScanAt,
            ),
          )
          .toList();

  Future<void> saveSource(model.Source s) => db
      .into(db.sources)
      .insertOnConflictUpdate(
        SourcesCompanion.insert(
          id: Value(s.id),
          name: s.name,
          locator: s.locator,
          lastKnownPath: s.lastKnownPath,
          platform: s.platform,
          volumeIdentity: Value(s.volumeIdentity),
          enabled: Value(s.enabled),
          recursive: Value(s.recursive),
          lastScanAt: Value(s.lastScanAt),
        ),
      );

  Future<List<model.Media>> media() async => (await db.mediaDao.getAllMedia())
      .map(
        (m) => model.Media(
          id: m.id,
          sourceId: m.sourceId,
          relativePath: m.relativePath,
          fileName: m.fileName,
          extension: m.extension,
          size: m.size,
          modifiedAt: m.modifiedAt,
        ),
      )
      .toList();

  Future<void> replaceMedia(int sourceId, List<model.Media> items) =>
      db.transaction(() async {
        final ids = items.map((m) => m.id).toSet();
        final removed = (await db.mediaDao.getMediaBySource(sourceId))
            .where((m) => !ids.contains(m.id))
            .map((m) => m.id)
            .toList();
        await (db.delete(
          db.mediaStates,
        )..where((t) => t.mediaId.isIn(removed))).go();
        await (db.delete(db.media)..where((t) => t.id.isIn(removed))).go();
        await db.batch(
          (b) => b.insertAllOnConflictUpdate(
            db.media,
            items
                .map(
                  (m) => MediaCompanion.insert(
                    id: Value(m.id),
                    sourceId: m.sourceId,
                    relativePath: m.relativePath,
                    fileName: m.fileName,
                    extension: m.extension,
                    size: m.size,
                    modifiedAt: m.modifiedAt,
                  ),
                )
                .toList(),
          ),
        );
      });

  Future<void> removeSource(int id) => db.transaction(() async {
    await replaceMedia(id, []);
    await (db.delete(db.hiddenRules)..where((t) => t.sourceId.equals(id))).go();
    await db.sourceDao.deleteSource(id);
  });

  Future<List<HiddenRuleEntry>> rules() => db.select(db.hiddenRules).get();
  Future<void> hideFolder(int sourceId, String path) async {
    final existing =
        await (db.select(db.hiddenRules)..where(
              (t) => t.sourceId.equals(sourceId) & t.relativePath.equals(path),
            ))
            .get();
    if (existing.isEmpty) {
      await db
          .into(db.hiddenRules)
          .insert(
            HiddenRulesCompanion.insert(sourceId: sourceId, relativePath: path),
          );
    }
  }

  Future<void> resetHidden() => db.transaction(() async {
    await db.delete(db.hiddenRules).go();
    await db
        .update(db.mediaStates)
        .write(const MediaStatesCompanion(hidden: Value(false)));
  });
}
