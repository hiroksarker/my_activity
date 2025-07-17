import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';
import '../widgets/add_transaction_dialog.dart';
import '../screens/transaction_details_screen.dart';
import '../../../widgets/modern_background.dart';
import '../../../core/theme/app_theme.dart';

class ModernFinanceScreen extends StatefulWidget {
  const ModernFinanceScreen({super.key});

  @override
  State<ModernFinanceScreen> createState() => _ModernFinanceScreenState();
}

class _ModernFinanceScreenState extends State<ModernFinanceScreen> with AutomaticKeepAliveClientMixin {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  
  // Cache for calculations to avoid repeated database calls
  double? _cachedNetIncome;
  Map<String, double>? _cachedIncomeBySource;
  Map<String, double>? _cachedExpensesByCategory;
  List<FinancialTransaction>? _cachedTransactions;
  DateTime? _lastCalculationTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
    // Load data immediately when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFinanceData();
    });
  }

  Future<void> _loadFinanceData() async {
    final provider = context.read<TransactionProvider>();
    try {
      final results = await Future.wait([
        provider.getNetIncome(_startDate, _endDate),
        provider.getIncomeBySource(_startDate, _endDate),
        provider.getExpensesByCategory(_startDate, _endDate),
        provider.getTransactionsByDateRange(_startDate, _endDate),
      ]);
      
      if (mounted) {
        setState(() {
          _cachedNetIncome = results[0] as double;
          _cachedIncomeBySource = results[1] as Map<String, double>;
          _cachedExpensesByCategory = results[2] as Map<String, double>;
          _cachedTransactions = results[3] as List<FinancialTransaction>;
          _lastCalculationTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading finance data: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadFinanceData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Financial Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // Show loading only if we don't have cached data
          if (_cachedNetIncome == null && provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading financial data...'),
                ],
              ),
            );
          }

          // Use cached data if available, otherwise show empty state
          final netIncome = _cachedNetIncome ?? 0.0;
          final incomeBySource = _cachedIncomeBySource ?? <String, double>{};
          final expensesByCategory = _cachedExpensesByCategory ?? <String, double>{};
          final transactions = _cachedTransactions ?? <FinancialTransaction>[];

          // Calculate totals for display
          final totalIncome = incomeBySource.values.fold(0.0, (sum, amount) => sum + amount);
          final totalExpenses = expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);

          return RefreshIndicator(
            key: _refreshKey,
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Text(
                            'Financial Period',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat.yMMMd().format(_startDate)} - ${DateFormat.yMMMd().format(_endDate)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Financial Overview Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Net Income Card
                        StatsCard(
                          title: 'Net Income',
                          value: '\$${netIncome.toStringAsFixed(2)}',
                          subtitle: netIncome >= 0 ? 'Positive balance' : 'Negative balance',
                          icon: netIncome >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: netIncome >= 0 ? AppTheme.success : AppTheme.error,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Income and Expenses Row
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Total Income',
                                value: '\$${totalIncome.toStringAsFixed(2)}',
                                subtitle: '${incomeBySource.length} sources',
                                icon: Icons.arrow_upward,
                                color: AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatsCard(
                                title: 'Total Expenses',
                                value: '\$${totalExpenses.toStringAsFixed(2)}',
                                subtitle: '${expensesByCategory.length} categories',
                                icon: Icons.arrow_downward,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Income by Source Section
                  if (incomeBySource.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Income Sources',
                      subtitle: 'Breakdown by source',
                      action: TextButton(
                        onPressed: () {
                          // Navigate to detailed income view
                        },
                        child: const Text('View All'),
                      ),
                    ),
                    ...incomeBySource.entries.map((entry) {
                      final percentage = totalIncome > 0 ? (entry.value / totalIncome * 100) : 0.0;
                      return ModernCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: AppTheme.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: AppTheme.outline,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}% of total income',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // Expenses by Category Section
                  if (expensesByCategory.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Expense Categories',
                      subtitle: 'Breakdown by category',
                      action: TextButton(
                        onPressed: () {
                          // Navigate to detailed expenses view
                        },
                        child: const Text('View All'),
                      ),
                    ),
                    ...expensesByCategory.entries.map((entry) {
                      final percentage = totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0.0;
                      return ModernCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.shopping_cart,
                                color: AppTheme.error,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: AppTheme.outline,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.error),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}% of total expenses',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // Recent Transactions Section
                  if (transactions.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Recent Transactions',
                      subtitle: '${transactions.length} transactions',
                      action: TextButton(
                        onPressed: () {
                          // Navigate to all transactions
                        },
                        child: const Text('View All'),
                      ),
                    ),
                    ...transactions.take(5).map((transaction) {
                      final isExpense = transaction.type == TransactionType.expense;
                      return ModernCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isExpense 
                                  ? AppTheme.error.withOpacity(0.1)
                                  : AppTheme.success.withOpacity(0.1),
                              child: Icon(
                                isExpense ? Icons.remove : Icons.add,
                                color: isExpense ? AppTheme.error : AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${transaction.category} • ${DateFormat.yMMMd().format(transaction.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isExpense ? AppTheme.error : AppTheme.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ] else ...[
                    const EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Transactions Yet',
                      subtitle: 'Start tracking your finances by adding your first transaction',
                    ),
                  ],

                  // Bottom padding for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const AddTransactionDialog(),
          );
          
          if (result == true && mounted) {
            await _loadFinanceData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
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
      // Refresh data with new date range
      await _loadFinanceData();
    }
  }
}