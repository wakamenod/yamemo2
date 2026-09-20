import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider_foundation/path_provider_foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yamemo2/utils/log.dart';

/// iOSでアプリ本体とApp Extension（Siri連携など）がDBを共有するためのApp Group ID。
/// bundle id (com.wakamenod.apps.yamemo2) に合わせている。
const appGroupID = 'group.com.wakamenod.apps.yamemo2';

const dbFileName = 'yamemoapp_database.db';

/// SQLiteがDB本体と一緒に作るファイル。WALモードのときだけ存在する。
const _dbSidecarSuffixes = ['-wal', '-shm'];

/// コピー中のファイルに付ける一時的な拡張子。
const _stagingSuffix = '.migrating';

/// 移行済みであることを示すマーカーファイルの拡張子。旧パス側に置く。
const migratedMarkerSuffix = '.migrated';

/// 実際に開くDBのパスを返す。
///
/// iOSでは共有コンテナ配下を使い、旧パス（サンドボックス内Documents）に
/// DBが残っていれば初回だけコピーして引き継ぐ。共有コンテナが使えない場合や
/// 引き継ぎに失敗した場合は旧パスをそのまま使う（メモを見失わせない）。
Future<String> resolveDatabasePath() async {
  final legacyPath = p.join(await getDatabasesPath(), dbFileName);
  if (!Platform.isIOS) return legacyPath;

  final alreadyMigrated = await File(
    '$legacyPath$migratedMarkerSuffix',
  ).exists();

  final container = await PathProviderFoundation().getContainerPath(
    appGroupIdentifier: appGroupID,
  );
  if (container == null) {
    // 移行前なら旧パスのDBが唯一のデータなので、そのまま使えばよい。
    if (!alreadyMigrated) {
      LOG.warn('App Groupコンテナを取得できないため旧パスのDBを使う: $appGroupID');
      return legacyPath;
    }
    // 移行後はそうはいかない。旧パスのDBは移行時点のスナップショットなので、
    // ここで開くと移行後に書いたメモが消えたように見える。開かずに失敗させる。
    LOG.shout('移行済みなのにApp Groupコンテナを取得できない: $appGroupID');
    throw SharedContainerUnavailableException(appGroupID);
  }

  final sharedPath = p.join(container, dbFileName);
  // 移行済みなら旧パスのDBは古いので、二度とコピーし直さない。
  if (alreadyMigrated) return sharedPath;

  final migrated = await migrateDatabaseIfNeeded(
    legacyPath: legacyPath,
    sharedPath: sharedPath,
  );
  if (!migrated) return legacyPath;

  await markMigrated(legacyPath);
  return sharedPath;
}

/// 共有コンテナのDBを使う状態になったことを記録する。
///
/// 記録に失敗してもDB自体は使えるので、警告だけ出して続行する
/// （次回起動時に再度記録を試みる）。
Future<void> markMigrated(String legacyPath) async {
  try {
    await File('$legacyPath$migratedMarkerSuffix').create(recursive: true);
  } catch (e) {
    LOG.warn('移行済みマーカーを書けなかった: $e');
  }
}

/// 移行後にApp Group共有コンテナへアクセスできなくなった状態。
///
/// 旧パスのDBを開けば古いメモが表示されてしまい、ユーザーからは
/// データが消えたように見えるため、開かずにこの例外を投げる。
class SharedContainerUnavailableException implements Exception {
  final String appGroupID;

  SharedContainerUnavailableException(this.appGroupID);

  @override
  String toString() =>
      'SharedContainerUnavailableException: '
      'App Group $appGroupID の共有コンテナへアクセスできない';
}

/// 旧パスのDBを共有コンテナへコピーする。
///
/// 共有コンテナ側を使ってよければtrueを返す。コピーに失敗したときは
/// 中途半端なファイルを消した上でfalseを返し、呼び出し側を旧パスに戻す。
Future<bool> migrateDatabaseIfNeeded({
  required String legacyPath,
  required String sharedPath,
}) async {
  if (await File(sharedPath).exists()) return true;
  // 新規インストール。sqfliteが共有コンテナ側に作る。
  // ここでもtrueを返すので、呼び出し側がマーカーを残す。
  if (!await File(legacyPath).exists()) return true;

  // 途中でクラッシュしても壊れたDBが残らないよう、一時名でコピーしてから改名する。
  final staged = <String>[];
  try {
    await Directory(p.dirname(sharedPath)).create(recursive: true);
    for (final suffix in ['', ..._dbSidecarSuffixes]) {
      final src = File('$legacyPath$suffix');
      if (!await src.exists()) continue;
      await src.copy('$sharedPath$suffix$_stagingSuffix');
      staged.add('$sharedPath$suffix');
    }
    for (final dest in staged) {
      await File('$dest$_stagingSuffix').rename(dest);
    }
    LOG.info('DBを共有コンテナへ移行した: $sharedPath');
    return true;
  } catch (e) {
    LOG.shout('DBの共有コンテナへの移行に失敗したため旧パスを使う: $e');
    for (final dest in staged) {
      await _deleteIfExists('$dest$_stagingSuffix');
      await _deleteIfExists(dest);
    }
    return false;
  }
}

Future<void> _deleteIfExists(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {
    // 消せなくても旧パスを使うだけなので握りつぶす
  }
}
