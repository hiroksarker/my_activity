import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';

class AddDocumentDialog extends StatefulWidget {
  final int tripId;
  const AddDocumentDialog({required this.tripId});
  @override
  State<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  String type = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Document'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Type (e.g. Passport, Ticket)'),
              validator: (v) => v == null || v.isEmpty ? 'Enter a type' : null,
              onSaved: (v) => type = v!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (v) => description = v ?? '',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final doc = Document(
                tripId: widget.tripId,
                type: type,
                filePath: '', // You can add file picker logic here
                description: description,
                id: null,
              );
              await context.read<DocumentProvider>().addDocument(doc);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
