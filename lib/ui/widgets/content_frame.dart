import 'package:flutter/material.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';

/// 内容を中央に寄せ、幅を [AppSpacing.maxContentWidth] までに制限する。
///
/// iPhone では画面幅がこの上限より狭いので何も起きない。iPad のように
/// 横に広い画面でだけ効き、カードや入力欄が端から端まで伸びて
/// 間延びするのを防ぐ。
class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppSpacing.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
