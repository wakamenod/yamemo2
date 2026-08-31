# App Store 提出用の素材

## スクリーンショット

| ディレクトリ | 撮影に使う端末 | 解像度 | App Store Connect のスロット |
| --- | --- | --- | --- |
| `screenshots/iphone-6.9` | iPhone 17 Pro Max | 1320 × 2868 | 6.9 インチディスプレイ |
| `screenshots/iphone-6.5` | iPhone 14 Plus | 1284 × 2778 | 6.5 インチディスプレイ |
| `screenshots/ipad-13` | iPad Pro 13-inch (M5) | 2064 × 2752 | 13 インチディスプレイ |

スロットごとに受け付ける寸法が違い、6.9 インチ用の 1320 × 2868 を
6.5 インチのスロットに入れると「寸法が正しくありません」と警告が出る
（6.5 インチが受け付けるのは 1242 × 2688 か 1284 × 2778）。
どのスロットが表示されるかは App Store Connect 側の仕様変更で変わるので、
最終的には画面の表示に従うこと。

6.5 インチ用のシミュレータは既定では入っていないので、必要なら作る:

```sh
xcrun simctl create "YAMemo Shot 6.5" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus \
  com.apple.CoreSimulator.SimRuntime.iOS-26-5
```

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
