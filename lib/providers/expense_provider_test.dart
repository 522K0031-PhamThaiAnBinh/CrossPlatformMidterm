import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_riverpod/models/expense.dart';
import 'package:expense_tracker_riverpod/providers/expense_provider.dart';

void main() {
  group('ExpenseNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with empty list', () async {
      final notifier = container.read(expenseNotifierProvider.notifier);
      final state = await container.read(expenseNotifierProvider.future);
      
      expect(state, isEmpty);
    });

    test('should add expense correctly', () async {
      final notifier = container.read(expenseNotifierProvider.notifier);
      final expense = Expense(
        id: '1',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Food',
        date: DateTime.now(),
      );

      await notifier.addExpense(expense);
      final state = await container.read(expenseNotifierProvider.future);

      expect(state.length, 1);
      expect(state.first, expense);
    });
  });
}