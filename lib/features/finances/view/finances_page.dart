import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/models/activity.dart';
import 'package:intl/intl.dart';
import 'package:your_app/features/ledger/widgets/add_ledger_entry_dialog.dart';
import 'package:your_app/features/ledger/models/account.dart';
import 'package:your_app/features/ledger/models/category.dart';
import 'package:your_app/features/ledger/providers/ledger_provider.dart';
import 'widgets/finances_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/recent_transactions.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  String _selectedPeriod = 'This Month';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<ActivityProvider>(
          builder: (context, provider, child) {
            final financeActivities = provider.activities
                .where((activity) => activity.category == 'Finance Tracking')
                .toList();
            
            final totalIncome = financeActivities
                .where((a) => a.amount > 0)
                .fold(0.0, (sum, a) => sum + a.amount);
            
            final totalExpenses = financeActivities
                .where((a) => a.amount < 0)
                .fold(0.0, (sum, a) => sum + a.amount.abs());
            
            final balance = totalIncome - totalExpenses;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancesHeader(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (value) => setState(() => _selectedPeriod = value),
                  ),
                  const SizedBox(height: 8),
                  BalanceCard(balance: balance, income: totalIncome, expenses: totalExpenses),
                  const SizedBox(height: 24),
                  _buildBudgetingTools(),
                  const SizedBox(height: 24),
                  _buildSpendingChart(),
                  const SizedBox(height: 24),
                  RecentTransactions(transactions: financeActivities),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    // Fetch or define your accounts and categories lists
    final accounts = <Account>[
      Account(id: '1', name: 'Cash'),
      Account(id: '2', name: 'Bank'),
      // ...fetch from provider or backend
    ];
    final categories = <Category>[
      Category(id: '1', name: 'Salary'),
      Category(id: '2', name: 'Groceries'),
      // ...fetch from provider or backend
    ];

    showDialog(
      context: context,
      builder: (context) => AddLedgerEntryDialog(
        onAdd: (entry) {
          Provider.of<LedgerProvider>(context, listen: false).addEntry(entry);
        },
        accounts: accounts,
        categories: categories,
      ),
    );
  }

  Widget _buildBudgetingTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budgeting Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBudgetTool(
                Icons.savings,
                'Budget Goals',
                'Set financial goals and track your spending',
                Colors.green,
                () {},
              ),
              const Divider(height: 24),
              _buildBudgetTool(
                Icons.pie_chart,
                'Spending Analysis',
                'Analyze your spending patterns',
                Colors.orange,
                () {},
              ),
              const Divider(height: 24),
              _buildBudgetTool(
                Icons.receipt_long,
                'Bills & Subscriptions',
                'Manage recurring payments',
                Colors.purple,
                () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTool(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Spending vs. Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Current Month',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '\$3,000',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '/ \$4,000',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar('Food', 0.7, Colors.blue),
                    _buildChartBar('Transport', 0.5, Colors.green),
                    _buildChartBar('Entertainment', 0.3, Colors.orange),
                    _buildChartBar('Rent', 0.9, Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(String label, double percentage, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: 100 * percentage,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80 * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}