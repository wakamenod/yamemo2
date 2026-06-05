import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t =
      Translations.byText("en-US") +
      {"en-US": "Add New Category", "ja-JP": "新規カテゴリ追加"} +
      {"en-US": "CANCEL", "ja-JP": "キャンセル"} +
      {"en-US": "DELETE", "ja-JP": "削除"} +
      {"en-US": "Add", "ja-JP": "追加"} +
      {"en-US": "EDIT", "ja-JP": "更新"} +
      {"en-US": "Unexpected Error.", "ja-JP": "予期しないエラーが発生しました"} +
      {"en-US": "Deleted", "ja-JP": "削除しました"} +
      {
        "en-US": "Are you sure you wish to delete this memo?",
        "ja-JP": "このメモを削除しますか?",
      } +
      {
        "en-US":
            "Are you sure you wish to delete this catgory and all memos in it?",
        "ja-JP": "このカテゴリとカテゴリ内のメモを削除しますか?",
      } +
      {"en-US": "Select Category", "ja-JP": "カテゴリ選択"} +
      {"en-US": "Edit Category", "ja-JP": "カテゴリ編集"} +
      {"en-US": "Position: ", "ja-JP": "タブ位置"} +
      {"en-US": "Name: ", "ja-JP": "名前"} +
      {"en-US": "Confirm", "ja-JP": "確認"} +
      {"en-US": "Backup", "ja-JP": "バックアップ"} +
      {"en-US": "Backup description", "ja-JP": "バックアップとリストアの管理ができます。"} +
      {"en-US": "Create Backup", "ja-JP": "バックアップを作成"} +
      {"en-US": "Restore from Backup", "ja-JP": "バックアップから復元"} +
      {"en-US": "Confirm Restore", "ja-JP": "復元の確認"} +
      {
        "en-US":
            "All current data will be overwritten. Are you sure you want to restore?",
        "ja-JP": "現在のデータは全て上書きされます。本当に復元しますか？",
      } +
      {"en-US": "Backup completed.", "ja-JP": "バックアップが完了しました。"} +
      {"en-US": "Restore completed.", "ja-JP": "復元が完了しました。"} +
      {"en-US": "Restore cancelled.", "ja-JP": "復元がキャンセルされました。"} +
      {
        "en-US": "Failed to restore. The file may be invalid.",
        "ja-JP": "復元に失敗しました。ファイルが不正な可能性があります。",
      } +
      {"en-US": "Restore", "ja-JP": "復元"};

  String get i18n => localize(this, _t);
}
