import 'package:flutter/material.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/ui/views/add_category_screen.dart';
import 'package:yamemo2/yamemo.i18n.dart';

import 'category_edit_dialog.dart';

const _tabHeight = 36.0;
const _tabBarHeight = _tabHeight + AppSpacing.sm + AppSpacing.md;

/// AppBar の bottom に置くカテゴリタブ。
///
/// 旧実装は [preferredSize] が 7.0 しか無いのに中身が 35.0 あり、
/// AppBar がタブを潰していた。高さは [_tabBarHeight] で一元管理する。
class CategoryTabBar extends StatefulWidget implements PreferredSizeWidget {
  CategoryTabBar({super.key});

  final _model = serviceLocator<MemoScreenViewModel>();

  @override
  Size get preferredSize => const Size.fromHeight(_tabBarHeight);

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  /// 選択中タブを画面内にスクロールさせるための、カテゴリ ID ごとのキー。
  final Map<int, GlobalKey> _tabKeys = {};

  /// 直近でスクロールを合わせたカテゴリ。選択が変わったときだけ動かす。
  int? _lastScrolledCategoryID;

  MemoScreenViewModel get _model => widget._model;

  @override
  Widget build(BuildContext context) {
    _scheduleScrollToSelected();

    return SizedBox(
      height: _tabBarHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            for (var index = 0; index < _model.categoryCount; index++)
              _buildCategoryTab(context, index),
            _buildAddTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, int index) {
    final category = _model.getCategoryAt(index);
    final isSelected = _model.isSelectedCategory(category);
    final theme = Theme.of(context);
    final key = _tabKeys.putIfAbsent(category.id, () => GlobalKey());

    return Padding(
      key: key,
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: _TabPill(
        isSelected: isSelected,
        onTap: () => _model.selectCategoryAt(index),
        onLongPress: () => showCategoryEditDialog(context, index),
        child: Text(
          category.title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAddTab(BuildContext context) {
    return _TabPill(
      isSelected: false,
      onTap: () => _showAddCategorySheet(context),
      child: Icon(
        Icons.add,
        size: 18.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _scheduleScrollToSelected() {
    final selectedID = _model.selectedCategory.id;
    if (selectedID == _lastScrolledCategoryID) return;
    _lastScrolledCategoryID = selectedID;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _tabKeys[selectedID]?.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    });
  }

  Future _showAddCategorySheet(BuildContext context) async {
    // シートが閉じた後に発火しうるので、messenger は await の前に掴んでおく。
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddCategoryScreen(
        onAddCateogry: (newCategory) {
          _model.addCategory(newCategory).catchError((e) {
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
  }

  Future showCategoryEditDialog(BuildContext ctx, int idx) async {
    _model.selectCategoryAt(idx);
    MemoCategory category = _model.getCategoryAt(idx);

    return await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return CategoryEditDialog(baseContext: ctx, category: category);
      },
    );
  }
}

/// 選択＝オレンジ塗り、非選択＝ヘアラインの枠のみ、という 1 種類の
/// 表現にタブを統一する。
class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: const StadiumBorder(),
        child: Ink(
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Container(
            height: _tabHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
