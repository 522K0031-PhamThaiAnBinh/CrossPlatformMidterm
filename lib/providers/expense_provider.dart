import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

part 'expense_provider.g.dart';

@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  Future<List<Expense>> build() async {
    return await ref.read(storageServiceProvider).loadExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    final currentState = await future;
    final updatedList = [...currentState, expense];
    
    await ref.read(storageServiceProvider).saveExpenses(updatedList);
    state = AsyncValue.data(updatedList);
  }

  Future<void> updateExpense(String id, Expense updatedExpense) async {
    final currentState = await future;
    final updatedList = currentState.map((e) => e.id == id ? updatedExpense : e).toList();
    
    await ref.read(storageServiceProvider).saveExpenses(updatedList);
    state = AsyncValue.data(updatedList);
  }

  Future<void> deleteExpense(String id) async {
    final currentState = await future;
    final updatedList = currentState.where((e) => e.id != id).toList();
    
    await ref.read(storageServiceProvider).saveExpenses(updatedList);
    state = AsyncValue.data(updatedList);
  }

  // NEW: Enhanced methods
  Future<void> togglePaidStatus(String id) async {
    final currentState = await future;
    final expense = currentState.firstWhere((e) => e.id == id);
    await updateExpense(id, expense.copyWith(isPaid: !expense.isPaid));
  }

  Future<void> toggleFavorite(String id) async {
    final currentState = await future;
    final expense = currentState.firstWhere((e) => e.id == id);
    await updateExpense(id, expense.copyWith(isFavorite: !expense.isFavorite));
  }

  Future<void> updatePriority(String id, String priority) async {
    final currentState = await future;
    final expense = currentState.firstWhere((e) => e.id == id);
    await updateExpense(id, expense.copyWith(priority: priority));
  }
}

// FIXED: Synchronous computed providers (like your original working style)
@riverpod
double totalExpenses(TotalExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.fold(0.0, (sum, expense) => sum + expense.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

@riverpod
Map<String, double> expensesByCategory(ExpensesByCategoryRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final Map<String, double> categoryTotals = {};
      for (final expense in expenses) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
      return categoryTotals;
    },
    loading: () => {},
    error: (_, __) => {},
  );
}

// NEW: Advanced computed providers (fixed to match your pattern)
@riverpod
double totalExpensesThisMonth(TotalExpensesThisMonthRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final thisMonthExpenses = expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month
      ).toList();
      
      return thisMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

@riverpod
List<Expense> expensesByPriority(ExpensesByPriorityRef ref, String priority) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.where((expense) => expense.priority == priority).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<Expense> unpaidExpenses(UnpaidExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.where((expense) => !expense.isPaid).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<Expense> favoriteExpenses(FavoriteExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.where((expense) => expense.isFavorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
Map<String, double> monthlySpendingTrend(MonthlySpendingTrendRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final Map<String, double> monthlyTotals = {};
      
      for (final expense in expenses) {
        final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }
      
      return monthlyTotals;
    },
    loading: () => {},
    error: (_, __) => {},
  );
}

@riverpod
List<String> availableTags(AvailableTagsRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final Set<String> allTags = {};
      
      for (final expense in expenses) {
        allTags.addAll(expense.tags);
      }
      
      return allTags.toList()..sort();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

// NEW: Additional useful computed providers
@riverpod
int expenseCount(ExpenseCountRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

@riverpod
double averageExpenseAmount(AverageExpenseAmountRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      if (expenses.isEmpty) return 0.0;
      final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      return total / expenses.length;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

@riverpod
String topSpendingCategory(TopSpendingCategoryRef ref) {
  final categoryTotals = ref.watch(expensesByCategoryProvider);
  if (categoryTotals.isEmpty) return 'No expenses';
  
  return categoryTotals.entries
    .reduce((a, b) => a.value > b.value ? a : b)
    .key;
}