import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../models/account.dart';
import '../models/category.dart';

class AddLedgerEntryDialog extends StatefulWidget {
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
  State<AddLedgerEntryDialog> createState() => _AddLedgerEntryDialogState();
}

class _AddLedgerEntryDialogState extends State<AddLedgerEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _debitController = TextEditingController();
  final _creditController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccount;
  String? _selectedCategory;

  @override
  void dispose() {
    _descriptionController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final debit = double.tryParse(_debitController.text) ?? 0.0;
    final credit = double.tryParse(_creditController.text) ?? 0.0;
    widget.onAdd(
      LedgerEntry(
        id: '', // Will be set by backend
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        debit: debit,
        credit: credit,
        account: _selectedAccount!,
        category: _selectedCategory!,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Ledger Entry'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Description required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _debitController,
                      decoration: const InputDecoration(labelText: 'Debit (in)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if ((v == null || v.isEmpty) && (_creditController.text.isEmpty)) {
                          return 'Enter debit or credit';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _creditController,
                      decoration: const InputDecoration(labelText: 'Credit (out)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if ((v == null || v.isEmpty) && (_debitController.text.isEmpty)) {
                          return 'Enter debit or credit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAccount,
                items: widget.accounts
                    .map((a) => DropdownMenuItem(value: a.name, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAccount = v),
                decoration: const InputDecoration(labelText: 'Account'),
                validator: (v) => v == null ? 'Select account' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: widget.categories
                    .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v == null ? 'Select category' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
