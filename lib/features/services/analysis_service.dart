import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget.dart';
import '../models/receipt.dart';

class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  AnalysisService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getSpendingAnalysis({
    required DateTime startDate,
    required DateTime endDate,
    String? category,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final query = _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (category != null) {
        query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      final receipts = snapshot.docs.map((doc) => Receipt.fromJson(doc.data())).toList();

      // Calculate total spending
      final totalSpending = receipts.fold<double>(
        0,
        (sum, receipt) => sum + receipt.amount,
      );

      // Calculate category-wise spending
      final categorySpending = <String, double>{};
      for (final receipt in receipts) {
        categorySpending[receipt.category] =
            (categorySpending[receipt.category] ?? 0) + receipt.amount;
      }

      // Calculate daily spending
      final dailySpending = <DateTime, double>{};
      for (final receipt in receipts) {
        final date = DateTime(
          receipt.date.year,
          receipt.date.month,
          receipt.date.day,
        );
        dailySpending[date] = (dailySpending[date] ?? 0) + receipt.amount;
      }

      // Calculate average daily spending
      final daysCount = endDate.difference(startDate).inDays + 1;
      final averageDailySpending = totalSpending / daysCount;

      // Find top spending categories
      final sortedCategories = categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCategories = sortedCategories.take(5).toList();

      // Calculate spending trends
      final spendingTrend = _calculateSpendingTrend(dailySpending);

      return {
        'totalSpending': totalSpending,
        'categorySpending': categorySpending,
        'dailySpending': dailySpending,
        'averageDailySpending': averageDailySpending,
        'topCategories': topCategories,
        'spendingTrend': spendingTrend,
        'receiptCount': receipts.length,
      };
    } catch (e) {
      throw Exception('Failed to analyze spending: $e');
    }
  }

  Future<Map<String, dynamic>> getBudgetAnalysis(Budget budget) async {
    try {
      final spendingAnalysis = await getSpendingAnalysis(
        startDate: budget.startDate,
        endDate: budget.endDate,
      );

      final categorySpending = spendingAnalysis['categorySpending'] as Map<String, double>;
      final totalSpending = spendingAnalysis['totalSpending'] as double;

      // Calculate budget utilization
      final categoryUtilization = <String, double>{};
      for (final category in budget.categories) {
        final spent = categorySpending[category] ?? 0;
        final limit = budget.categoryLimits[category] ?? 0;
        categoryUtilization[category] = limit > 0 ? (spent / limit) * 100 : 0;
      }

      // Calculate overall budget utilization
      final overallUtilization = (totalSpending / budget.totalAmount) * 100;

      // Calculate remaining budget
      final remainingBudget = budget.totalAmount - totalSpending;

      // Calculate category-wise remaining budget
      final categoryRemaining = <String, double>{};
      for (final category in budget.categories) {
        final spent = categorySpending[category] ?? 0;
        final limit = budget.categoryLimits[category] ?? 0;
        categoryRemaining[category] = limit - spent;
      }

      // Calculate days remaining in budget period
      final now = DateTime.now();
      final daysRemaining = budget.endDate.difference(now).inDays;

      // Calculate projected spending
      final daysElapsed = now.difference(budget.startDate).inDays;
      final averageDailySpending = daysElapsed > 0 ? totalSpending / daysElapsed : 0;
      final projectedSpending = averageDailySpending * daysRemaining;

      return {
        'budget': budget,
        'totalSpending': totalSpending,
        'categorySpending': categorySpending,
        'categoryUtilization': categoryUtilization,
        'overallUtilization': overallUtilization,
        'remainingBudget': remainingBudget,
        'categoryRemaining': categoryRemaining,
        'daysRemaining': daysRemaining,
        'projectedSpending': projectedSpending,
        'isOverBudget': totalSpending > budget.totalAmount,
        'isProjectedOverBudget': (totalSpending + projectedSpending) > budget.totalAmount,
      };
    } catch (e) {
      throw Exception('Failed to analyze budget: $e');
    }
  }

  Future<Map<String, dynamic>> getTrendAnalysis({
    required DateTime startDate,
    required DateTime endDate,
    String? category,
  }) async {
    try {
      final spendingAnalysis = await getSpendingAnalysis(
        startDate: startDate,
        endDate: endDate,
        category: category,
      );

      final dailySpending = spendingAnalysis['dailySpending'] as Map<DateTime, double>;
      final categorySpending = spendingAnalysis['categorySpending'] as Map<String, double>;

      // Calculate monthly trends
      final monthlyTrends = _calculateMonthlyTrends(dailySpending);

      // Calculate category trends
      final categoryTrends = _calculateCategoryTrends(categorySpending);

      // Calculate spending patterns
      final spendingPatterns = _analyzeSpendingPatterns(dailySpending);

      return {
        'monthlyTrends': monthlyTrends,
        'categoryTrends': categoryTrends,
        'spendingPatterns': spendingPatterns,
        'averageSpending': spendingAnalysis['averageDailySpending'],
        'topCategories': spendingAnalysis['topCategories'],
      };
    } catch (e) {
      throw Exception('Failed to analyze trends: $e');
    }
  }

  Map<String, dynamic> _calculateSpendingTrend(Map<DateTime, double> dailySpending) {
    if (dailySpending.isEmpty) return {};

    final sortedDays = dailySpending.keys.toList()..sort();
    final values = sortedDays.map((day) => dailySpending[day]!).toList();

    // Calculate moving average
    final windowSize = 7; // 7-day moving average
    final movingAverage = <DateTime, double>{};
    for (var i = windowSize - 1; i < sortedDays.length; i++) {
      final sum = values.sublist(i - windowSize + 1, i + 1).reduce((a, b) => a + b);
      movingAverage[sortedDays[i]] = sum / windowSize;
    }

    // Calculate trend direction
    final firstValue = values.first;
    final lastValue = values.last;
    final trendDirection = lastValue > firstValue ? 'increasing' : 'decreasing';
    final trendPercentage = ((lastValue - firstValue) / firstValue) * 100;

    return {
      'movingAverage': movingAverage,
      'trendDirection': trendDirection,
      'trendPercentage': trendPercentage,
      'volatility': _calculateVolatility(values),
    };
  }

  Map<String, dynamic> _calculateMonthlyTrends(Map<DateTime, double> dailySpending) {
    final monthlyTotals = <DateTime, double>{};
    for (final entry in dailySpending.entries) {
      final month = DateTime(entry.key.year, entry.key.month);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + entry.value;
    }

    final sortedMonths = monthlyTotals.keys.toList()..sort();
    final values = sortedMonths.map((month) => monthlyTotals[month]!).toList();

    return {
      'monthlyTotals': monthlyTotals,
      'trend': _calculateSpendingTrend(
        Map.fromEntries(
          sortedMonths.map((month) => MapEntry(month, monthlyTotals[month]!)),
        ),
      ),
    };
  }

  Map<String, dynamic> _calculateCategoryTrends(Map<String, double> categorySpending) {
    final total = categorySpending.values.fold<double>(0, (sum, amount) => sum + amount);
    final percentages = <String, double>{};
    for (final entry in categorySpending.entries) {
      percentages[entry.key] = (entry.value / total) * 100;
    }

    return {
      'percentages': percentages,
      'total': total,
      'categories': categorySpending.keys.toList(),
    };
  }

  Map<String, dynamic> _analyzeSpendingPatterns(Map<DateTime, double> dailySpending) {
    if (dailySpending.isEmpty) return {};

    // Analyze weekday vs weekend spending
    final weekdaySpending = <double>[];
    final weekendSpending = <double>[];
    for (final entry in dailySpending.entries) {
      final isWeekend = entry.key.weekday == DateTime.saturday ||
          entry.key.weekday == DateTime.sunday;
      if (isWeekend) {
        weekendSpending.add(entry.value);
      } else {
        weekdaySpending.add(entry.value);
      }
    }

    // Calculate averages
    final weekdayAverage = weekdaySpending.isEmpty
        ? 0
        : weekdaySpending.reduce((a, b) => a + b) / weekdaySpending.length;
    final weekendAverage = weekendSpending.isEmpty
        ? 0
        : weekendSpending.reduce((a, b) => a + b) / weekendSpending.length;

    // Find highest spending day
    final highestSpendingDay = dailySpending.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'weekdayAverage': weekdayAverage,
      'weekendAverage': weekendAverage,
      'highestSpendingDay': highestSpendingDay,
      'weekdayCount': weekdaySpending.length,
      'weekendCount': weekendSpending.length,
    };
  }

  double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDifferences = values.map((value) => (value - mean) * (value - mean));
    final variance = squaredDifferences.reduce((a, b) => a + b) / values.length;
    return variance;
  }
} 