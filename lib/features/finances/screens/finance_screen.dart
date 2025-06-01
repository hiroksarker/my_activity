import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/models/activity.dart';
import '../widgets/income_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../screens/transactions_list_screen.dart';
import '../screens/transaction_details_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTimeRange? dateRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
              );
              if (dateRange != null) {
                setState(() {
                  _startDate = dateRange.start;
                  _endDate = dateRange.end;
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          activityProvider.getNetIncome(_startDate, _endDate),
          activityProvider.getIncomeBySource(_startDate, _endDate),
          activityProvider.getExpensesByCategory(_startDate, _endDate),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final netIncome = snapshot.data![0] as double;
          final incomeBySource = snapshot.data![1] as Map<String, double>;
          final expensesByCategory = snapshot.data![2] as Map<String, double>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Net Income',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${netIncome.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: netIncome >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (incomeBySource.isNotEmpty) ...[
                  const Text(
                    'Income by Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: incomeBySource.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key),
                            trailing: Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (expensesByCategory.isNotEmpty) ...[
                  const Text(
                    'Expenses by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: expensesByCategory.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key),
                            trailing: Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FutureBuilder<List<Activity>>(
                  future: activityProvider.getTransactionsByDateRange(
                    _startDate ?? DateTime(2020),
                    _endDate ?? DateTime.now(),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final transactions = snapshot.data!;
                    if (transactions.isEmpty) {
                      return const Center(
                        child: Text('No transactions found'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final isExpense = transaction.transactionType == TransactionType.debit;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.categoryColor,
                                child: Icon(
                                  transaction.categoryIcon,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(transaction.title),
                              subtitle: Text(
                                '${transaction.category} • ${DateFormat.yMMMd().format(transaction.createdAt)}',
                              ),
                              trailing: Text(
                                '\$${(transaction.amount ?? 0).abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isExpense ? Colors.red : Colors.green,
                                ),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/transaction-details',
                                  arguments: transaction,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTransactionDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 