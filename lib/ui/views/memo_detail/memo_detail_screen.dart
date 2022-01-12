import 'package:flutter/material.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/ui/views/memo_detail/update_memo_state.dart';
import 'add_memo_state.dart';
import 'memo_detail_screen_state.dart';

class MemoDetailScreen extends StatefulWidget {
  static const String id = 'detail';
  final MemoScreenViewModel model;

  const MemoDetailScreen({Key? key, required this.model}) : super(key: key);

  @override
  MemoDetailScreenState createState() {
    return model.selectedMemo == null
        ? AddMemoState(model)
        : UpdateMemoState(model);
  }
}
