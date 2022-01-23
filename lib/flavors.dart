enum Flavor {
  DEV,
  PROD,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.DEV:
        return 'Yamemo2(Dev)';
      case Flavor.PROD:
        return 'Yamemo2';
      default:
        return 'title';
    }
  }

}
