import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yamemo2/flavors.dart';
import 'package:yamemo2/utils/log.dart';

class GoogleMobileAdsService {
  Future<InitializationStatus> initialization;
  GoogleMobileAdsService(this.initialization);
  String get bannerAdUnitId =>
      Platform.isAndroid ? F.androidAdUnitID : F.iOSAdUnitID;
  BannerAdListener get adListener => _adListener;
  final BannerAdListener _adListener = BannerAdListener(
    onAdLoaded: (ad) => LOG.info('Ad loaded: ${ad.adUnitId}.'),
    onAdClosed: (ad) => LOG.info('Ad closed: ${ad.adUnitId}.'),
    onAdFailedToLoad: (ad, error) =>
        LOG.info('Ad failed to load: ${ad.adUnitId}, $error.'),
    onAdOpened: (ad) => LOG.info('Ad opened: ${ad.adUnitId}.'),
  );
}
