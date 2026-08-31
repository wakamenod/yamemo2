import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:yamemo2/services/ads/google_mobile_ads_service.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:yamemo2/ui/theme/app_spacing.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/ui/views/backup_screen.dart';
import 'package:yamemo2/ui/widgets/category_tab_bar.dart';
import 'package:yamemo2/ui/widgets/category_memo_list.dart';
import 'package:yamemo2/yamemo.i18n.dart';

import 'package:yamemo2/utils/log.dart';

/// 広告が未ロードのときも同じ高さを確保して、レイアウトが飛ぶのを防ぐ。
const _adSlotHeight = 50.0;

class MemoListScreen extends StatefulWidget {
  static const id = 'list';

  const MemoListScreen({super.key});

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen>
    with TickerProviderStateMixin {
  final _model = serviceLocator<MemoScreenViewModel>();
  BannerAd? _bannerAd;
  bool _bannerAdIsLoaded = false;

  @override
  void initState() {
    _model.loadData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ads = serviceLocator<GoogleMobileAdsService>();
    ads.initialization.then((status) {
      setState(() {
        _bannerAd = BannerAd(
          adUnitId: ads.bannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              LOG.info('$BannerAd loaded.');
              setState(() {
                _bannerAdIsLoaded = true;
              });
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              LOG.info('$BannerAd failedToLoad: $error');
              ad.dispose();
            },
            onAdOpened: (Ad ad) => LOG.info('$BannerAd onAdOpened.'),
            onAdClosed: (Ad ad) => LOG.info('$BannerAd onAdClosed.'),
          ),
        )..load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoScreenViewModel>(
      create: (context) => _model,
      child: Consumer<MemoScreenViewModel>(
        builder: (context, value, child) {
          LOG.info('build memo list. isLoading=${value.isLoading}');
          if (value.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // NOTE: CategoryTabBar / CategoryMemoList は Provider を購読せず
          // serviceLocator から直接 ViewModel を掴んでいる。この Consumer の
          // builder 内で毎回生成すること。const 化したり Consumer の child:
          // に退避すると UI が古いデータのまま固まる。
          return Scaffold(
            appBar: AppBar(
              title: const Text('YAMemo'),
              bottom: CategoryTabBar(),
            ),
            drawer: _buildDrawer(context),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                Navigator.restorablePush(context, memoDetailRoute);
              },
              child: const Icon(Icons.add),
            ),
            // 広告を bottomNavigationBar に置くと Scaffold が FAB を自動で
            // その上にドッキングさせる（旧実装の margin: bottom 50 が不要になる）。
            bottomNavigationBar: _buildAdSlot(),
            body: CategoryMemoList(),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YAMemo', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  const _AppVersionLabel(),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: Text('Backup'.i18n),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, BackupScreen.id);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text('License'.i18n),
                    onTap: () async {
                      Navigator.pop(context); // Close the drawer
                      final packageInfo = await PackageInfo.fromPlatform();
                      if (context.mounted) {
                        showLicensePage(
                          context: context,
                          applicationName: packageInfo.appName,
                          applicationVersion: packageInfo.version,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdSlot() {
    final bannerAd = _bannerAd;
    if (bannerAd == null || !_bannerAdIsLoaded) {
      return const SizedBox(height: _adSlotHeight);
    }
    return SizedBox(
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        return Text(
          version == null ? '' : 'v$version',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}
