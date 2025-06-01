import 'package:logger/logger.dart';

class LoggerService {
  static late Logger logger;

  static void initialize() {
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
} 