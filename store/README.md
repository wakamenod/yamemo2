# App Store 提出用の素材

## スクリーンショット

| ディレクトリ | 端末 | 解像度 |
| --- | --- | --- |
| `screenshots/iphone-6.9` | iPhone 17 Pro Max | 1320 × 2868 |
| `screenshots/ipad-13` | iPad Pro 13-inch (M5) | 2064 × 2752 |

iPhone は 6.9 インチ、iPad は 13 インチが App Store Connect の必須サイズ。
これより小さい端末向けは Apple 側で縮小されるので、この 2 種類を用意すれば足りる
（必須サイズの規定は変わることがあるので、最終的には App Store Connect の表示に従うこと）。

1024×1024 のマーケティング用アイコンはアセットカタログから読まれるため、
ここに置く必要はない。

## 撮り直しかた

撮影専用のエントリポイント `lib/main-screenshot.dart` を使う。通常の起動と違い、
サンプルのメモを流し込み、広告を初期化せず（テスト広告の写り込みを防ぐ）、
デバッグバナーも出さない。起動後は 一覧 → 詳細 → バックアップ の順に自動で
遷移する。

```sh
# 1. シミュレータを起動してステータスバーを固定する
xcrun simctl boot "iPhone 17 Pro Max"
xcrun simctl status_bar <udid> override \
  --time "9:41" --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3

# 2. インストールする（--flavor は付けない。理由は下記）
fvm flutter run -t lib/main-screenshot.dart -d <udid>

# 3. flutter run を止め、アプリを再起動しながら時刻で撮る
xcrun simctl launch <udid> com.wakamenod.apps.yamemo2
#   起動から 5.5s → 一覧 / 12.5s → 詳細 / 19.5s → バックアップ
xcrun simctl io <udid> screenshot store/screenshots/<端末>/list.png
```

### `--flavor` を付けてはいけない理由

`ios/Flutter/prodDebug.xcconfig` などのフレーバー用 xcconfig が
`FLUTTER_TARGET=lib/main-prod.dart` を `Generated.xcconfig` の後に定義しており、
`-t` の指定を上書きしてしまう。フレーバーなしで実行すると `Debug.xcconfig` が
使われ、`-t` が効く（バンドル ID は `com.wakamenod.apps.yamemo2` になる）。

## 未対応

- Android（Google Play）向けの素材は未整備。
