import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

class StorageService {
  static const String _expensesKey = 'expenses';

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList(_expensesKey) ?? [];
    
    return expensesJson
        .map((json) => Expense.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = expenses
        .map((expense) => jsonEncode(expense.toJson()))
        .toList();
    
    await prefs.setStringList(_expensesKey, expensesJson);
  }
}