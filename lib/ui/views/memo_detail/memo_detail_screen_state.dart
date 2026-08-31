import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/ui/views/add_category_screen.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/yamemo.i18n.dart';
import 'package:yamemo2/utils/log.dart';

import '../../../business_logic/models/memo.dart';

class MemoDetailScreenState extends State<MemoDetailScreen>
    with RestorationMixin {
  final RestorableTextEditingController controller =
      RestorableTextEditingController();
  final _model = serviceLocator<MemoScreenViewModel>();
  Timer? _debounce;

  MemoDetailScreenState();

  @override
  void initState() {
    super.initState();
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'Unexpected Error.'.i18n}\n$error'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void Function() getSaveFn() {
    if (!_model.isMemoSelected()) {
      return () async {
        try {
          final newMemo = await _model.addMemo(controller.value.text);
          _model.updateWritingMemoRecord(newMemo.id ?? 0);
          _model.selectMemo(newMemo);
        } catch (e) {
          LOG.info('Error saving memo: $e');
          _showError(e);
        }
      };
    }

    return () async {
      try {
        _model.updateWritingMemoRecord(_model.selectedMemo.id ?? 0);
        _model.updateSelectedMemo(controller.value.text);
      } catch (e) {
        LOG.info('Error saving memo: $e');
        _showError(e);
      }
    };
  }

  static void popDetailPage(BuildContext context, MemoScreenViewModel model) {
    model.deselectMemo();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isMemoSelected()) {
      controller.value.text = _model.selectedMemo.content;
    }
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<MemoScreenViewModel>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  popDetailPage(context, _model);
                },
              ),
              actions: <Widget>[
                DoneEditButton(model: _model, onTapDone: () => getSaveFn()),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: _CategoryPickerButton(
                    title: value.selectedCategory.title,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => buildDialog(value, context),
                      );
                    },
                  ),
                ),
                buildContentForm(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getSaveFn().call();
    });
  }

  Widget buildContentForm() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mediumAll,
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: TextFormField(
            textAlignVertical: TextAlignVertical.top,
            controller: controller.value,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: null,
            expands: false,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              // NOTE: 旧実装は contentPadding に負の値を入れていた。
              // 余白は外側の Container が持つのでここはゼロにする。
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Enter content'.i18n,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget buildDialog(MemoScreenViewModel model, BuildContext context) {
    return SimpleDialog(
      title: Text("Select Category".i18n),
      children: dialogOptions(model, context),
    );
  }

  List<Widget> dialogOptions(MemoScreenViewModel model, BuildContext context) {
    final theme = Theme.of(context);
    final selectedID = model.selectedCategory.id;

    var res = List<Widget>.generate(model.categoryCount, (index) {
      final category = model.getCategoryAt(index);
      final isSelected = category.id == selectedID;

      return SimpleDialogOption(
        onPressed: () async {
          model.selectCategoryAt(index);
          popDetailPage(context, model);
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      );
    });

    res.add(const Divider(height: AppSpacing.lg));
    res.add(
      SimpleDialogOption(
        onPressed: () => _addCategoryFromDialog(model, context),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('Add New Category'.i18n, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );

    return res;
  }

  Future<void> _addCategoryFromDialog(
    MemoScreenViewModel model,
    BuildContext context,
  ) async {
    // シートが閉じた後に発火しうるので、messenger は await の前に掴んでおく。
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddCategoryScreen(
        onAddCateogry: (newCategory) {
          model.addCategory(newCategory).catchError((e) {
            messenger.showSnackBar(
              SnackBar(
                content: Text("Unexpected Error.".i18n),
                backgroundColor: errorColor,
              ),
            );
          });
        },
      ),
    );
    if (!context.mounted) return;
    // カテゴリ選択ダイアログ自体を閉じる。
    Navigator.pop(context);
  }

  @override
  String? get restorationId => 'memo_detail';

  @override
  Future<void> restoreState(
    RestorationBucket? oldBucket,
    bool initialRestore,
  ) async {
    registerForRestoration(controller, 'memo_detail_text');
    if (!initialRestore) {
      final writingMemo = _model.getMemoByID(await _model.getWritingMemoID());
      if (writingMemo != Memo.nullMemo) {
        _model.selectMemo(writingMemo);
        _model.selectCategoryByID(writingMemo.categoryID);
      }
    }
  }
}

/// 現在のカテゴリを示し、タップで変更できるボタン。
///
/// 旧実装は素の Text + 三角アイコンで、押せることが分からなかった。
class _CategoryPickerButton extends StatelessWidget {
  const _CategoryPickerButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: theme.colorScheme.primaryContainer,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.expand_more,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DoneEditButton extends StatelessWidget {
  final Function onTapDone;
  final MemoScreenViewModel model;

  const DoneEditButton({
    super.key,
    required this.onTapDone,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.check),
      tooltip: 'Done'.i18n,
      onPressed: () {
        onTapDone();
        MemoDetailScreenState.popDetailPage(context, model);
      },
    );
  }
}
