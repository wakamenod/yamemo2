import 'package:flutter/material.dart';
import 'package:yamemo2/yamemo.i18n.dart';
import 'package:yamemo2/constants.dart';

class AddCategoryScreen extends StatefulWidget {
  final Function(String) onAddCateogry;
  const AddCategoryScreen({Key? key, required this.onAddCateogry})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Category'.i18n,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30.0, color: kBaseColor),
              ),
              TextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  controller: _controller,
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
              TextButton(
                style: TextButton.styleFrom(backgroundColor: kBaseColor),
                onPressed: () {
                  widget.onAddCateogry(_controller.text);
                  Navigator.pop(context, _controller.text);
                },
                child: Text(
                  'Add'.i18n,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
