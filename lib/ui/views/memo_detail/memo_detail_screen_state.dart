import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/constants.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/ui/views/add_category_screen.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/yamemo.i18n.dart';

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

  void Function() getSaveFn() {
    if (!_model.isMemoSelected()) {
      return () async {
        try {
          final newMemo = await _model.addMemo(controller.value.text);
          _model.updateWritingMemoRecord(newMemo.id ?? 0);
          _model.selectMemo(newMemo);
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Unexpected Error.".i18n, backgroundColor: Colors.redAccent);
        }
      };
    }

    return () async {
      try {
        _model.updateWritingMemoRecord(_model.selectedMemo.id ?? 0);
        _model.updateSelectedMemo(controller.value.text);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Unexpected Error.".i18n, backgroundColor: Colors.redAccent);
      }
    };
  }

  static void popDetailPage(BuildContext context, MemoScreenViewModel model) {
    model.deselectMemo();
    Navigator.pop(context);
  }

  @override
  void dispose() {
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
      child: Consumer<MemoScreenViewModel>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: kBaseColor,
            leading: BackButton(
              onPressed: () {
                popDetailPage(context, _model);
              },
            ),
            actions: <Widget>[
              DoneEditButton(model: _model, onTapDone: () => getSaveFn()),
            ],
          ),
          body: Container(
            color: kBaseBgColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13, top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => buildDialog(value, context),
                      );
                    },
                    child: Row(
                      children: [
                        Text('${value.selectedCategory.title} '),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                buildContentForm(),
              ],
            ),
          ),
        );
      }),
    );
  }

  _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getSaveFn().call();
    });
  }

  Widget buildContentForm() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 18.0),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            textAlignVertical: TextAlignVertical.top,
            controller: controller.value,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: null,
            onChanged: _onTextChanged,
            // maxLength: 512,
            // maxLengthEnforced: true,
            //initialValue: _content,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: -10.0, horizontal: 5.0),
              isDense: true,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              labelText: '',
              hintText: 'Enter content',
              alignLabelWithHint: true,
              labelStyle:
                  TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
            validator: (value) => (value != null && value.isNotEmpty)
                ? null
                : 'content can\'t be empty',
            style: const TextStyle(fontSize: 20.0, color: Colors.black87),
            // onChanged: (content) => _content = content,
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

  List<SimpleDialogOption> dialogOptions(
      MemoScreenViewModel model, BuildContext context) {
    var res = List<SimpleDialogOption>.generate(
        model.categoryCount,
        (index) => SimpleDialogOption(
              onPressed: () async {
                model.selectCategoryAt(index);
                popDetailPage(context, model);
              },
              child: Text(model.getCategoryAt(index).title),
            ));

    res.add(SimpleDialogOption(
        child: Text('Add New Category'.i18n),
        onPressed: () async {
          await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddCategoryScreen(
                    onAddCateogry: (newCategory) {
                      model.addCategory(newCategory).catchError((e) {
                        Fluttertoast.showToast(
                            msg: "Unexpected Error.".i18n,
                            backgroundColor: Colors.redAccent);
                      });
                    },
                  ));
          if (context.mounted) {
            Navigator.pop(context);
          }
        }));

    return res;
  }

  @override
  String? get restorationId => 'memo_detail';

  @override
  Future<void> restoreState(
      RestorationBucket? oldBucket, bool initialRestore) async {
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

class DoneEditButton extends StatelessWidget {
  final Function onTapDone;
  final MemoScreenViewModel model;

  const DoneEditButton({Key? key, required this.onTapDone, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        child: const Icon(Icons.check),
        onTap: () {
          onTapDone();
          MemoDetailScreenState.popDetailPage(context, model);
        },
      ),
    );
  }
}
