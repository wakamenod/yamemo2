import 'package:flutter_test/flutter_test.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/services/service_locator.dart';

/// DBを開けない状況を再現するサービス。
class _FailingMemoService extends MemoService {
  @override
  Future<List<MemoCategory>> getAllCategories(bool forceDiskFetch) async =>
      throw Exception('DBを開けない');

  @override
  Future<List<Memo>> getAllMemos() => throw UnimplementedError();
  @override
  Future<MemoCategory> addCategory(MemoCategory category) =>
      throw UnimplementedError();
  @override
  Future updateCategory(MemoCategory category) => throw UnimplementedError();
  @override
  Future<Memo> addMemo(Memo memo) => throw UnimplementedError();
  @override
  Future updateMemo(Map<String, dynamic> memoMap) => throw UnimplementedError();
  @override
  Future deleteMemo(int id) => throw UnimplementedError();
  @override
  Future deleteMemoByCategoryID(int categoryID) => throw UnimplementedError();
  @override
  Future deleteCategory(MemoCategory category) => throw UnimplementedError();
  @override
  Future updateCategorySortNos(int from, int to) => throw UnimplementedError();
  @override
  Future<int> getWritingMemoID() => throw UnimplementedError();
  @override
  Future updateWritingMemoRecord(int memoID) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> exportBackup() => throw UnimplementedError();
  @override
  Future<void> importBackup(Map<String, dynamic> data) =>
      throw UnimplementedError();
}

void main() {
  setUp(() async {
    await serviceLocator.reset();
    serviceLocator.registerSingleton<MemoService>(_FailingMemoService());
    serviceLocator.registerLazySingleton<MemoScreenViewModel>(
      () => MemoScreenViewModel(),
    );
  });

  test('DBを開けないときは空の一覧ではなくエラー状態になる', () async {
    final model = serviceLocator<MemoScreenViewModel>();

    model.loadData();
    await Future.delayed(Duration.zero);

    expect(model.hasLoadError, isTrue);
    expect(model.isLoading, isFalse);
    expect(model.categoryCount, 0);
  });
}
