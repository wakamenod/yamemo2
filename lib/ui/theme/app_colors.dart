import 'package:flutter/material.dart';

/// アプリのカラートークン。
///
/// 色を直接ウィジェットに書かないこと。ここか [ColorScheme] 経由で参照する。
/// ダークモードは現状サポートしていないが、将来対応できるよう
/// 参照はすべて [Theme.of] 経由に寄せてある。
abstract final class AppColors {
  /// ブランドのオレンジ。塗り（FAB・選択タブ・FilledButton）専用。
  ///
  /// 明るいので **文字色として使ってはいけない**（白背景でコントラスト比 2:1）。
  /// 明るい面の上に文字やアイコンとして置く場合は [brandInk] を使う。
  static const brand = Color(0xFFE58A2D);

  /// [brand] の上に置く文字・アイコンの色。
  ///
  /// 白は [brand] に対して 2.6:1 しか出ず WCAG AA（4.5:1）を満たさない。
  /// オレンジを保ったまま基準を満たすため、白ではなく暖色の濃茶を載せる。
  /// 対 [brand] で 5.2:1。
  static const onBrand = Color(0xFF3D2A12);

  /// 明るい面の上に置くオレンジの文字・アイコン用。
  /// 白で 5.7:1、[background] で 5.3:1、[brandSoft] で 4.9:1。
  static const brandInk = Color(0xFF9E5310);

  /// オレンジの淡い面（選択中のうっすらした背景など）。
  static const brandSoft = Color(0xFFFDEBD6);

  /// アプリ全体の地。従来のベージュより明度を上げて濁りを取ったもの。
  static const background = Color(0xFFFAF6F0);

  /// カード・シート・AppBar などの前面。
  static const surface = Color(0xFFFFFFFF);

  /// 本文色（暖色寄りのニアブラック）。
  static const ink = Color(0xFF2B2521);

  /// 補助テキスト。[background] の上で 4.8:1、[surface] の上で 5.2:1。
  static const inkMuted = Color(0xFF756B64);

  /// カードの境界に使うヘアライン。
  static const hairline = Color(0xFFE8E1D6);

  static const danger = Color(0xFFB3261E);

  /// モーダル背後のスクリム。
  static const scrim = Color(0x66000000);

  static final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: brand,
        brightness: Brightness.light,
      ).copyWith(
        primary: brand,
        onPrimary: onBrand,
        primaryContainer: brandSoft,
        onPrimaryContainer: brandInk,
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: inkMuted,
        outlineVariant: hairline,
        error: danger,
        onError: Colors.white,
      );
}
