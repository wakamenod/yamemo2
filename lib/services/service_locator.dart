import 'package:get_it/get_it.dart';
import 'package:yamemo2/services/memo/memo_service.dart';
import 'package:yamemo2/business_logic/view_models/memo_screen_viewmodel.dart';
import 'package:yamemo2/services/memo/memo_service_sqlite.dart';
// todo
// import 'admob/admob_service.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // serviceLocator.registerLazySingleton<MemoService>(() => MemoServiceFake());
  serviceLocator.registerLazySingleton<MemoService>(() => MemoServiceSQLite());
  // todo
  // serviceLocator.registerLazySingleton<AdMobService>(() => AdMobService());

  serviceLocator
      .registerFactory<MemoScreenViewModel>(() => MemoScreenViewModel());
}
