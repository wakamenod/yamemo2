import 'memo.dart';

class MemoCategory {
  static final MemoCategory nullCategory = MemoCategory._empty();

  final int id;
  String title;
  int sortNo;
  final List<Memo> memos;

  MemoCategory(
      {required this.id,
      required this.title,
      required this.memos,
      required this.sortNo});

  MemoCategory._empty()
      : id = 0,
        title = '',
        sortNo = 0,
        memos = [];

  factory MemoCategory.fromMap(Map<String, dynamic> el, List<Memo> ms) =>
      MemoCategory(
        id: el["id"],
        title: el["title"],
        sortNo: el["sort_no"],
        memos: ms.where((i) => (i.categoryID == el["id"])).toList(),
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'title': title,
      'sort_no': sortNo,
    };
  }

  int get memoCount {
    return memos.length;
  }

  Memo getMemoAt(int idx) {
    return memos[idx];
  }

  Memo getMemoByID(int id) {
    return memos.firstWhere((m) => m.id == id);
  }
}
