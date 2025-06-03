import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';
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
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return FutureBuilder(
            future: Future.wait([
              provider.getNetIncome(_startDate, _endDate),
              provider.getIncomeBySource(_startDate, _endDate),
              provider.getExpensesByCategory(_startDate, _endDate),
              provider.getTransactionsByDateRange(_startDate, _endDate),
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
              final transactions = snapshot.data![3] as List<FinancialTransaction>;

              return RefreshIndicator(
                key: _refreshKey,
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      if (transactions.isNotEmpty) ...[
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
                            final isExpense = transaction.type == TransactionType.expense;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.categoryColorData,
                                child: Icon(
                                  transaction.categoryIconData,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(transaction.title),
                              subtitle: Text(
                                '${transaction.category} • ${DateFormat.yMMMd().format(transaction.createdAt)}',
                              ),
                              trailing: Text(
                                '\$${transaction.amount.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isExpense ? Colors.red : Colors.green,
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
                        ),
                      ] else ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No transactions found'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const AddTransactionDialog(),
          );
          
          if (result == true && mounted) {
            _refreshKey.currentState?.show();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
} 