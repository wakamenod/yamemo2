import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/memo/memo_service_sqlite.dart';

import 'ads/google_mobile_ads_service.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator(Future<InitializationStatus> adsInitFuture) {
  // serviceLocator.registerLazySingleton<MemoService>(() => MemoServiceFake());
  serviceLocator.registerLazySingleton<MemoService>(() => MemoServiceSQLite());
  serviceLocator.registerLazySingleton<GoogleMobileAdsService>(
      () => GoogleMobileAdsService(adsInitFuture));

  serviceLocator
      .registerFactory<MemoScreenViewModel>(() => MemoScreenViewModel());
}
