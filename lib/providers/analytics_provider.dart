import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';
import 'expense_provider.dart';

part 'analytics_provider.g.dart';

@riverpod
Map<int, double> monthlyExpenses(MonthlyExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final Map<int, double> monthlyTotals = {};
      final now = DateTime.now();
      
      // Initialize last 12 months with proper year handling
      for (int i = 0; i < 12; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthKey = monthDate.month + (monthDate.year * 100); // ✅ Better month key
        monthlyTotals[monthKey] = 0.0;
      }
      
      // Calculate actual totals for current year only
      for (final expense in expenses) {
        // Only include expenses from the current year
        if (expense.date.year == now.year) {
          final monthKey = expense.date.month + (expense.date.year * 100);
          monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
        }
      }
      
      // Convert back to simple month numbers for the current year
      final Map<int, double> currentYearMonths = {};
      for (int month = 1; month <= 12; month++) {
        final monthKey = month + (now.year * 100);
        currentYearMonths[month] = monthlyTotals[monthKey] ?? 0.0;
      }
      
      return currentYearMonths;
    },
    loading: () => <int, double>{},
    error: (_, __) => <int, double>{},
  );
}

@riverpod
double averageDailyExpense(AverageDailyExpenseRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      if (expenses.isEmpty) return 0.0;
      
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final recentExpenses = expenses.where(
        (expense) => expense.date.isAfter(thirtyDaysAgo),
      );
      
      if (recentExpenses.isEmpty) return 0.0;
      
      final total = recentExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      return total / 30;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

@riverpod
List<Expense> expensesThisMonth(ExpensesThisMonthRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      return expenses.where(
        (expense) => expense.date.isAfter(startOfMonth),
      ).toList();
    },
    loading: () => <Expense>[],
    error: (_, __) => <Expense>[],
  );
}

@riverpod
Map<String, int> expenseCountByCategory(ExpenseCountByCategoryRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final Map<String, int> categoryCounts = {};
      for (final expense in expenses) {
        categoryCounts[expense.category] = 
            (categoryCounts[expense.category] ?? 0) + 1;
      }
      return categoryCounts;
    },
    loading: () => <String, int>{},
    error: (_, __) => <String, int>{},
  );
}

// Additional useful providers for analytics
@riverpod
double totalExpensesThisWeek(TotalExpensesThisWeekRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      final thisWeekExpenses = expenses.where(
        (expense) => expense.date.isAfter(weekAgo),
      );
      
      return thisWeekExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

@riverpod
String highestSpendingMonth(HighestSpendingMonthRef ref) {
  final monthlyData = ref.watch(monthlyExpensesProvider);
  if (monthlyData.isEmpty) return 'No data';
  
  final highestEntry = monthlyData.entries
      .reduce((a, b) => a.value > b.value ? a : b);
  
  final monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  return monthNames[highestEntry.key];
}