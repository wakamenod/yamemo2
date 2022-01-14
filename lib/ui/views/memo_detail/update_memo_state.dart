// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
// import 'package:yamemo2/yamemo.i18n.dart';
// import 'memo_detail_screen_state.dart';

// class UpdateMemoState extends MemoDetailScreenState {
//   UpdateMemoState(MemoScreenViewModel model) : super(model: model);

//   @override
//   Widget build(BuildContext context) {
//     controller.text = model.selectedMemo.content;
//     return super.build(context);
//   }

//   @override
//   void onTapDone() {
//     model.updateSelectedMemo(controller.text).catchError((e) {
//       Fluttertoast.showToast(
//           msg: "Unexpected Error.".i18n, backgroundColor: Colors.redAccent);
//     });
//   }
// }
