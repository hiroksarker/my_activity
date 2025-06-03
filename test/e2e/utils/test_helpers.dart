import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io' show Platform;

Future<void> setupTestEnvironment() async {
  // Initialize FFI for sqflite only on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Get the temporary directory for test database
  final tempDir = await path_provider.getTemporaryDirectory();
  final dbPath = path.join(tempDir.path, 'test.db');
  
  // Delete existing test database if it exists
  try {
    await databaseFactory.deleteDatabase(dbPath);
  } catch (e) {
    // Ignore errors if database doesn't exist
  }
  
  // Set up test environment
  TestWidgetsFlutterBinding.ensureInitialized();
} 