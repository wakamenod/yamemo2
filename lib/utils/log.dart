import 'package:flutter/foundation.dart';
import 'package:simple_logger/simple_logger.dart';

class LOG {
  static final SimpleLogger _logger = SimpleLogger()
    ..setLevel(_logLevel())
    ..levelPrefixes = {
      Level.FINEST: '👾 ',
      Level.FINER: '👀 ',
      Level.FINE: '🎾 ',
      Level.CONFIG: '🐶 ',
      Level.INFO: '👻 ',
      Level.WARNING: '⚠️ ',
      Level.SEVERE: '‼️ ',
      Level.SHOUT: '😡 ',
    }
    ..formatter = (info) =>
        '${_logger.levelPrefixes[info.level] ?? ''}${info.level} ${info.message}';

  static Level _logLevel() {
    return kReleaseMode ? Level.WARNING : Level.ALL;
  }

  static void info(String msg) {
    _logger.info(msg);
  }

  static void warn(String msg) {
    _logger.warning(msg);
  }

  static void shout(String msg) {
    _logger.shout(msg);
  }
}
