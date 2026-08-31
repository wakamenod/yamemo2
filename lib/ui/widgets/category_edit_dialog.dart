import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/yamemo.i18n.dart';

class CategoryEditDialog extends StatefulWidget {
  const CategoryEditDialog({
    super.key,
    required this.baseContext,
    required this.category,
  });

  final BuildContext baseContext;
  final MemoCategory category;

  @override
  State<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryEditDialog> {
  late int selectedPosition;
  TextEditingController controller = TextEditingController();
  final _model = serviceLocator<MemoScreenViewModel>();

  @override
  void initState() {
    super.initState();
    selectedPosition = widget.category.sortNo;
    controller.text = widget.category.title;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDelete = _model.categoryCount > 1;

    return AlertDialog(
      title: Text("Edit Category".i18n),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Name: ".i18n, style: theme.textTheme.bodySmall),
          TextField(autofocus: true, controller: controller),
          const SizedBox(height: AppSpacing.lg),
          Text("Position: ".i18n, style: theme.textTheme.bodySmall),
          SpinBox(
            value: selectedPosition.toDouble(),
            max: _model.categoryCount.toDouble(),
            min: 1,
            onChanged: (val) => selectedPosition = val.toInt(),
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: canDelete
                ? theme.colorScheme.error
                : theme.disabledColor,
          ),
          onPressed: canDelete
              ? () {
                  Navigator.of(context).pop(true);
                  showDeleteCategoryConfirmDialog(
                    context,
                    widget.baseContext,
                    widget.category,
                  );
                }
              : null,
          child: Text("DELETE".i18n),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: () {
            _model
                .updateCategory(controller.text, selectedPosition)
                .catchError((e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Unexpected Error.".i18n),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                })
                .whenComplete(() {
                  if (!context.mounted) return;
                  Navigator.of(widget.baseContext).pop(true);
                });
          },
          child: Text("EDIT".i18n),
        ),
      ],
    );
  }

  Future showDeleteCategoryConfirmDialog(
    BuildContext ctx,
    BuildContext baseCtx,
    MemoCategory category,
  ) async {
    return await showDialog(
      context: ctx,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirm".i18n),
          content: Text(
            "Are you sure you wish to delete this catgory and all memos in it?"
                .i18n,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text("CANCEL".i18n),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () {
                var isError = false;
                _model
                    .deleteCategory(category)
                    .catchError((e) {
                      isError = true;
                    })
                    .whenComplete(() {
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(true);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        snackBarWhenComplete(dialogContext, isError),
                      );
                    });
              },
              child: Text("DELETE".i18n),
            ),
          ],
        );
      },
    );
  }

  SnackBar snackBarWhenComplete(BuildContext context, bool isError) {
    return isError
        ? SnackBar(
            content: Text("Unexpected Error.".i18n),
            backgroundColor: Theme.of(context).colorScheme.error,
          )
        : SnackBar(content: Text("Deleted".i18n));
  }
}
