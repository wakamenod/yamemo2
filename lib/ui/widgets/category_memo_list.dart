import 'package:flutter/material.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/ui/widgets/empty_memo_view.dart';
import 'package:yamemo2/ui/widgets/memo_list_tile.dart';
import 'package:yamemo2/utils/log.dart';
import 'package:yamemo2/yamemo.i18n.dart';

class CategoryMemoList extends StatelessWidget {
  final _model = serviceLocator<MemoScreenViewModel>();

  CategoryMemoList({super.key});

  @override
  Widget build(BuildContext context) {
    LOG.info('build isloading = ${_model.isLoading}');
    if (_model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final category = _model.selectedCategory;
    if (category.memoCount == 0) {
      return const EmptyMemoView();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.listBottomInset,
      ),
      itemCount: category.memoCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext ctx, int idx) {
        final Memo memo = category.getMemoAt(idx);

        return Dismissible(
          key: Key(memo.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => confirmDismissMemo(context, memo),
          background: const MemoDismissBackground(),
          child: MemoListTile(
            memo: memo,
            onTap: () {
              _model.selectMemo(memo);
              Navigator.restorablePush(context, memoDetailRoute);
            },
          ),
        );
      },
    );
  }

  Future<bool> confirmDismissMemo(BuildContext ctx, Memo memo) async {
    return await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm".i18n),
          content: Text("Are you sure you wish to delete this memo?".i18n),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("CANCEL".i18n),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                var isError = false;
                _model
                    .deleteMemo(memo)
                    .catchError((e) {
                      isError = true;
                    })
                    .whenComplete(() {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(snackBarWhenComplete(context, isError));
                      Navigator.of(context).pop(true);
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
