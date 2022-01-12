class Memo {
  final int id;
  int categoryID;
  String content;

  factory Memo.fromMap(Map<String, dynamic> el) => Memo(
        id: el["id"],
        categoryID: el["category_id"],
        content: el["content"] == null ? '' : el['content'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryID,
      'content': content,
    };
  }

  Memo({required this.id, required this.categoryID, required this.content});
}
