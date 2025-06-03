import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';
import '../widgets/add_transaction_dialog.dart';
import 'transaction_details_screen.dart';

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddTransactionDialog(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.type == TransactionType.expense
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  child: Icon(
                    transaction.type == TransactionType.expense
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: transaction.type == TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                title: Text(transaction.title),
                subtitle: Text(transaction.category),
                trailing: Text(
                  NumberFormat.currency(symbol: '\$').format(transaction.amount),
                  style: TextStyle(
                    color: transaction.type == TransactionType.expense
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailsScreen(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 