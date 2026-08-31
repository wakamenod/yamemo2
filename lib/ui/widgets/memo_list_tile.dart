import 'package:flutter/material.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/ui/theme/app_colors.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/yamemo.i18n.dart';

/// [Memo] にタイトル用のフィールドは無いので、本文から導出する。
///
/// 最初の空でない行をタイトル、それ以降をプレビューとして扱う。
({String title, String preview}) splitMemoContent(String content) {
  final lines = content.split('\n');
  final titleIndex = lines.indexWhere((line) => line.trim().isNotEmpty);
  if (titleIndex < 0) {
    return (title: '', preview: '');
  }

  final rest = lines
      .sublist(titleIndex + 1)
      .join('\n')
      .trim()
      // 本文中の空行は、限られた 2 行のプレビューでは無駄なので詰める。
      .replaceAll(RegExp(r'\n\s*\n+'), '\n');

  return (title: lines[titleIndex].trim(), preview: rest);
}

/// メモ一覧の 1 行。
///
/// 旧実装は本文を `ListTile.leading`（アイコン用の狭い枠）に入れており、
/// テキストが潰れる原因になっていた。ここでは自前の Column で
/// タイトルとプレビューの階層を作る。
class MemoListTile extends StatelessWidget {
  const MemoListTile({super.key, required this.memo, required this.onTap});

  final Memo memo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = splitMemoContent(memo.content);
    final isEmpty = parts.title.isEmpty;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppRadius.mediumAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumAll,
        child: Ink(
          // Dismissible は内部の Stack から loose constraints を渡してくるので、
          // 明示しないとカードが内容の幅に縮んでしまう。
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: AppRadius.mediumAll,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEmpty ? 'Untitled'.i18n : parts.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isEmpty
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontStyle: isEmpty ? FontStyle.italic : null,
                  ),
                ),
                if (parts.preview.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    parts.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// スワイプ削除時にカードの下から現れる背景。
///
/// カードと同じ角丸にしないと、スワイプ中に角のズレが見えてしまう。
class MemoDismissBackground extends StatelessWidget {
  const MemoDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.danger,
        borderRadius: AppRadius.mediumAll,
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'DELETE'.i18n,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
