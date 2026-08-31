// ignore_for_file: file_names, avoid_print

/// App Store 用スクリーンショット撮影専用のエントリポイント。
///
/// 製品ビルドには含まれない（このファイルを -t に指定したときだけ使われる）。
///
///   `flutter run --flavor prod -t lib/main-screenshot.dart -d <simulator udid>`
///
/// 通常の起動と違う点:
///   * サンプルのメモを流し込む（空の一覧を撮っても仕方がないため）
///   * 広告を初期化しない。テスト広告の "Test Ad" が写り込むのを避ける
///   * デバッグバナーとフレーバーバナーを出さない
///   * 一覧 → 詳細 → バックアップ の順に自動で遷移し、各画面で
///     `SCREENSHOT_READY:<名前>` を標準出力に出す。撮影スクリプトはこの行を
///     見てから `xcrun simctl io <udid> screenshot` を叩く。
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/flavors.dart';
import 'package:yamemo2/services/ads/google_mobile_ads_service.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/services/memo/memo_service_sqlite.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/theme/app_theme.dart';
import 'package:yamemo2/ui/views/backup_screen.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/ui/views/memo_list_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  LicenseRegistry.addLicense(() async* {
    final zenMaruGothic = await rootBundle.loadString(
      'assets/google_fonts/OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['zen_maru_gothic'], zenMaruGothic);
  });

  F.appFlavor = Flavor.kProd;
  WidgetsFlutterBinding.ensureInitialized();

  // 広告は初期化しない。完了しない Future を渡すことで BannerAd が作られず、
  // 一覧画面の広告枠は高さだけ確保した空欄になる。
  final neverInitialized = Completer<InitializationStatus>().future;
  serviceLocator.registerLazySingleton<MemoService>(() => MemoServiceSQLite());
  serviceLocator.registerLazySingleton<GoogleMobileAdsService>(
    () => GoogleMobileAdsService(neverInitialized),
  );
  serviceLocator.registerLazySingleton<MemoScreenViewModel>(
    () => MemoScreenViewModel(),
  );

  await _seed();
  runApp(const ScreenshotApp());
  unawaited(_walkThrough());
}

/// 一覧が空だとスクリーンショットにならないので、初回だけサンプルを入れる。
Future<void> _seed() async {
  final service = serviceLocator<MemoService>();
  if ((await service.getAllMemos()).isNotEmpty) return;

  final categories = await service.getAllCategories(true);
  const titles = ['仕事', '買い物', 'アイデア'];
  for (var i = 0; i < categories.length && i < titles.length; i++) {
    categories[i].title = titles[i];
    await service.updateCategory(categories[i]);
  }
  var idx = categories.length;
  while (idx < titles.length) {
    await service.addCategory(
      MemoCategory(id: 0, title: titles[idx], memos: [], sortNo: 0),
    );
    idx++;
  }

  final refreshed = await service.getAllCategories(true);
  final work = refreshed[0].id;
  final shopping = refreshed.length > 1 ? refreshed[1].id : work;
  final ideas = refreshed.length > 2 ? refreshed[2].id : work;

  final samples = <int, List<String>>{
    work: [
      '週次ミーティングのメモ\n・リリースは来週の水曜\n・アイコンの差し替えは完了\n・レビュー担当を決める',
      '経費精算\n交通費と書籍代。月末までに提出する。',
      '読み返す資料\nドキュメントの 3 章から。設計の背景がまとまっている。',
    ],
    shopping: [
      '週末の買い物\n・牛乳\n・トマト缶 2 つ\n・コーヒー豆\n・洗剤',
      'コーヒー豆のメモ\n浅煎りが好み。前回のエチオピアが当たりだった。',
    ],
    ideas: [
      '思いついたこと\nカテゴリごとに色を付けられると探しやすいかもしれない。',
      'next\n読みたい本のリストをここに集める。',
    ],
  };

  for (final entry in samples.entries) {
    for (final content in entry.value) {
      await service.addMemo(Memo(categoryID: entry.key, content: content));
    }
  }
}

/// 撮りたい画面を順に開き、落ち着いたところで目印を出力する。
Future<void> _walkThrough() async {
  final model = serviceLocator<MemoScreenViewModel>();

  await Future<void>.delayed(const Duration(seconds: 3));
  _ready('list');
  await Future<void>.delayed(const Duration(seconds: 6));

  final memo = model.selectedCategory.memoCount > 0
      ? model.selectedCategory.getMemoAt(0)
      : null;
  if (memo != null) {
    model.selectMemo(memo);
    navigatorKey.currentState?.push(
      memoDetailRoute(navigatorKey.currentContext!, null),
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _ready('detail');
    await Future<void>.delayed(const Duration(seconds: 6));
    navigatorKey.currentState?.pop();
    model.deselectMemo();
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  navigatorKey.currentState?.pushNamed(BackupScreen.id);
  await Future<void>.delayed(const Duration(milliseconds: 900));
  _ready('backup');
}

void _ready(String name) => print('SCREENSHOT_READY:$name');

/// 撮影用の [MaterialApp]。
///
/// 本番の [App] との違いはバナー 2 種を出さないことだけ。テーマ・ルート・
/// ローカライズは同じものを使う。
class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return I18n(
      child: MaterialApp(
        title: 'YAMemo',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: I18n.locale,
        theme: AppTheme.light,
        routes: {
          MemoListScreen.id: (context) => const MemoListScreen(),
          BackupScreen.id: (context) => const BackupScreen(),
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('ja', 'JP')],
        home: const MemoListScreen(),
      ),
    );
  }
}
