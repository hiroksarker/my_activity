import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/ledger_entry.dart';

class LedgerProvider with ChangeNotifier {
  final PocketBase _pb = PocketBase('http://10.0.2.2:8090'); // Android emulator, adjust for other platforms
  List<LedgerEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<LedgerEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _pb.collection('ledger_entries').getList(page: 1, perPage: 100, sort: '-date');
      _entries = result.items.map((item) => LedgerEntry.fromJson(item.toJson())).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add methods for addEntry, updateEntry, deleteEntry as needed
}