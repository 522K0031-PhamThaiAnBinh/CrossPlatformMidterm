import 'dart:math';
import 'package:uuid/uuid.dart';
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

  // Quick reset
  Future<void> deleteAllExpenses() async {
    await ref.read(storageServiceProvider).saveExpenses(const <Expense>[]);
    state = const AsyncValue.data(<Expense>[]);
  }

  // Toggle helpers
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

  // NEW: Seed test expenses dated from last 6 months up to today, ensuring all priorities appear
  Future<void> seedTestExpenses({int count = 50, bool clearBefore = false}) async {
    final rnd = Random();
    final now = DateTime.now();
    final uuid = const Uuid();

    // Keep categories aligned with the app/analytics normalization
    const categories = [
      'Food',
      'Transport',
      'Shopping',
      'Entertainment',
      'Bills',
      'Healthcare',
      'Education',
      'Other',
    ];
    const priorities = ['low', 'medium', 'high', 'urgent'];
    const tagPool = [
      'groceries',
      'work',
      'family',
      'fun',
      'monthly',
      'subscription',
      'sale',
      'urgent',
      'online',
      'cash',
    ];

    // Start from current or existing state
    List<Expense> base = clearBefore ? <Expense>[] : await future;

    // Ensure all priorities appear by cycling through them evenly, then shuffling
    final List<String> prioritiesCycled = List.generate(count, (i) => priorities[i % priorities.length]);
    prioritiesCycled.shuffle(rnd);

    for (int i = 0; i < count; i++) {
      // Choose a month within the last 6 months (0 = this month, 5 = 5 months ago)
      final monthOffset = rnd.nextInt(6); // [0..5]
      final monthStart = DateTime(now.year, now.month - monthOffset, 1);
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0); // last day of that month

      // Limit to today if in the current month
      final lastAllowedDay = monthOffset == 0 ? now.day : monthEnd.day;
      final day = 1 + rnd.nextInt(max(1, lastAllowedDay));
      final date = DateTime(monthStart.year, monthStart.month, day);

      final category = categories[rnd.nextInt(categories.length)];
      final amount = double.parse((rnd.nextDouble() * 200 + 5).toStringAsFixed(2));
      final priority = prioritiesCycled[i];
      final isPaid = rnd.nextDouble() < 0.7; // ~70% paid
      final isFavorite = rnd.nextDouble() < 0.2; // ~20% favorites

      final tagCount = rnd.nextInt(3); // 0..2 tags
      final tags = <String>{};
      while (tags.length < tagCount) {
        tags.add(tagPool[rnd.nextInt(tagPool.length)]);
      }

      final title = '$category ${amount.toStringAsFixed(0)}';
      final description = 'Auto-generated $category expense';
      final notes = rnd.nextBool() ? 'Seed data for testing' : null;

      base.add(
        Expense(
          id: uuid.v4(),
          title: title,
          amount: amount,
          category: category,
          date: date,
          description: description,
          tags: tags.toList(),
          isPaid: isPaid,
          priority: priority,
          isFavorite: isFavorite,
          location: null,
          notes: notes,
        ),
      );
    }

    // Keep list ordered by most recent
    base.sort((a, b) => b.date.compareTo(a.date));

    await ref.read(storageServiceProvider).saveExpenses(base);
    state = AsyncValue.data(base);
  }
}

// -------------------- Computed providers --------------------

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
        categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
      return categoryTotals;
    },
    loading: () => <String, double>{},
    error: (_, __) => <String, double>{},
  );
}

@riverpod
double totalExpensesThisMonth(TotalExpensesThisMonthRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final thisMonthExpenses =
          expenses.where((expense) => expense.date.year == now.year && expense.date.month == now.month);
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
    loading: () => const <Expense>[],
    error: (_, __) => const <Expense>[],
  );
}

@riverpod
List<Expense> unpaidExpenses(UnpaidExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.where((expense) => !expense.isPaid).toList(),
    loading: () => const <Expense>[],
    error: (_, __) => const <Expense>[],
  );
}

@riverpod
List<Expense> favoriteExpenses(FavoriteExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.where((e) => e.isFavorite).toList(),
    loading: () => const <Expense>[],
    error: (_, __) => const <Expense>[],
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
    loading: () => <String, double>{},
    error: (_, __) => <String, double>{},
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
      final list = allTags.toList()..sort();
      return list;
    },
    loading: () => const <String>[],
    error: (_, __) => const <String>[],
  );
}

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
  return categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
}

// Helper providers used by AnalyticsScreen (if you use those there)
@riverpod
Map<int, double> monthlyExpenses(MonthlyExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - 5, 1);
      final Map<int, double> totals = {
        for (int i = 0; i < 6; i++) DateTime(now.year, now.month - i, 1).month: 0.0
      };

      for (final e in expenses) {
        final d = DateTime(e.date.year, e.date.month, 1);
        if (!d.isBefore(start) && !d.isAfter(DateTime(now.year, now.month, 1))) {
          totals[e.date.month] = (totals[e.date.month] ?? 0) + e.amount;
        }
      }
      return totals;
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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final from = today.subtract(const Duration(days: 29));
      final recent = expenses.where((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return !d.isBefore(from) && !d.isAfter(today);
      });
      final total = recent.fold(0.0, (sum, expense) => sum + expense.amount);
      return total / 30.0;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}