import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';
import 'expense_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'search_provider.g.dart';

// Search state providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

@riverpod
Future<List<Expense>> filteredExpenses(FilteredExpensesRef ref) async {
  final expenses = await ref.watch(expenseNotifierProvider.future);
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);

  return expenses.where((expense) {
    // Text search
    if (query.isNotEmpty &&
        !expense.title.toLowerCase().contains(query.toLowerCase()) &&
        !expense.description!.toLowerCase().contains(query.toLowerCase()) ==
            true) {
      return false;
    }

    // Category filter
    if (category != null && expense.category != category) {
      return false;
    }

    // Date range filter
    if (dateRange != null) {
      if (expense.date.isBefore(dateRange.start) ||
          expense.date.isAfter(dateRange.end)) {
        return false;
      }
    }

    return true;
  }).toList();
}
