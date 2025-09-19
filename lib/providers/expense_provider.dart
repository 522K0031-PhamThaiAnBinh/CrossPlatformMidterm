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
}

// Computed providers for analytics
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