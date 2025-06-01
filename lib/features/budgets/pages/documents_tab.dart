import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../models/document.dart';
import 'add_document_dialog.dart';

class DocumentsTab extends StatefulWidget {
  final int tripId;
  const DocumentsTab({required this.tripId});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  @override
  void initState() {
    super.initState();
    Provider.of<DocumentProvider>(context, listen: false).loadDocuments(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentProvider>(
      builder: (context, provider, _) {
        final docs = provider.documents;
        return Scaffold(
          body: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.teal),
                      SizedBox(height: 16),
                      Text('No documents yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Tap + to add your first document!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    return Card(
                      color: Colors.teal.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.insert_drive_file, color: Colors.teal),
                        title: Text(doc.type, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(doc.description),
                        // trailing: IconButton(...), // Add delete/edit if needed
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddDocumentDialog(tripId: widget.tripId),
              );
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}