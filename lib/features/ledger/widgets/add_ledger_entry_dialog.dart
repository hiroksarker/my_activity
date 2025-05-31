import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../models/account.dart';
import '../models/category.dart';

class AddLedgerEntryDialog extends StatelessWidget {
  final void Function(LedgerEntry) onAdd;
  final List<Account> accounts;
  final List<Category> categories;

  const AddLedgerEntryDialog({
    required this.onAdd,
    required this.accounts,
    required this.categories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Ledger Entry'),
      content: const Text('Form goes here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Add'),
        ),
      ],
    );
  }
}
