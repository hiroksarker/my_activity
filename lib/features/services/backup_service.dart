import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _logger = Logger();
  late final encrypt.Key _encryptionKey;
  late final encrypt.IV _iv;
  final _secureStorage = const FlutterSecureStorage();

  Future<void> initialize() async {
    try {
      String? keyString = await _secureStorage.read(key: 'encryption_key');
      if (keyString == null) {
        final key = encrypt.Key.fromSecureRandom(32);
        keyString = base64.encode(key.bytes);
        await _secureStorage.write(key: 'encryption_key', value: keyString);
      }
      _encryptionKey = encrypt.Key(base64.decode(keyString));
      _iv = encrypt.IV.fromSecureRandom(16);
    } catch (e) {
      _logger.e('Error initializing backup service', error: e);
      rethrow;
    }
  }

  Future<String> _encryptData(String data) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    return encrypter.encrypt(data, iv: _iv).base64;
  }

  Future<String> _decryptData(String encryptedData) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    return encrypter.decrypt64(encryptedData, iv: _iv);
  }

  Future<void> backupToCloud({
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    try {
      final encryptedData = await _encryptData(json.encode(data));
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .doc(DateTime.now().toIso8601String())
          .set({
        'data': encryptedData,
        'timestamp': FieldValue.serverTimestamp(),
        'version': '1.0',
      });
    } catch (e) {
      throw Exception('Failed to backup data: $e');
    }
  }

  Future<Map<String, dynamic>> restoreFromCloud({
    required String userId,
    String? backupId,
  }) async {
    try {
      final query = _firestore
          .collection('users')
          .doc(userId)
          .collection('backups');

      final snapshot = backupId != null
          ? await query.doc(backupId).get()
          : await query.orderBy('timestamp', descending: true).limit(1).get();

      if (!snapshot.exists) {
        throw Exception('No backup found');
      }

      final data = snapshot.data()!['data'] as String;
      final decryptedData = await _decryptData(data);
      return json.decode(decryptedData) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to restore data: $e');
    }
  }

  Future<void> backupToLocal({
    required Map<String, dynamic> data,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_${DateTime.now().toIso8601String()}.json');
      final encryptedData = await _encryptData(json.encode(data));
      await file.writeAsString(encryptedData);
    } catch (e) {
      throw Exception('Failed to backup data locally: $e');
    }
  }

  Future<Map<String, dynamic>> restoreFromLocal(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final encryptedData = await file.readAsString();
      final decryptedData = await _decryptData(encryptedData);
      return json.decode(decryptedData) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to restore data from local backup: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBackupHistory({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'timestamp': data['timestamp']?.toDate()?.toIso8601String(),
          'version': data['version'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get backup history: $e');
    }
  }

  Future<void> deleteBackup({
    required String userId,
    required String backupId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .doc(backupId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  Future<void> deleteLocalBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete local backup: $e');
    }
  }
} 