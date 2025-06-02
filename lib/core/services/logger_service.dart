import 'package:logging/logging.dart';

class LoggerService {
  static late Logger logger;

  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        // ignore: avoid_print
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace: ${record.stackTrace}');
      }
    });

    logger = Logger('MyActivity');
  }

  static void info(String message) => logger.info(message);
  static void error(String message, {Object? error, StackTrace? stackTrace}) => 
      logger.severe(message, error, stackTrace);
} 