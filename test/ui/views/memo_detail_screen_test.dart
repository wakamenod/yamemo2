import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';

/// 詳細画面のウィジェットテスト用のメモリ内サービス。
///
/// SQLite 実装を使うとウィジェットテストの fake async とかみ合わないので、
/// マイクロタスクだけで完結する最小の実装を用意する。
class _InMemoryMemoService extends MemoService {
  static const _categoryDefs = [
    (id: 1, title: 'category1', sortNo: 1),
    (id: 2, title: 'category2', sortNo: 2),
  ];

  final List<Map<String, dynamic>> rows = [];
  int _nextMemoID = 1;
  int _writingMemoID = 0;

  @override
  Future<List<Memo>> getAllMemos() async => rows.map(Memo.fromMap).toList();

  @override
  Future<List<MemoCategory>> getAllCategories(bool forceDiskFetch) async {
    final memos = await getAllMemos();
    return _categoryDefs
        .map(
          (def) => MemoCategory(
            id: def.id,
            title: def.title,
            sortNo: def.sortNo,
            memos: memos.where((m) => m.categoryID == def.id).toList(),
          ),
        )
        .toList();
  }

  @override
  Future<Memo> addMemo(Memo memo) async {
    final id = _nextMemoID++;
    rows.add({
      'id': id,
      'category_id': memo.categoryID,
      'content': memo.content,
    });
    return Memo(id: id, categoryID: memo.categoryID, content: memo.content);
  }

  @override
  Future updateMemo(Map<String, dynamic> memoMap) async {
    final row = rows.firstWhere((r) => r['id'] == memoMap['id']);
    row['category_id'] = memoMap['category_id'];
    row['content'] = memoMap['content'];
  }

  @override
  Future<int> getWritingMemoID() async => _writingMemoID;

  @override
  Future updateWritingMemoRecord(int memoID) async {
    _writingMemoID = memoID;
  }

  @override
  Future<MemoCategory> addCategory(MemoCategory category) =>
      throw UnimplementedError();
  @override
  Future updateCategory(MemoCategory category) => throw UnimplementedError();
  @override
  Future deleteMemo(int id) => throw UnimplementedError();
  @override
  Future deleteMemoByCategoryID(int categoryID) => throw UnimplementedError();
  @override
  Future deleteCategory(MemoCategory category) => throw UnimplementedError();
  @override
  Future updateCategorySortNos(int from, int to) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> exportBackup() => throw UnimplementedError();
  @override
  Future<void> importBackup(Map<String, dynamic> data) =>
      throw UnimplementedError();
}

void main() {
  late _InMemoryMemoService service;
  late MemoScreenViewModel model;

  setUp(() async {
    await serviceLocator.reset();
    service = _InMemoryMemoService();
    serviceLocator.registerSingleton<MemoService>(service);
    serviceLocator.registerLazySingleton<MemoScreenViewModel>(
      () => MemoScreenViewModel(),
    );
    model = serviceLocator<MemoScreenViewModel>();
  });

  // 詳細画面は 2 枚目のルートとして開く。popDetailPage が最後のルートを
  // pop しようとしないようにするため。
  Widget buildApp() {
    return I18n(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoDetailScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  /// アプリを起動し、ViewModel の初期ロードを終わらせる。
  ///
  /// NOTE: `loadData()` は戻り値が void なので await できない。fake async では
  /// `Future.delayed` がテスト本体の await では進まないため、`pump()` で流す。
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    model.loadData();
    await tester.pump();
  }

  /// 詳細画面を 2 枚目のルートとして開く。
  Future<void> openDetail(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> pickCategory(WidgetTester tester, String title) async {
    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title).last);
    await tester.pumpAndSettle();
  }

  group('既存メモのカテゴリ変更', () {
    /// category1 にメモを 1 件作り、それを開いた状態にする。
    Future<Memo> openExistingMemo(WidgetTester tester) async {
      await pumpApp(tester);
      final memo = await model.addMemo('既存メモ');
      model.selectMemo(memo);
      await openDetail(tester);
      return memo;
    }

    testWidgets('チェックボタンで新しいカテゴリに保存される', (tester) async {
      final memo = await openExistingMemo(tester);

      await pickCategory(tester, 'category2');
      await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
      await tester.pumpAndSettle();

      final memos = await service.getAllMemos();
      expect(memos.length, 1, reason: 'メモが重複して作られていないこと');
      expect(memos.single.id, memo.id);
      expect(memos.single.categoryID, 2);
      expect(memos.single.content, '既存メモ');
    });

    testWidgets('戻るボタンで閉じてもカテゴリ変更は保存済み', (tester) async {
      await openExistingMemo(tester);

      await pickCategory(tester, 'category2');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      final memos = await service.getAllMemos();
      expect(memos.length, 1);
      expect(memos.single.categoryID, 2);
    });

    testWidgets('本文とカテゴリを両方変更してチェックすると両方保存される', (tester) async {
      await openExistingMemo(tester);

      await tester.enterText(find.byType(TextFormField), '編集後の本文');
      await pickCategory(tester, 'category2');
      await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
      await tester.pumpAndSettle();

      final memos = await service.getAllMemos();
      expect(memos.length, 1);
      expect(memos.single.categoryID, 2);
      expect(memos.single.content, '編集後の本文');
    });
  });

  group('新規メモ', () {
    testWidgets('カテゴリを先に選んでも空メモは作られない', (tester) async {
      await pumpApp(tester);
      await openDetail(tester);

      await pickCategory(tester, 'category2');
      expect(await service.getAllMemos(), isEmpty);

      await tester.enterText(find.byType(TextFormField), '新規メモ');
      await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
      await tester.pumpAndSettle();

      final memos = await service.getAllMemos();
      expect(memos.length, 1);
      expect(memos.single.categoryID, 2);
      expect(memos.single.content, '新規メモ');
    });

    testWidgets('保存して閉じた後にメモの選択状態が残らない', (tester) async {
      await pumpApp(tester);
      await openDetail(tester);

      await tester.enterText(find.byType(TextFormField), '新規メモ');
      await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
      await tester.pumpAndSettle();

      expect(model.isMemoSelected(), isFalse);
    });
  });
}
