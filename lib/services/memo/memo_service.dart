import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';

abstract class MemoService {
  Future<List<Memo>> getAllMemos();
  Future<List<MemoCategory>> getAllCategories(bool forceDiskFetch);
  Future<MemoCategory> addCategory(MemoCategory category);
  Future updateCategory(MemoCategory category);
  Future<Memo> addMemo(Memo memo);
  Future updateMemo(Map<String, dynamic> memoMap);
  Future deleteMemo(int id);
  Future deleteMemoByCategoryID(int categoryID);
  Future deleteCategory(MemoCategory category);
  Future updateCategorySortNos(int from, int to);
  Future<int> getWritingMemoID();
  Future updateWritingMemoRecord(int memoID);

  /// 全Category・全MemoをJSON用Mapとしてエクスポートする
  Future<Map<String, dynamic>> exportBackup();

  /// JSON用Mapからデータをインポートし、既存データを置き換える
  Future<void> importBackup(Map<String, dynamic> data);
}
