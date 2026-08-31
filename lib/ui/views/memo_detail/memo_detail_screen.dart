import 'package:flutter/material.dart';
import 'memo_detail_screen_state.dart';

class MemoDetailScreen extends StatefulWidget {
  static const String id = 'detail';

  const MemoDetailScreen({super.key});

  @override
  MemoDetailScreenState createState() => MemoDetailScreenState();
}

/// メモ詳細への遷移ルート。
///
/// `Navigator.restorablePush` に渡すため、**トップレベル関数のまま**にすること。
/// クロージャ化すると状態復元（[RestorationMixin]）が壊れる。
Route<Object?> memoDetailRoute(BuildContext context, Object? arguments) {
  return PageRouteBuilder<Object?>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const MemoDetailScreen(),
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
