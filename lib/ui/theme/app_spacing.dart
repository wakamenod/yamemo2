import 'package:flutter/material.dart';

/// 余白のスケール。4 の倍数で刻む。
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// 一覧の最下部に確保する余白。FAB と広告バナーに最後の行が隠れないように。
  static const listBottomInset = 96.0;
}

/// 角丸のスケール。画面ごとにバラバラだった値をここに集約する。
abstract final class AppRadius {
  static const s = 8.0;
  static const m = 12.0;
  static const l = 20.0;

  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(s));
  static const BorderRadius mediumAll = BorderRadius.all(Radius.circular(m));
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(l));

  /// ボトムシート用の上だけ丸い角。
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(l),
    topRight: Radius.circular(l),
  );
}
