import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/database/database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and retrieve source', () async {
    final dao = database.sourceDao;
    final id = await dao.insertSource(SourcesCompanion.insert(
      name: 'Test Source',
      locator: '/test/locator',
      lastKnownPath: '/test/path',
      platform: 'macos',
    ));

    final source = await dao.getSourceById(id);
    expect(source != null, isTrue);
    expect(source!.name, 'Test Source');
    expect(source.enabled, isTrue); // default
  });

  test('insert and retrieve media', () async {
    final sourceDao = database.sourceDao;
    final mediaDao = database.mediaDao;

    final sourceId = await sourceDao.insertSource(SourcesCompanion.insert(
      name: 'Test Source',
      locator: '/test/locator',
      lastKnownPath: '/test/path',
      platform: 'macos',
    ));

    final mediaId = await mediaDao.insertMedia(MediaCompanion.insert(
      sourceId: sourceId,
      relativePath: 'video.mp4',
      fileName: 'video.mp4',
      extension: 'mp4',
      size: 1024,
      modifiedAt: DateTime.now(),
    ));

    final media = await mediaDao.getMediaById(mediaId);
    expect(media != null, isTrue);
    expect(media!.fileName, 'video.mp4');
  });

  test('media states are upserted correctly', () async {
    final sourceDao = database.sourceDao;
    final mediaDao = database.mediaDao;
    final stateDao = database.stateDao;

    final sourceId = await sourceDao.insertSource(SourcesCompanion.insert(
      name: 'Test',
      locator: '/test',
      lastKnownPath: '/test',
      platform: 'macos',
    ));

    final mediaId = await mediaDao.insertMedia(MediaCompanion.insert(
      sourceId: sourceId,
      relativePath: 'video.mp4',
      fileName: 'video.mp4',
      extension: 'mp4',
      size: 1024,
      modifiedAt: DateTime.now(),
    ));

    await stateDao.setFavorite(mediaId, true);
    final state1 = await stateDao.getState(mediaId);
    expect(state1!.favorite, isTrue);
    expect(state1.playCount, 0);

    await stateDao.incrementPlayCount(mediaId);
    final state2 = await stateDao.getState(mediaId);
    expect(state2!.favorite, isTrue); // favorite should remain true
    expect(state2.playCount, 1);
  });
  
  test('eligible media ids filters hidden media and disabled sources', () async {
    final sourceDao = database.sourceDao;
    final mediaDao = database.mediaDao;
    final stateDao = database.stateDao;
    
    // enabled source
    final s1 = await sourceDao.insertSource(SourcesCompanion.insert(
      name: 'S1', locator: 'S1', lastKnownPath: 'S1', platform: 'macos',
    ));
    // disabled source
    final s2 = await sourceDao.insertSource(SourcesCompanion.insert(
      name: 'S2', locator: 'S2', lastKnownPath: 'S2', platform: 'macos',
      enabled: const Value(false),
    ));
    
    final m1 = await mediaDao.insertMedia(MediaCompanion.insert(
      sourceId: s1, relativePath: '1.mp4', fileName: '1.mp4', extension: 'mp4', size: 0, modifiedAt: DateTime.now()
    ));
    final m2 = await mediaDao.insertMedia(MediaCompanion.insert(
      sourceId: s1, relativePath: '2.mp4', fileName: '2.mp4', extension: 'mp4', size: 0, modifiedAt: DateTime.now()
    ));
    final m3 = await mediaDao.insertMedia(MediaCompanion.insert(
      sourceId: s2, relativePath: '3.mp4', fileName: '3.mp4', extension: 'mp4', size: 0, modifiedAt: DateTime.now()
    ));
    
    // hide m2
    await stateDao.setHidden(m2, true);
    
    final eligible = await mediaDao.getEligibleMediaIds();
    expect(eligible, contains(m1));
    expect(eligible, isNot(contains(m2))); // hidden
    expect(eligible, isNot(contains(m3))); // disabled source
  });
}
