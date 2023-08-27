// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yamemo2/app.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'flavors.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final zenMaruGothic =
        await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['zen_maru_gothic'], zenMaruGothic);
  });

  F.appFlavor = Flavor.kProd;
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  setupServiceLocator(initFuture);
  runApp(const App());
}
