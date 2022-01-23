// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yamemo2/main.dart';
import 'package:yamemo2/services/service_locator.dart';
import 'flavors.dart';

void main() {
  F.appFlavor = Flavor.kDev;
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  setupServiceLocator(initFuture);
  runApp(const MyApp());
}
