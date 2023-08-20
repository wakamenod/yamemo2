import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yamemo2/constants.dart';

import 'package:yamemo2/services/ads/google_mobile_ads_service.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:yamemo2/ui/views/memo_detail/memo_detail_screen.dart';
import 'package:yamemo2/ui/widgets/category_tab_bar.dart';
import 'package:yamemo2/ui/widgets/category_memo_list.dart';

import 'package:yamemo2/utils/log.dart';

class MemoListScreen extends StatefulWidget {
  static const id = 'list';

  const MemoListScreen({Key? key}) : super(key: key);

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

  static Route<Object?> _memoDetailNavigation(
          BuildContext context, Object? argument) =>
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const MemoDetailScreen(),
        transitionDuration: const Duration(seconds: 0),
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoScreenViewModel>(
      create: (context) => _model,
      child: Consumer<MemoScreenViewModel>(builder: (context, value, child) {
        LOG.info('build memo list. isLoading=${value.isLoading}');
        if (value.isLoading) {
          return Container(
            color: kBaseBgColor,
          );
        }
        return Scaffold(
          appBar: AppBar(
              elevation: 0.0,
              backgroundColor: kBaseColor,
              bottom: CategoryTabBar()),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton(
                backgroundColor: kBaseColor,
                child: const Icon(Icons.add),
                onPressed: () async {
                  Navigator.restorablePush(
                    context,
                    _memoDetailNavigation,
                  );
                }),
          ),
          body: Column(
            children: [
              Expanded(child: CategoryMemoList()),
              createAd(),
            ],
          ),
        );
      }),
    );
  }

  Widget createAd() {
    final bannerAd = _bannerAd;
    return bannerAd == null || !_bannerAdIsLoaded
        ? const SizedBox(height: 50)
        : SizedBox(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd));
  }
}
