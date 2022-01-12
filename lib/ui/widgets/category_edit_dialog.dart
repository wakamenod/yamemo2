import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/constants.dart';
import 'package:yamemo2/yamemo.i18n.dart';

class CategoryEditDialog extends StatefulWidget {
  const CategoryEditDialog(
      {Key? key,
      required this.model,
      required this.baseContext,
      required this.category})
      : super(key: key);

  final MemoScreenViewModel model;
  final BuildContext baseContext;
  final MemoCategory category;

  @override
  _CategoryEditDialogState createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryEditDialog> {
  late int selectedPosition;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedPosition = widget.category.sortNo;
    controller.text = widget.category.title;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Edit Category".i18n),
      children: [
        buildCategoryNameEdit(controller: controller),
        buildCategoryIndexEdit(
          position: selectedPosition,
          max: widget.model.categoryCount,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: widget.model.categoryCount <= 1
                      ? null
                      : () {
                          Navigator.of(widget.baseContext).pop(true);
                          showDeleteCategoryConfirmDialog(
                              context, widget.baseContext, widget.category);
                        },
                  child: Text(
                    "DELETE".i18n,
                    style: TextStyle(
                        color: widget.model.categoryCount <= 1
                            ? Colors.grey
                            : Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    widget.model
                        .updateCategory(controller.text, selectedPosition)
                        .catchError((e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Unexpected Error.".i18n),
                          backgroundColor: Colors.redAccent));
                    }).whenComplete(() {
                      Navigator.of(widget.baseContext).pop(true);
                    });
                  },
                  child: Text("EDIT".i18n)),
            ],
          ),
        )
      ],
    );
  }

  Widget buildCategoryNameEdit({required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(child: Text("Name: ".i18n)),
          SizedBox(
            width: 150,
            child: TextField(
                autofocus: true,
                textAlign: TextAlign.center,
                controller: controller,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kBaseColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kBaseColor),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: kBaseColor),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryIndexEdit({required int max, required int position}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(child: Text("Position: ".i18n)),
          SizedBox(
              width: 150,
              child: SpinBox(
                onChanged: (val) => {selectedPosition = val.toInt()},
                value: position.toDouble(),
                max: max.toDouble(),
                min: 1,
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none),
              )),
        ],
      ),
    );
  }

  Future showDeleteCategoryConfirmDialog(
      BuildContext ctx, BuildContext baseCtx, MemoCategory category) async {
    return await showDialog(
        context: ctx,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Confirm".i18n),
            content: Text(
                "Are you sure you wish to delete this catgory and all memos in it?"
                    .i18n),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    SnackBar sb = SnackBar(
                        content: Text("Unexpected Error.".i18n),
                        backgroundColor: Colors.redAccent);
                    widget.model
                        .deleteCategory(category)
                        .then((value) {
                          sb = SnackBar(content: Text("Deleted".i18n));
                        })
                        .catchError((e) {})
                        .whenComplete(() {
                          ScaffoldMessenger.of(context).showSnackBar(sb);
                          Navigator.of(dialogContext).pop(true);
                        });
                  },
                  child: Text("DELETE".i18n)),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text("CANCEL".i18n),
              ),
            ],
          );
        });
  }
}
