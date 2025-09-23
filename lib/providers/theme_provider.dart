import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/storage_service.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<ThemeMode> build() async {
    final savedTheme = await ref.read(storageServiceProvider).getThemeMode();
    return savedTheme ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(storageServiceProvider).saveThemeMode(mode);
    state = AsyncValue.data(mode);
  }

  Future<void> toggleTheme() async {
    final current = await future;
    final newMode = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}