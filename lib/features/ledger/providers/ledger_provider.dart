import 'package:flutter/foundation.dart';
import '../models/ledger_entry.dart';

class LedgerProvider with ChangeNotifier {
  List<LedgerEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<LedgerEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEntries() async {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(LedgerEntry entry) async {
    _entries.add(entry);
    notifyListeners();
  }

  Future<void> updateEntry(LedgerEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}