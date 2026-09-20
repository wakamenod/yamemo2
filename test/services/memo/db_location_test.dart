import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yamemo2/services/memo/db_location.dart';

void main() {
  late Directory tmp;
  late String legacyPath;
  late String sharedPath;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('db_location_test');
    await Directory(p.join(tmp.path, 'legacy')).create();
    legacyPath = p.join(tmp.path, 'legacy', dbFileName);
    sharedPath = p.join(tmp.path, 'shared', dbFileName);
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  group('migrateDatabaseIfNeeded', () {
    test('旧DBを共有コンテナへコピーする', () async {
      await File(legacyPath).writeAsString('memo db');

      expect(
        await migrateDatabaseIfNeeded(
          legacyPath: legacyPath,
          sharedPath: sharedPath,
        ),
        isTrue,
      );
      expect(await File(sharedPath).readAsString(), 'memo db');
      // 旧DBは安全網として残す
      expect(await File(legacyPath).exists(), isTrue);
    });

    test('WALのサイドカーファイルも一緒にコピーする', () async {
      await File(legacyPath).writeAsString('memo db');
      await File('$legacyPath-wal').writeAsString('wal');
      await File('$legacyPath-shm').writeAsString('shm');

      await migrateDatabaseIfNeeded(
        legacyPath: legacyPath,
        sharedPath: sharedPath,
      );

      expect(await File('$sharedPath-wal').readAsString(), 'wal');
      expect(await File('$sharedPath-shm').readAsString(), 'shm');
    });

    test('コピー中の一時ファイルを残さない', () async {
      await File(legacyPath).writeAsString('memo db');

      await migrateDatabaseIfNeeded(
        legacyPath: legacyPath,
        sharedPath: sharedPath,
      );

      final leftovers = Directory(p.dirname(sharedPath))
          .listSync()
          .map((e) => p.basename(e.path))
          .where((name) => name.contains('migrating'));
      expect(leftovers, isEmpty);
    });

    test('移行済みなら共有コンテナ側を上書きしない', () async {
      await File(legacyPath).writeAsString('古いメモ');
      await Directory(p.dirname(sharedPath)).create(recursive: true);
      await File(sharedPath).writeAsString('新しいメモ');

      expect(
        await migrateDatabaseIfNeeded(
          legacyPath: legacyPath,
          sharedPath: sharedPath,
        ),
        isTrue,
      );
      expect(await File(sharedPath).readAsString(), '新しいメモ');
    });

    test('新規インストール（旧DBなし）では何もコピーせず共有コンテナを使う', () async {
      expect(
        await migrateDatabaseIfNeeded(
          legacyPath: legacyPath,
          sharedPath: sharedPath,
        ),
        isTrue,
      );
      expect(await File(sharedPath).exists(), isFalse);
    });

    test('移行済みマーカーを付けた後は再度コピーしない前提で、マーカーは旧パス側に作られる', () async {
      await File(legacyPath).writeAsString('memo db');
      await migrateDatabaseIfNeeded(
        legacyPath: legacyPath,
        sharedPath: sharedPath,
      );

      await markMigrated(legacyPath);

      expect(await File('$legacyPath$migratedMarkerSuffix').exists(), isTrue);
    });

    test('コピーに失敗したら旧パスへフォールバックし、壊れたDBを残さない', () async {
      await File(legacyPath).writeAsString('memo db');
      // 共有コンテナのパスにディレクトリを作っておき、コピーを失敗させる
      await Directory(sharedPath).create(recursive: true);

      expect(
        await migrateDatabaseIfNeeded(
          legacyPath: legacyPath,
          sharedPath: sharedPath,
        ),
        isFalse,
      );
      expect(await File(legacyPath).readAsString(), 'memo db');
    });
  });

  group('SharedContainerUnavailableException', () {
    test('App Group IDがメッセージに含まれる', () {
      final e = SharedContainerUnavailableException(appGroupID);

      expect(e.toString(), contains(appGroupID));
    });
  });
}
