import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/expense.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

class StorageService {
  static const String _expensesKey = 'expenses';
  static const String _themeKey = 'theme_mode';
  static const String _settingsKey = 'user_settings';

  Future<List<Expense>> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = prefs.getStringList(_expensesKey) ?? [];
      
      return expensesJson.map((json) {
        final Map<String, dynamic> expenseData = jsonDecode(json);
        
        // Handle backward compatibility for new fields
        expenseData['tags'] ??= <String>[];
        expenseData['isPaid'] ??= false;
        expenseData['priority'] ??= 'medium';
        expenseData['isFavorite'] ??= false;
        
        return Expense.fromJson(expenseData);
      }).toList();
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = expenses
          .map((expense) => jsonEncode(expense.toJson()))
          .toList();
      
      await prefs.setStringList(_expensesKey, expensesJson);
    } catch (e) {
      print('Error saving expenses: $e');
      rethrow;
    }
  }

  // NEW: Theme persistence
  Future<ThemeMode?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex == null) return null;
    return ThemeMode.values[themeIndex];
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  // NEW: Settings persistence
  Future<Map<String, dynamic>> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson == null) return {};
    return jsonDecode(settingsJson);
  }

  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }
}