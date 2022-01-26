import 'package:flutter/material.dart';
import 'package:yamemo2/business_logic/models/memo.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/constants.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/utils/log.dart';
import 'package:yamemo2/yamemo.i18n.dart';

class CategoryMemoList extends StatelessWidget {
  const CategoryMemoList(Key? key, this._model) : super(key: key);

  final MemoScreenViewModel _model;

  static Route<Object?> _memoDetailNavigation(
          BuildContext context, Object? argument) =>
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const MemoDetailScreen(
          screenType: ScreenType.add,
        ),
        transitionDuration: const Duration(seconds: 0),
      );

  @override
  Widget build(BuildContext context) {
    LOG.info('build isloading = ${_model.isLoading}');
    if (_model.isLoading) {
      return Container(
        color: kBaseBgColor,
      );
    }

    final category = _model.selectedCategory;
    return Container(
      color: kBaseBgColor,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: category.memoCount,
          itemBuilder: (BuildContext ctx, int idx) {
            final Memo memo = category.getMemoAt(idx);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Dismissible(
                  confirmDismiss: (direction) =>
                      confirmDismissMemo(context, memo),
                  key: Key(memo.id.toString()),
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    ),
                  ),
                  child: GestureDetector(
                      onTap: () async {
                        _model.selectMemo(memo);
                        Navigator.restorablePush(
                          context,
                          _memoDetailNavigation,
                        );
                        _model.deselectMemo();
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0))),
                        child: ListTile(
                            leading: Text(
                          memo.content,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 14.0, height: 1.0),
                          strutStyle: const StrutStyle(
                            fontSize: 14.0,
                            height: 0.2,
                          ),
                        )),
                      ))),
            );
          }),
    );
  }

  Future<bool> confirmDismissMemo(ctx, memo) async {
    return await showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm".i18n),
            content: Text("Are you sure you wish to delete this memo?".i18n),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    var isError = false;
                    _model.deleteMemo(memo).catchError((e) {
                      isError = true;
                    }).whenComplete(() {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(snackBarWhenComplete(isError));
                      Navigator.of(context).pop(true);
                    });
                  },
                  child: Text("DELETE".i18n)),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("CANCEL".i18n),
              ),
            ],
          );
        });
  }

  SnackBar snackBarWhenComplete(bool isError) {
    return isError
        ? SnackBar(
            content: Text("Unexpected Error.".i18n),
            backgroundColor: Colors.redAccent)
        : SnackBar(content: Text("Deleted".i18n));
  }
}
