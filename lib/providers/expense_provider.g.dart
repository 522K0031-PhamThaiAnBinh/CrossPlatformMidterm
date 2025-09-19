// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalExpensesHash() => r'9060392fcd16dbfa18f1668808211698682e5e76';

/// See also [totalExpenses].
@ProviderFor(totalExpenses)
final totalExpensesProvider = AutoDisposeProvider<double>.internal(
  totalExpenses,
  name: r'totalExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalExpensesRef = AutoDisposeProviderRef<double>;
String _$expensesByCategoryHash() =>
    r'aa46a7fdd710bc4089d611c84a05f46c1a1e586c';

/// See also [expensesByCategory].
@ProviderFor(expensesByCategory)
final expensesByCategoryProvider =
    AutoDisposeProvider<Map<String, double>>.internal(
  expensesByCategory,
  name: r'expensesByCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expensesByCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpensesByCategoryRef = AutoDisposeProviderRef<Map<String, double>>;
String _$expenseNotifierHash() => r'9f7c951ecc271650924fe2da999b7fb940fe872b';

/// See also [ExpenseNotifier].
@ProviderFor(ExpenseNotifier)
final expenseNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ExpenseNotifier, List<Expense>>.internal(
  ExpenseNotifier.new,
  name: r'expenseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseNotifier = AutoDisposeAsyncNotifier<List<Expense>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
