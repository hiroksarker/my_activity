import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_activity/core/security/security_service.dart';

@GenerateMocks([FlutterSecureStorage])
class SecurityTestHelper {
  static const testKey = 'test_key';
  static const testValue = 'test_value';
  static const testToken = 'test_token';
  static const testUrl = 'https://example.com';

  // Mock secure storage for testing
  static FlutterSecureStorage getMockSecureStorage() {
    final mockStorage = MockFlutterSecureStorage();
    when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
        .thenAnswer((_) async => null);
    when(mockStorage.read(key: anyNamed('key')))
        .thenAnswer((_) async => testValue);
    when(mockStorage.delete(key: anyNamed('key')))
        .thenAnswer((_) async => null);
    when(mockStorage.deleteAll())
        .thenAnswer((_) async => null);
    return mockStorage;
  }

  // Create test security service
  static SecurityService getTestSecurityService() {
    return SecurityService();
  }

  // Create test widget with security features
  static Widget createTestWidget({
    required Widget child,
    required SecurityService securityService,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          securityService.enableScreenshotPrevention(context);
          return child;
        },
      ),
    );
  }

  // Generate test JWT token
  static String generateTestJWT({
    required String subject,
    required DateTime expiration,
  }) {
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };
    final payload = {
      'sub': subject,
      'exp': expiration.millisecondsSinceEpoch ~/ 1000,
    };
    // Note: This is a simplified version for testing
    // In production, use proper JWT signing
    return '${_base64Encode(header)}.${_base64Encode(payload)}.signature';
  }

  // Helper method to encode JSON to base64
  static String _base64Encode(Map<String, dynamic> json) {
    final jsonString = json.toString();
    final bytes = utf8.encode(jsonString);
    return base64Url.encode(bytes);
  }

  // Create test sensitive data
  static String createTestSensitiveData() {
    return 'password=test123&token=abc123&key=secret123';
  }

  // Create test encrypted data
  static String createTestEncryptedData() {
    return 'encrypted_test_data';
  }

  // Create test network response
  static Map<String, dynamic> createTestNetworkResponse() {
    return {
      'status': 'success',
      'data': {
        'id': 1,
        'name': 'Test Data',
      },
    };
  }

  // Create test error response
  static Map<String, dynamic> createTestErrorResponse() {
    return {
      'status': 'error',
      'message': 'Test error message',
    };
  }

  // Create test device info
  static Map<String, dynamic> createTestDeviceInfo() {
    return {
      'isPhysicalDevice': true,
      'isJailbroken': false,
      'isEmulator': false,
    };
  }
} 