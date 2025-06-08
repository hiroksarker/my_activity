import 'package:flutter/material.dart';
import '../../../features/activities/providers/activity_provider.dart';
import 'package:provider/provider.dart';
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
import '../widgets/green_pills_wallpaper.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year', 'All Time'];
  String _incomePiePeriod = 'This Month';
  final List<String> _piePeriods = ['Today', 'This Week', 'This Month'];
  late TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeActivities() async {
    if (!mounted) return;
    
    try {
      await context.read<ActivityProvider>().fetchActivities();
    } catch (e) {
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

  Map<String, double> _groupIncomeByPeriod(List<Activity> activities) {
    final now = DateTime.now();
    final Map<String, double> grouped = {};
    for (final a in activities.where((a) => a.transactionType == TransactionType.credit)) {
      String key;
      if (_incomePiePeriod == 'Today') {
        key = DateFormat('yyyy-MM-dd').format(a.timestamp);
        if (a.timestamp.year == now.year && a.timestamp.month == now.month && a.timestamp.day == now.day) {
          grouped[key] = (grouped[key] ?? 0) + (a.amount ?? 0);
        }
      } else if (_incomePiePeriod == 'This Week') {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        if (a.timestamp.isAfter(weekStart) && a.timestamp.isBefore(weekEnd)) {
          key = DateFormat('EEE').format(a.timestamp); // e.g. Mon, Tue
          grouped[key] = (grouped[key] ?? 0) + (a.amount ?? 0);
        }
      } else {
        // This Month
        if (a.timestamp.year == now.year && a.timestamp.month == now.month) {
          key = DateFormat('d MMM').format(a.timestamp); // e.g. 8 Jun
          grouped[key] = (grouped[key] ?? 0) + (a.amount ?? 0);
        }
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GreenPillsWallpaper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finances'),
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard),
                text: 'Overview',
              ),
              Tab(
                icon: Icon(Icons.arrow_upward),
                text: 'Income',
              ),
              Tab(
                icon: Icon(Icons.arrow_downward),
                text: 'Expenses',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeActivities,
              tooltip: 'Refresh',
            ),
            PopupMenuButton<String>(
              tooltip: 'Select Period',
              onSelected: (String period) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              itemBuilder: (BuildContext context) {
                return _periods.map((String period) {
                  return PopupMenuItem<String>(
                    value: period,
                    child: Row(
                      children: [
                        Icon(
                          period == _selectedPeriod ? Icons.check : Icons.calendar_today,
                          size: 20,
                          color: period == _selectedPeriod ? theme.colorScheme.primary : null,
                        ),
                        const SizedBox(width: 8),
                        Text(period),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddTransactionDialog(context),
              tooltip: 'Add Transaction',
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
                RefreshIndicator(
                  onRefresh: _initializeActivities,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // New: Pie chart for income by period
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Income Distribution', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              value: _incomePiePeriod,
                              items: _piePeriods.map((period) => DropdownMenuItem(value: period, child: Text(period))).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _incomePiePeriod = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final incomePieData = _groupIncomeByPeriod(activities);
                            final totalIncomePie = incomePieData.values.fold<double>(0, (sum, v) => sum + v);
                            if (incomePieData.isEmpty) {
                              return const Text('No income data for this period.');
                            }
                            return CategoryBreakdown(
                              data: incomePieData,
                              total: totalIncomePie,
                              isExpense: false,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        FinancialSummary(
                          balance: balance,
                          income: totalIncome,
                          expenses: totalExpenses,
                          period: _selectedPeriod,
                        ),
                        const SizedBox(height: 24),
                        if (expensesByCategory.isNotEmpty)
                          CategoryBreakdown(
                            data: expensesByCategory,
                            total: totalExpenses,
                            isExpense: true,
                          ),
                        const SizedBox(height: 24),
                        if (incomeBySource.isNotEmpty)
                          CategoryBreakdown(
                            data: incomeBySource,
                            total: totalIncome,
                            isExpense: false,
                          ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Transactions',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        // TODO: Navigate to full transaction list
                                      },
                                      icon: const Icon(Icons.list),
                                      label: const Text('View All'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TransactionList(
                                  transactions: activities.take(5).toList(),
                                  onTransactionTap: (activity) {
                                    // TODO: Show transaction details
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Income Tab
                RefreshIndicator(
                  onRefresh: _initializeActivities,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        if (incomeBySource.isNotEmpty)
                          CategoryBreakdown(
                            data: incomeBySource,
                            total: totalIncome,
                            isExpense: false,
                          ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Income Transactions',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TransactionList(
                                  transactions: activities
                                      .where((a) => a.transactionType == TransactionType.credit)
                                      .toList(),
                                  onTransactionTap: (activity) {
                                    // TODO: Show transaction details
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Expenses Tab
                RefreshIndicator(
                  onRefresh: _initializeActivities,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        if (expensesByCategory.isNotEmpty)
                          CategoryBreakdown(
                            data: expensesByCategory,
                            total: totalExpenses,
                            isExpense: true,
                          ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expense Transactions',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TransactionList(
                                  transactions: activities
                                      .where((a) => a.transactionType == TransactionType.debit)
                                      .toList(),
                                  onTransactionTap: (activity) {
                                    // TODO: Show transaction details
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTransactionDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Transaction'),
        ),
      ),
    );
  }
} 