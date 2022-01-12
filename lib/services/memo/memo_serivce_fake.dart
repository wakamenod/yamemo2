import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';

import 'memo_service.dart';

class MemoServiceFake extends MemoService {
  @override
  Future<List<Memo>> getAllMemos() async {
    List<Memo> res = [
      Memo(id: 1, categoryID: 1, content: 'AAAAAA'),
      Memo(id: 2, categoryID: 1, content: 'BBBBBB'),
      Memo(id: 3, categoryID: 1, content: 'CCCCCC'),
    ];
    return res;
  }

  @override
  Future<List<MemoCategory>> getAllCategories(bool forceDiskFetch) async {
    return [
      MemoCategory(
        title: "Fake 1",
        id: 0,
        memos: [],
        sortNo: 0,
      ),
      MemoCategory(
        title: "Fake 2",
        id: 1,
        memos: [],
        sortNo: 1,
      ),
      MemoCategory(
        title: "Fake 3",
        id: 2,
        memos: [],
        sortNo: 2,
      ),
    ];
  }

  @override
  Future<MemoCategory> addCategory(MemoCategory category) {
    throw UnimplementedError();
  }

  @override
  Future<Memo> addMemo(Memo memo) {
    throw UnimplementedError();
  }

  @override
  Future deleteMemo(int id) {
    throw UnimplementedError();
  }

  @override
  Future updateMemo(Map<String, dynamic> memoMap) {
    throw UnimplementedError();
  }

  @override
  Future updateCategory(MemoCategory category) {
    throw UnimplementedError();
  }

  @override
  Future deleteCategory(MemoCategory category) {
    throw UnimplementedError();
  }

  @override
  Future deleteMemoByCategoryID(int categoryID) {
    throw UnimplementedError();
  }

  @override
  Future updateCategorySortNos(int from, int to) {
    throw UnimplementedError();
  }
}
