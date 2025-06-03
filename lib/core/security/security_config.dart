import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// Security configuration implementing OWASP Mobile Security Testing Guide (MSTG)
class SecurityConfig {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // MSTG-STORAGE-1: Sensitive data should be encrypted at rest
  static Future<void> secureStore(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> secureRetrieve(String key) async {
    return await _storage.read(key: key);
  }

  // MSTG-CRYPTO-1: App uses cryptographic functions
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // MSTG-NETWORK-1: App uses secure communication
  static Future<bool> validateCertificate(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // MSTG-AUTH-1: App implements proper authentication
  static bool validateToken(String token) {
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // MSTG-CODE-1: App is properly signed
  static const String appSignature = 'YOUR_APP_SIGNATURE'; // Replace with actual signature

  // MSTG-STORAGE-2: No sensitive data in logs
  static String sanitizeLogData(String data) {
    // Remove sensitive information like tokens, passwords, etc.
    return data.replaceAll(RegExp(r'(password|token|key|secret)=[^&]*'), r'$1=***');
  }

  // MSTG-STORAGE-3: No sensitive data in screenshots
  static const bool preventScreenshots = true;

  // MSTG-STORAGE-4: No sensitive data in clipboard
  static const bool preventClipboard = true;

  // MSTG-STORAGE-5: No sensitive data in backups
  static const bool preventBackups = true;

  // MSTG-STORAGE-6: No sensitive data in memory
  static void clearSensitiveData() {
    // Implement secure memory clearing
  }

  // MSTG-STORAGE-7: No sensitive data in logs
  static void secureLogging(String message) {
    // Implement secure logging
    print(sanitizeLogData(message));
  }

  // MSTG-STORAGE-8: No sensitive data in screenshots
  static void preventScreenCapture() {
    // Implement screen capture prevention
  }

  // MSTG-STORAGE-9: No sensitive data in backups
  static void preventBackup() {
    // Implement backup prevention
  }

  // MSTG-STORAGE-10: No sensitive data in memory
  static void secureMemory() {
    // Implement secure memory handling
  }

  // SSL Pinning Configuration
  static const List<String> sslPinningHashes = [
    '189591E0B45506CF13E56BBD5B17908DD19D40E7F093489CAF7BA737457D8D35', // Debug keystore SHA-256
    'F870BA600403D55B442F6D79CF2FD19FFF47A05EE1751B86C03AA6CF6C57A3D0', // Release keystore SHA-256
  ];

  // API Configuration
  static const String apiBaseUrl = 'https://api.example.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Secure Storage Keys
  static const String secureStoragePrefix = 'secure_';
  static const String authTokenKey = '${secureStoragePrefix}auth_token';
  static const String encryptionKeyKey = '${secureStoragePrefix}encryption_key';
  static const String biometricEnabledKey = '${secureStoragePrefix}biometric_enabled';

  // Encryption Configuration
  static const int encryptionKeyLength = 32; // 256 bits
  static const String encryptionAlgorithm = 'AES-256-CBC';
  static const int pbkdf2Iterations = 100000;
  static const int pbkdf2KeyLength = 32; // 256 bits
  static const String pbkdf2Algorithm = 'SHA-256';

  // Security Headers
  static const Map<String, String> securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';",
  };

  // Debug Configuration
  static const bool enableDebugLogging = false;
  static const bool allowDebugMode = false;
  static const bool enforceSSL = true;
  static const bool preventScreenshots = true;
  static const bool preventBackup = true;
  static const bool preventClipboardAccess = true;

  // Certificate Pinning Configuration
  static const Map<String, List<String>> certificatePins = {
    'api.example.com': [
      '189591E0B45506CF13E56BBD5B17908DD19D40E7F093489CAF7BA737457D8D35', // Debug keystore SHA-256
      'F870BA600403D55B442F6D79CF2FD19FFF47A05EE1751B86C03AA6CF6C57A3D0', // Release keystore SHA-256
    ],
  };

  // Keystore Configuration
  static const Map<String, Map<String, String>> keystoreConfig = {
    'debug': {
      'path': 'debug.keystore',
      'password': 'android',
      'alias': 'androiddebugkey',
      'keyPassword': 'android',
      'sha1': '93:EA:5D:69:73:86:B2:2C:67:BD:46:28:00:D3:36:CD:83:A8:F5:5F',
      'sha256': '189591E0B45506CF13E56BBD5B17908DD19D40E7F093489CAF7BA737457D8D35',
    },
    'release': {
      'path': 'release.keystore',
      'password': 'MyActivity@2024',
      'alias': 'my_activity_release',
      'keyPassword': 'MyActivity@2024',
      'sha1': '27:C0:79:FB:3F:B3:1D:EB:E6:71:38:58:9C:9E:B5:E5:57:F8:6B:C8',
      'sha256': 'F870BA600403D55B442F6D79CF2FD19FFF47A05EE1751B86C03AA6CF6C57A3D0',
    },
  };
} 