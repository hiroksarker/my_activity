import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/models/activity.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/finance_dashboard.dart';
import '../widgets/budget_card.dart';
import '../widgets/income_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/financial_summary.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_transaction_dialog.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year', 'All Time'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeActivities() async {
    if (!mounted) return;
    
    try {
      print('Initializing finance activities...');
      await context.read<ActivityProvider>().fetchActivities();
      print('Finance activities initialized successfully');
    } catch (e) {
      print('Error initializing finance activities: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading activities: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _initializeActivities,
          ),
        ),
      );
    }
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeActivities,
          ),
          PopupMenuButton<String>(
            onSelected: (String period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (BuildContext context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          final activities = provider.activities.where((activity) {
            if (activity.amount == null) return false;
            
            switch (_selectedPeriod) {
              case 'This Week':
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 7));
                return activity.timestamp.isAfter(weekStart) && activity.timestamp.isBefore(weekEnd);
              case 'This Month':
                return activity.timestamp.year == now.year && activity.timestamp.month == now.month;
              case 'This Year':
                return activity.timestamp.year == now.year;
              case 'All Time':
                return true;
              default:
                return false;
            }
          }).toList();

          // Calculate totals
          final totalIncome = activities
              .where((a) => a.transactionType == TransactionType.credit)
              .fold<double>(0, (sum, a) => sum + (a.amount ?? 0));
          
          final totalExpenses = activities
              .where((a) => a.transactionType == TransactionType.debit)
              .fold<double>(0, (sum, a) => sum + (a.amount ?? 0));
          
          final balance = totalIncome - totalExpenses;

          // Group transactions by category
          final expensesByCategory = <String, double>{};
          final incomeBySource = <String, double>{};
          
          for (final activity in activities) {
            if (activity.amount == null) continue;
            
            if (activity.transactionType == TransactionType.debit) {
              expensesByCategory[activity.category] = 
                  (expensesByCategory[activity.category] ?? 0) + activity.amount!;
            } else {
              incomeBySource[activity.category] = 
                  (incomeBySource[activity.category] ?? 0) + activity.amount!;
            }
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FinancialSummary(
                      balance: balance,
                      income: totalIncome,
                      expenses: totalExpenses,
                      period: _selectedPeriod,
                    ),
                    const SizedBox(height: 24),
                    if (expensesByCategory.isNotEmpty) ...[
                      Text(
                        'Expenses by Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CategoryBreakdown(
                        data: expensesByCategory,
                        total: totalExpenses,
                        isExpense: true,
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (incomeBySource.isNotEmpty) ...[
                      Text(
                        'Income by Source',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CategoryBreakdown(
                        data: incomeBySource,
                        total: totalIncome,
                        isExpense: false,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TransactionList(
                      transactions: activities,
                      onTransactionTap: (activity) {
                        // TODO: Show transaction details
                      },
                    ),
                  ],
                ),
              ),
              
              // Income Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IncomeCard(
                      totalIncome: totalIncome,
                      incomeBySource: incomeBySource,
                      period: _selectedPeriod,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Income Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TransactionList(
                      transactions: activities.where((a) => 
                        a.transactionType == TransactionType.credit
                      ).toList(),
                      onTransactionTap: (activity) {
                        // TODO: Show transaction details
                      },
                    ),
                  ],
                ),
              ),
              
              // Expenses Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpenseCard(
                      totalExpenses: totalExpenses,
                      expensesByCategory: expensesByCategory,
                      period: _selectedPeriod,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Expense Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TransactionList(
                      transactions: activities.where((a) => 
                        a.transactionType == TransactionType.debit
                      ).toList(),
                      onTransactionTap: (activity) {
                        // TODO: Show transaction details
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 