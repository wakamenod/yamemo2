import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'ANDROID_AD_UNIT_ID_DEV', obfuscate: true)
  static final String kAndroidAddUnitIDDev = _Env.kAndroidAddUnitIDDev;

  @EnviedField(varName: 'ANDROID_AD_UNIT_ID_PROD', obfuscate: true)
  static final String kAndroidAddUnitIDProd = _Env.kAndroidAddUnitIDProd;

  @EnviedField(varName: 'IOS_AD_UNIT_ID_DEV', obfuscate: true)
  static final String kIOSAddUnitIDDev = _Env.kIOSAddUnitIDDev;

  @EnviedField(varName: 'IOS_AD_UNIT_ID_PROD', obfuscate: true)
  static final String kIOSAddUnitIDProd = _Env.kIOSAddUnitIDProd;
}
