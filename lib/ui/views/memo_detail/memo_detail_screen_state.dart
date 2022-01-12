import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/constants.dart';
import 'package:yamemo2/ui/views/add_category_screen.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/yamemo.i18n.dart';

abstract class MemoDetailScreenState extends State<MemoDetailScreen> {
  final TextEditingController controller = TextEditingController();
  final MemoScreenViewModel model;

  MemoDetailScreenState({required this.model});

  void onTapDone();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: Consumer<MemoScreenViewModel>(builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: kBaseColor,
            actions: <Widget>[
              // todo key
              DoneEditButton(UniqueKey(), () => onTapDone()),
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
                        Text('${value.selectedCategory!.title} '),
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
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: null,
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
            validator: (value) =>
                value!.isNotEmpty ? null : 'content can\'t be empty',
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
                Navigator.pop(context);
              },
              child: Text(model.getCategoryAt(index).title),
            ));

    res.add(SimpleDialogOption(
        child: Text('Add New Category'.i18n),
        onPressed: () async {
          await showModalBottomSheet<String>(
              context: context,
              builder: (context) => AddCategoryScreen(
                    onAddCateogry: (newCategory) {
                      model.addCategory(newCategory).catchError((e) {
                        Fluttertoast.showToast(
                            msg: "Unexpected Error.".i18n,
                            backgroundColor: Colors.redAccent);
                      });
                    },
                  ));
          Navigator.pop(context);
        }));

    return res;
  }
}

class DoneEditButton extends StatelessWidget {
  final Function _onTapDone;

  const DoneEditButton(Key? key, this._onTapDone) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        child: const Icon(Icons.check),
        onTap: () {
          _onTapDone();
          Navigator.pop(context);
        },
      ),
    );
  }
}
