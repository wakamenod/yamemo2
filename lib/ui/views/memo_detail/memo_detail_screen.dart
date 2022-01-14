import 'package:flutter/material.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'memo_detail_screen_state.dart';

enum ScreenType {
  add,
  update,
}

class MemoDetailScreen extends StatefulWidget {
  static const String id = 'detail';
  final MemoScreenViewModel model;
  final ScreenType screenType;

  const MemoDetailScreen(
      {Key? key, required this.model, required this.screenType})
      : super(key: key);

  @override
  MemoDetailScreenState createState() => MemoDetailScreenState();
}
