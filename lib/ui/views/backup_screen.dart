import 'package:flutter/material.dart';
import 'package:yamemo2/constants.dart';
import 'package:yamemo2/yamemo.i18n.dart';

class BackupScreen extends StatefulWidget {
  static const id = 'backup';

  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kBaseColor,
        title: Text('Backup'.i18n),
      ),
      body: Container(
        color: kBaseBgColor,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup description'.i18n,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
