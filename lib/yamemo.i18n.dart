import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations("en_us") +
      {
        "en_us": "Add New Category",
        "ja_jp": "新規カテゴリ追加",
      } +
      {
        "en_us": "CANCEL",
        "ja_jp": "キャンセル",
      } +
      {
        "en_us": "DELETE",
        "ja_jp": "削除",
      } +
      {
        "en_us": "Add",
        "ja_jp": "追加",
      } +
      {
        "en_us": "EDIT",
        "ja_jp": "更新",
      } +
      {
        "en_us": "Unexpected Error.",
        "ja_jp": "予期しないエラーが発生しました",
      } +
      {
        "en_us": "Deleted",
        "ja_jp": "削除しました",
      } +
      {
        "en_us": "Are you sure you wish to delete this memo?",
        "ja_jp": "このメモを削除しますか?",
      } +
      {
        "en_us":
            "Are you sure you wish to delete this catgory and all memos in it?",
        "ja_jp": "このカテゴリとカテゴリ内のメモを削除しますか?",
      } +
      {
        "en_us": "Select Category",
        "ja_jp": "カテゴリ選択",
      } +
      {
        "en_us": "Edit Category",
        "ja_jp": "カテゴリ編集",
      } +
      {
        "en_us": "Position: ",
        "ja_jp": "タブ位置",
      } +
      {
        "en_us": "Name: ",
        "ja_jp": "名前",
      } +
      {
        "en_us": "Confirm",
        "ja_jp": "確認",
      };

  String get i18n => localize(this, _t);
}
