import 'package:yamemo2/env/env.dart';

enum Flavor {
  kDev,
  kProd,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.kDev:
        return 'Yamemo2(Dev)';
      case Flavor.kProd:
        return 'Yamemo2';
      default:
        return 'title';
    }
  }

  static String get androidAdUnitID {
    switch (appFlavor) {
      case Flavor.kDev:
        return Env.kAndroidAddUnitIDDev;
      case Flavor.kProd:
        return Env.kAndroidAddUnitIDProd;
      default:
        return '';
    }
  }

  static String get iOSAdUnitID {
    switch (appFlavor) {
      case Flavor.kDev:
        return Env.kIOSAddUnitIDDev;
      case Flavor.kProd:
        return Env.kIOSAddUnitIDProd;
      default:
        return '';
    }
  }
}
