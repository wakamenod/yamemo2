import 'package:flutter/material.dart';
import 'memo_detail_screen_state.dart';

enum ScreenType {
  add,
  update,
}

class MemoDetailScreen extends StatefulWidget {
  static const String id = 'detail';
  final ScreenType screenType;

  const MemoDetailScreen({Key? key, required this.screenType})
      : super(key: key);

  @override
  MemoDetailScreenState createState() => MemoDetailScreenState();
}
