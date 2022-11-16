import 'package:simple_logger/simple_logger.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/config_log.dart';

/// log factory to produce and initialize logger
/// [ConfigLog.logLevel] and [ConfigLog.includeCallerInfo]
abstract class LogWrapper {
  /// log factory
  static Future<SimpleLogger> getLog(ConfigModel configModel) async {
    var res = SimpleLogger();
    var config = await configModel.load();
    var log = config.log;
    var logLevel = log.getLevel(log.logLevel);
    res.setLevel(logLevel, includeCallerInfo: log.includeCallerInfo);
    return res;
  }
}
