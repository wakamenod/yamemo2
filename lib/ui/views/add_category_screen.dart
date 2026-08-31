import 'package:flutter/material.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/yamemo.i18n.dart';

class AddCategoryScreen extends StatefulWidget {
  final Function(String) onAddCateogry;
  const AddCategoryScreen({super.key, required this.onAddCateogry});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    widget.onAddCateogry(title);
    Navigator.pop(context, title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 旧実装は高さを画面の 80% に固定していて、テキストフィールド 1 つに対して
    // 白い余白が大量に余っていた。内容の高さ＋キーボード分だけを取る。
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add New Category'.i18n, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                autofocus: true,
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(hintText: 'Category'.i18n),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: _submit, child: Text('Add'.i18n)),
            ],
          ),
        ),
      ),
    );
  }
}
