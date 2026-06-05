import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byText("en-US") +
      {
        "en-US": "Add New Category",
        "ja-JP": "新規カテゴリ追加",
      } +
      {
        "en-US": "CANCEL",
        "ja-JP": "キャンセル",
      } +
      {
        "en-US": "DELETE",
        "ja-JP": "削除",
      } +
      {
        "en-US": "Add",
        "ja-JP": "追加",
      } +
      {
        "en-US": "EDIT",
        "ja-JP": "更新",
      } +
      {
        "en-US": "Unexpected Error.",
        "ja-JP": "予期しないエラーが発生しました",
      } +
      {
        "en-US": "Deleted",
        "ja-JP": "削除しました",
      } +
      {
        "en-US": "Are you sure you wish to delete this memo?",
        "ja-JP": "このメモを削除しますか?",
      } +
      {
        "en-US":
            "Are you sure you wish to delete this catgory and all memos in it?",
        "ja-JP": "このカテゴリとカテゴリ内のメモを削除しますか?",
      } +
      {
        "en-US": "Select Category",
        "ja-JP": "カテゴリ選択",
      } +
      {
        "en-US": "Edit Category",
        "ja-JP": "カテゴリ編集",
      } +
      {
        "en-US": "Position: ",
        "ja-JP": "タブ位置",
      } +
      {
        "en-US": "Name: ",
        "ja-JP": "名前",
      } +
      {
        "en-US": "Confirm",
        "ja-JP": "確認",
      };

  String get i18n => localize(this, _t);
}
