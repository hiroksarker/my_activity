import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:my_activity/shared/services/pocketbase_service.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  final PocketBase pb = PocketBase('http://127.0.0.1:8090'); // Change to your PocketBase URL

  // Example method
  Future<List<dynamic>> getRecords(String collection) async {
    final records = await pb.collection(collection).getFullList();
    return records.map((r) => r.data).toList();
  }
}

class ActivityProvider with ChangeNotifier {
  final _pbService = PocketBaseService();

  Future<void> fetchActivities() async {
    final activities = await _pbService.getRecords('activities');
    // ...handle activities...
    notifyListeners();
  }
}