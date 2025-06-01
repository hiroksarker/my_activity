import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/models/activity.dart';
import '../../finances/screens/transaction_details_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionType? _selectedType;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction Type Filter
            DropdownButtonFormField<TransactionType?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Transaction Type',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Types'),
                ),
                ...TransactionType.values.map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type == TransactionType.debit ? 'Expense' : 'Income'),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),

            // Category Filter
            DropdownButtonFormField<String?>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._getUniqueCategories().map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),

            // Date Range Filter
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(
                _startDate == null || _endDate == null
                    ? 'Select date range'
                    : '${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _startDate != null && _endDate != null
                      ? DateTimeRange(start: _startDate!, end: _endDate!)
                      : null,
                );

                if (picked != null) {
                  setState(() {
                    _startDate = picked.start;
                    _endDate = picked.end;
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedCategory = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueCategories() {
    final activityProvider = context.read<ActivityProvider>();
    final transactions = activityProvider.expenses;
    return transactions.map((t) => t.category).toSet().toList()..sort();
  }

  List<Activity> _getFilteredTransactions() {
    final activityProvider = context.read<ActivityProvider>();
    var transactions = activityProvider.expenses;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((t) =>
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply type filter
    if (_selectedType != null) {
      transactions = transactions.where((t) => t.transactionType == _selectedType).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      transactions = transactions.where((t) => t.category == _selectedCategory).toList();
    }

    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      transactions = transactions.where((t) =>
          t.timestamp.isAfter(_startDate!) && t.timestamp.isBefore(_endDate!)).toList();
    }

    return transactions..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final filteredTransactions = _getFilteredTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active Filters
          if (_selectedType != null || _selectedCategory != null || _startDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedType != null)
                    Chip(
                      label: Text(_selectedType == TransactionType.debit ? 'Expenses' : 'Income'),
                      onDeleted: () {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  if (_startDate != null && _endDate != null)
                    Chip(
                      label: Text(
                        '${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      final isExpense = transaction.transactionType == TransactionType.debit;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.categoryColor.withOpacity(0.2),
                          child: Icon(
                            transaction.categoryIcon,
                            color: transaction.categoryColor,
                          ),
                        ),
                        title: Text(transaction.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${transaction.category} • ${DateFormat.yMMMd().format(transaction.timestamp)}',
                            ),
                            if (transaction.description?.isNotEmpty ?? false)
                              Text(
                                transaction.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (transaction.isRecurring)
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Recurring ${transaction.recurrenceType?.toLowerCase()}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(transaction.amount),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (transaction.isRecurring && transaction.nextOccurrence != null)
                              Text(
                                'Next: ${DateFormat.yMMMd().format(transaction.nextOccurrence!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
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
          ),
        ],
      ),
    );
  }
} 