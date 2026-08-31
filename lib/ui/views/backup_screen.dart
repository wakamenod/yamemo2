import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yamemo2/ui/theme/app_colors.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/yamemo.i18n.dart';
import 'package:yamemo2/utils/log.dart';

class BackupScreen extends StatefulWidget {
  static const id = 'backup';

  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _memoService = serviceLocator<MemoService>();
  bool _isLoading = false;

  void _notify(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Rect _getSharePositionOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final origin = box.localToGlobal(Offset.zero);
      return origin & box.size;
    }
    return Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, 100);
  }

  Future<void> _exportBackup(BuildContext shareContext) async {
    setState(() => _isLoading = true);
    try {
      final data = await _memoService.exportBackup();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(
        RegExp(r'[:]'),
        '-',
      );
      final filePath = '${tempDir.path}/yamemo_backup_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      if (!shareContext.mounted) return;
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'YAMemo Backup',
        sharePositionOrigin: _getSharePositionOrigin(shareContext),
      );

      // 一時ファイルを削除
      if (await file.exists()) {
        await file.delete();
      }

      _notify('Backup completed.'.i18n);
    } catch (e) {
      LOG.info('Error exporting backup: $e');
      _notify('${'Unexpected Error.'.i18n}\n$e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importBackup() async {
    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Restore'.i18n),
        content: Text(
          'All current data will be overwritten. Are you sure you want to restore?'
              .i18n,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'.i18n),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Restore'.i18n),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      _notify('Restore cancelled.'.i18n);
      return;
    }

    // ファイル選択
    const typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      uniformTypeIdentifiers: ['public.json'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file == null) {
      _notify('Restore cancelled.'.i18n);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      await _memoService.importBackup(data);

      // ViewModel を再読み込みしてUIに反映
      serviceLocator<MemoScreenViewModel>().loadData();

      _notify('Restore completed.'.i18n);
    } catch (e) {
      LOG.info('Error importing backup: $e');
      _notify(
        '${'Failed to restore. The file may be invalid.'.i18n}\n$e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backup'.i18n)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Backup description'.i18n,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                Builder(
                  builder: (btnContext) => FilledButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _exportBackup(btnContext),
                    icon: const Icon(Icons.backup_outlined),
                    label: Text('Create Backup'.i18n),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _importBackup,
                  icon: const Icon(Icons.restore),
                  label: Text('Restore from Backup'.i18n),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const ColoredBox(
              color: AppColors.scrim,
              child: SizedBox.expand(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
