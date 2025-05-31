import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/receipt.dart';
import '../models/income.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  Future<File> generateMonthlyReport({
    required DateTime month,
    required String format, // 'pdf' or 'excel'
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get start and end dates for the month
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      // Fetch all transactions for the month
      final receipts = await _getReceiptsForDateRange(startDate, endDate);
      final incomes = await _getIncomesForDateRange(startDate, endDate);
      final budgets = await _getBudgetsForDateRange(startDate, endDate);

      // Calculate summary
      final summary = _calculateMonthlySummary(receipts, incomes, budgets);

      // Generate report based on format
      if (format.toLowerCase() == 'pdf') {
        return await _generatePDFReport(
          month: month,
          receipts: receipts,
          incomes: incomes,
          budgets: budgets,
          summary: summary,
        );
      } else {
        return await _generateExcelReport(
          month: month,
          receipts: receipts,
          incomes: incomes,
          budgets: budgets,
          summary: summary,
        );
      }
    } catch (e) {
      throw Exception('Failed to generate monthly report: $e');
    }
  }

  Future<File> generateBudgetReport({
    required Budget budget,
    required String format,
  }) async {
    try {
      final receipts = await _getReceiptsForDateRange(
        budget.startDate,
        budget.endDate,
      );
      final incomes = await _getIncomesForDateRange(
        budget.startDate,
        budget.endDate,
      );

      final summary = _calculateBudgetSummary(budget, receipts, incomes);

      if (format.toLowerCase() == 'pdf') {
        return await _generateBudgetPDFReport(
          budget: budget,
          receipts: receipts,
          incomes: incomes,
          summary: summary,
        );
      } else {
        return await _generateBudgetExcelReport(
          budget: budget,
          receipts: receipts,
          incomes: incomes,
          summary: summary,
        );
      }
    } catch (e) {
      throw Exception('Failed to generate budget report: $e');
    }
  }

  Future<List<Receipt>> _getReceiptsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _auth.currentUser?.uid;
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('receipts')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snapshot.docs
        .map((doc) => Receipt.fromJson(doc.data()))
        .toList();
  }

  Future<List<Income>> _getIncomesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _auth.currentUser?.uid;
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snapshot.docs
        .map((doc) => Income.fromJson(doc.data()))
        .toList();
  }

  Future<List<Budget>> _getBudgetsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _auth.currentUser?.uid;
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();

    return snapshot.docs
        .map((doc) => Budget.fromJson(doc.data()))
        .toList();
  }

  Map<String, dynamic> _calculateMonthlySummary(
    List<Receipt> receipts,
    List<Income> incomes,
    List<Budget> budgets,
  ) {
    final totalExpenses = receipts.fold<double>(
      0,
      (sum, receipt) => sum + receipt.amount,
    );

    final totalIncome = incomes.fold<double>(
      0,
      (sum, income) => sum + income.amount,
    );

    final categoryExpenses = <String, double>{};
    for (final receipt in receipts) {
      categoryExpenses[receipt.category] =
          (categoryExpenses[receipt.category] ?? 0) + receipt.amount;
    }

    final sourceIncome = <String, double>{};
    for (final income in incomes) {
      sourceIncome[income.source] =
          (sourceIncome[income.source] ?? 0) + income.amount;
    }

    final budgetUtilization = <String, double>{};
    for (final budget in budgets) {
      final spent = categoryExpenses[budget.name] ?? 0;
      budgetUtilization[budget.name] =
          (spent / budget.totalAmount) * 100;
    }

    return {
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'netIncome': totalIncome - totalExpenses,
      'categoryExpenses': categoryExpenses,
      'sourceIncome': sourceIncome,
      'budgetUtilization': budgetUtilization,
      'transactionCount': receipts.length + incomes.length,
    };
  }

  Map<String, dynamic> _calculateBudgetSummary(
    Budget budget,
    List<Receipt> receipts,
    List<Income> incomes,
  ) {
    final categoryExpenses = <String, double>{};
    for (final receipt in receipts) {
      if (budget.categories.contains(receipt.category)) {
        categoryExpenses[receipt.category] =
            (categoryExpenses[receipt.category] ?? 0) + receipt.amount;
      }
    }

    final totalSpent = categoryExpenses.values.fold<double>(0, (sum, amount) => sum + amount);
    final remainingBudget = budget.totalAmount - totalSpent;

    final categoryUtilization = <String, double>{};
    for (final category in budget.categories) {
      final spent = categoryExpenses[category] ?? 0;
      final limit = budget.categoryLimits[category] ?? 0;
      categoryUtilization[category] = limit > 0 ? (spent / limit) * 100 : 0;
    }

    return {
      'budget': budget,
      'totalSpent': totalSpent,
      'remainingBudget': remainingBudget,
      'categoryExpenses': categoryExpenses,
      'categoryUtilization': categoryUtilization,
      'isOverBudget': totalSpent > budget.totalAmount,
    };
  }

  Future<File> _generatePDFReport({
    required DateTime month,
    required List<Receipt> receipts,
    required List<Income> incomes,
    required List<Budget> budgets,
    required Map<String, dynamic> summary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Monthly Financial Report - ${DateFormat('MMMM yyyy').format(month)}',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          _buildSummarySection(summary),
          pw.SizedBox(height: 20),
          _buildExpensesSection(receipts),
          pw.SizedBox(height: 20),
          _buildIncomeSection(incomes),
          pw.SizedBox(height: 20),
          _buildBudgetSection(budgets, summary),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/monthly_report_${DateFormat('yyyy_MM').format(month)}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> _generateExcelReport({
    required DateTime month,
    required List<Receipt> receipts,
    required List<Income> incomes,
    required List<Budget> budgets,
    required Map<String, dynamic> summary,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel.sheets.values.first;

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = 'Monthly Financial Report - ${DateFormat('MMMM yyyy').format(month)}';

    // Add summary
    _addExcelSummary(sheet, summary);

    // Add expenses
    _addExcelExpenses(sheet, receipts);

    // Add income
    _addExcelIncome(sheet, incomes);

    // Add budget
    _addExcelBudget(sheet, budgets, summary);

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/monthly_report_${DateFormat('yyyy_MM').format(month)}.xlsx',
    );
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  pw.Widget _buildSummarySection(Map<String, dynamic> summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total Income: ${_currencyFormat.format(summary['totalIncome'])}'),
          pw.Text('Total Expenses: ${_currencyFormat.format(summary['totalExpenses'])}'),
          pw.Text(
            'Net Income: ${_currencyFormat.format(summary['netIncome'])}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: summary['netIncome'] >= 0 ? PdfColors.green : PdfColors.red,
            ),
          ),
          pw.Text('Total Transactions: ${summary['transactionCount']}'),
        ],
      ),
    );
  }

  pw.Widget _buildExpensesSection(List<Receipt> receipts) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Expenses',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Description', 'Amount'],
            data: receipts.map((receipt) => [
              _dateFormat.format(receipt.date),
              receipt.category,
              receipt.title,
              receipt.formattedAmount,
            ]).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildIncomeSection(List<Income> incomes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Income',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Date', 'Source', 'Description', 'Amount'],
            data: incomes.map((income) => [
              _dateFormat.format(income.date),
              income.source,
              income.title,
              income.formattedAmount,
            ]).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBudgetSection(
    List<Budget> budgets,
    Map<String, dynamic> summary,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Budget Overview',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Category', 'Budget', 'Spent', 'Remaining', 'Utilization'],
            data: budgets.map((budget) {
              final spent = summary['categoryExpenses'][budget.name] ?? 0;
              final remaining = budget.totalAmount - spent;
              final utilization = (spent / budget.totalAmount) * 100;
              return [
                budget.name,
                _currencyFormat.format(budget.totalAmount),
                _currencyFormat.format(spent),
                _currencyFormat.format(remaining),
                '${utilization.toStringAsFixed(1)}%',
              ];
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _addExcelSummary(Sheet sheet, Map<String, dynamic> summary) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = 'Summary';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = 'Total Income';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = summary['totalIncome'];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = 'Total Expenses';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = summary['totalExpenses'];
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = 'Net Income';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
        .value = summary['netIncome'];
  }

  void _addExcelExpenses(Sheet sheet, List<Receipt> receipts) {
    final startRow = 8;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
        .value = 'Expenses';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow + 1))
        .value = 'Date';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow + 1))
        .value = 'Category';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow + 1))
        .value = 'Description';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow + 1))
        .value = 'Amount';

    for (var i = 0; i < receipts.length; i++) {
      final receipt = receipts[i];
      final row = startRow + 2 + i;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = _dateFormat.format(receipt.date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = receipt.category;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = receipt.title;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = receipt.amount;
    }
  }

  void _addExcelIncome(Sheet sheet, List<Income> incomes) {
    final startRow = 8 + incomes.length + 3;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
        .value = 'Income';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow + 1))
        .value = 'Date';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow + 1))
        .value = 'Source';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow + 1))
        .value = 'Description';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow + 1))
        .value = 'Amount';

    for (var i = 0; i < incomes.length; i++) {
      final income = incomes[i];
      final row = startRow + 2 + i;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = _dateFormat.format(income.date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = income.source;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = income.title;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = income.amount;
    }
  }

  void _addExcelBudget(
    Sheet sheet,
    List<Budget> budgets,
    Map<String, dynamic> summary,
  ) {
    final startRow = 8 + budgets.length + 3;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow))
        .value = 'Budget Overview';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: startRow + 1))
        .value = 'Category';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: startRow + 1))
        .value = 'Budget';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: startRow + 1))
        .value = 'Spent';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: startRow + 1))
        .value = 'Remaining';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: startRow + 1))
        .value = 'Utilization';

    for (var i = 0; i < budgets.length; i++) {
      final budget = budgets[i];
      final spent = summary['categoryExpenses'][budget.name] ?? 0;
      final remaining = budget.totalAmount - spent;
      final utilization = (spent / budget.totalAmount) * 100;
      final row = startRow + 2 + i;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = budget.name;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = budget.totalAmount;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = spent;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = remaining;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = utilization;
    }
  }
} 