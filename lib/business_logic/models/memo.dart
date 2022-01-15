class Memo {
  static final Memo nullMemo = Memo._empty();

  int? id;
  int categoryID;
  String content;

  factory Memo.fromMap(Map<String, dynamic> el) => Memo(
        id: el["id"],
        categoryID: el["category_id"],
        content: el["content"] == null ? '' : el['content'],
      );

  Memo._empty()
      : id = 0,
        categoryID = 0,
        content = '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryID,
      'content': content,
    };
  }

  Memo({this.id, required this.categoryID, required this.content});
}
