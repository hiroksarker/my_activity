import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';

class LedgerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ledger')),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.error != null) return Center(child: Text('Error: ${provider.error}'));
          if (provider.entries.isEmpty) return Center(child: Text('No ledger entries found.'));
          return ListView.builder(
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return ListTile(
                title: Text(entry.description),
                subtitle: Text('${entry.date.toLocal()} - ${entry.account}'),
                trailing: Text(
                  entry.debit > 0
                      ? '+${entry.debit}'
                      : entry.credit > 0
                          ? '-${entry.credit}'
                          : '',
                  style: TextStyle(
                    color: entry.debit > 0 ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show add entry dialog
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
