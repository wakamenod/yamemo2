import 'package:flutter/material.dart';
import 'package:yamemo2/yamemo.i18n.dart';
import 'package:yamemo2/constants.dart';

class AddCategoryScreen extends StatelessWidget {
  final Function(String) onAddCateogry;
  AddCategoryScreen({Key? key, required this.onAddCateogry}) : super(key: key);

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff757575),
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
                onAddCateogry(_controller.text);
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
    );
  }
}
