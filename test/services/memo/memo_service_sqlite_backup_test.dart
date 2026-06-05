import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/services/memo/memo_service_sqlite.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late MemoServiceSQLite service;

  setUp(() {
    service = MemoServiceSQLite(dbPath: inMemoryDatabasePath);
  });

  group('exportBackup', () {
    test('正しい構造のMapを返す (version, created_at, categories, memos)', () async {
      final backup = await service.exportBackup();

      expect(backup['version'], 1);
      expect(backup['created_at'], isA<String>());
      expect(backup['categories'], isList);
      expect(backup['memos'], isList);
    });

    test('初期DBのデフォルトカテゴリ2件をエクスポートできる', () async {
      final backup = await service.exportBackup();

      final categories = backup['categories'] as List;
      expect(categories.length, 2);
      expect(categories[0]['title'], 'category1');
      expect(categories[1]['title'], 'category2');
    });

    test('初期DBのメモは0件', () async {
      final backup = await service.exportBackup();

      final memos = backup['memos'] as List;
      expect(memos.length, 0);
    });

    test('Memo追加後にエクスポートに反映される', () async {
      await service.addMemo(Memo(categoryID: 1, content: 'テストメモ'));
      await service.addMemo(
          Memo(categoryID: 2, content: '改行を含む\nメモ'));

      final backup = await service.exportBackup();

      final memos = backup['memos'] as List;
      expect(memos.length, 2);
      expect(memos[0]['content'], 'テストメモ');
      expect(memos[0]['category_id'], 1);
      expect(memos[1]['content'], '改行を含む\nメモ');
      expect(memos[1]['category_id'], 2);
    });
  });

  group('importBackup', () {
    test('既存データが完全に置き換わる', () async {
      // 初期データとしてメモを追加
      await service.addMemo(Memo(categoryID: 1, content: '古いメモ'));

      // 新しいデータをインポート
      await service.importBackup({
        'version': 1,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'categories': [
          {'id': 10, 'title': 'インポートカテゴリ', 'sort_no': 0},
        ],
        'memos': [
          {'id': 100, 'category_id': 10, 'content': 'インポートメモ'},
        ],
      });

      final backup = await service.exportBackup();

      final categories = backup['categories'] as List;
      expect(categories.length, 1);
      expect(categories[0]['id'], 10);
      expect(categories[0]['title'], 'インポートカテゴリ');

      final memos = backup['memos'] as List;
      expect(memos.length, 1);
      expect(memos[0]['id'], 100);
      expect(memos[0]['content'], 'インポートメモ');
    });

    test('空データのインポートで全データがクリアされる', () async {
      await service.importBackup({
        'version': 1,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'categories': [],
        'memos': [],
      });

      final backup = await service.exportBackup();
      expect((backup['categories'] as List).length, 0);
      expect((backup['memos'] as List).length, 0);
    });

    test('複数カテゴリ・メモのインポートが正しく動作する', () async {
      await service.importBackup({
        'version': 1,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'categories': [
          {'id': 1, 'title': '仕事', 'sort_no': 0},
          {'id': 2, 'title': '個人', 'sort_no': 1},
          {'id': 3, 'title': 'アイデア', 'sort_no': 2},
        ],
        'memos': [
          {'id': 1, 'category_id': 1, 'content': '会議メモ'},
          {'id': 2, 'category_id': 1, 'content': 'TODO'},
          {'id': 3, 'category_id': 2, 'content': '買い物リスト'},
          {'id': 4, 'category_id': 3, 'content': 'アプリのアイデア'},
        ],
      });

      final backup = await service.exportBackup();

      final categories = backup['categories'] as List;
      expect(categories.length, 3);
      expect(categories[0]['title'], '仕事');
      expect(categories[1]['title'], '個人');
      expect(categories[2]['title'], 'アイデア');

      final memos = backup['memos'] as List;
      expect(memos.length, 4);
    });
  });

  group('ラウンドトリップ (export → import → export)', () {
    test('エクスポート→インポート→再エクスポートでデータが一致する', () async {
      // データを追加
      await service.addMemo(Memo(categoryID: 1, content: 'メモ1'));
      await service.addMemo(
          Memo(categoryID: 2, content: 'メモ2\n改行あり'));

      // エクスポート
      final exported = await service.exportBackup();

      // 別のサービスインスタンス（新規DB）にインポート
      final newService = MemoServiceSQLite(dbPath: inMemoryDatabasePath);
      await newService.importBackup(exported);

      // 再エクスポート
      final reExported = await newService.exportBackup();

      // categories と memos が一致すること（created_at は異なるので比較しない）
      expect(reExported['version'], exported['version']);
      expect(reExported['categories'], exported['categories']);
      expect(reExported['memos'], exported['memos']);
    });
  });
}
