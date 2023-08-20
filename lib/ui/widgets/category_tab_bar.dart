import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:yamemo2/business_logic/models/memo_category.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/constants.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/yamemo.i18n.dart';

import 'category_edit_dialog.dart';

class CategoryTabBar extends StatelessWidget implements PreferredSizeWidget {
  final _model = serviceLocator<MemoScreenViewModel>();

  CategoryTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(_model.categoryCount, (int index) {
          var category = _model.getCategoryAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onLongPress: () => showCategoryEditDialog(context, index),
              onTap: () => _model.selectCategoryAt(index),
              child: Container(
                decoration: _model.isSelectedCategory(category)
                    ? selectedDeco
                    : unselectedDeco,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 35.0,
                child: Center(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _model.isSelectedCategory(category)
                          ? kBaseColor
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(7.0);
  }

  Decoration get selectedDeco {
    return const BoxDecoration(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      color: kBaseBgColor,
    );
  }

  Decoration get unselectedDeco {
    return const BoxDecoration(
        // color: kBaseColor
        );
  }

  Future showCategoryEditDialog(BuildContext ctx, int idx) async {
    _model.selectCategoryAt(idx);
    MemoCategory category = _model.getCategoryAt(idx);

    return await showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return CategoryEditDialog(
            baseContext: ctx,
            category: category,
          );
        });
  }
}

class CategoryIndexEdit extends StatelessWidget {
  const CategoryIndexEdit({Key? key, required this.max, required this.position})
      : super(key: key);

  final int max;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(child: Text("Position: ".i18n)),
          SizedBox(
              width: 150,
              child: SpinBox(
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
}

class CategoryNameEdit extends StatelessWidget {
  const CategoryNameEdit({Key? key, required this.controller})
      : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
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
}
