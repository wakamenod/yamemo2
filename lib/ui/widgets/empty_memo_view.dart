import 'package:flutter/material.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/yamemo.i18n.dart';

/// カテゴリにメモが 1 件も無いときの表示。
///
/// 旧実装ではただの空白が表示されていた。
class EmptyMemoView extends StatelessWidget {
  const EmptyMemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 56,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No memos yet'.i18n,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap the + button to add one.'.i18n,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
