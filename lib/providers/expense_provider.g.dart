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
    r'c55712f3f5e467f073a170be2a070a5fc81d8a53';

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
String _$totalExpensesThisMonthHash() =>
    r'9baacd5332debfdfa227e62895f4ad786d8ac3a6';

/// See also [totalExpensesThisMonth].
@ProviderFor(totalExpensesThisMonth)
final totalExpensesThisMonthProvider = AutoDisposeProvider<double>.internal(
  totalExpensesThisMonth,
  name: r'totalExpensesThisMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalExpensesThisMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalExpensesThisMonthRef = AutoDisposeProviderRef<double>;
String _$expensesByPriorityHash() =>
    r'682fbfc2735aa66bbb16ea6b737df99e3e4b11f1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [expensesByPriority].
@ProviderFor(expensesByPriority)
const expensesByPriorityProvider = ExpensesByPriorityFamily();

/// See also [expensesByPriority].
class ExpensesByPriorityFamily extends Family<List<Expense>> {
  /// See also [expensesByPriority].
  const ExpensesByPriorityFamily();

  /// See also [expensesByPriority].
  ExpensesByPriorityProvider call(
    String priority,
  ) {
    return ExpensesByPriorityProvider(
      priority,
    );
  }

  @override
  ExpensesByPriorityProvider getProviderOverride(
    covariant ExpensesByPriorityProvider provider,
  ) {
    return call(
      provider.priority,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'expensesByPriorityProvider';
}

/// See also [expensesByPriority].
class ExpensesByPriorityProvider extends AutoDisposeProvider<List<Expense>> {
  /// See also [expensesByPriority].
  ExpensesByPriorityProvider(
    String priority,
  ) : this._internal(
          (ref) => expensesByPriority(
            ref as ExpensesByPriorityRef,
            priority,
          ),
          from: expensesByPriorityProvider,
          name: r'expensesByPriorityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expensesByPriorityHash,
          dependencies: ExpensesByPriorityFamily._dependencies,
          allTransitiveDependencies:
              ExpensesByPriorityFamily._allTransitiveDependencies,
          priority: priority,
        );

  ExpensesByPriorityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.priority,
  }) : super.internal();

  final String priority;

  @override
  Override overrideWith(
    List<Expense> Function(ExpensesByPriorityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpensesByPriorityProvider._internal(
        (ref) => create(ref as ExpensesByPriorityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        priority: priority,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Expense>> createElement() {
    return _ExpensesByPriorityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesByPriorityProvider && other.priority == priority;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExpensesByPriorityRef on AutoDisposeProviderRef<List<Expense>> {
  /// The parameter `priority` of this provider.
  String get priority;
}

class _ExpensesByPriorityProviderElement
    extends AutoDisposeProviderElement<List<Expense>>
    with ExpensesByPriorityRef {
  _ExpensesByPriorityProviderElement(super.provider);

  @override
  String get priority => (origin as ExpensesByPriorityProvider).priority;
}

String _$unpaidExpensesHash() => r'a790623af6c4a087f6d4a485d90cf01122dd2afd';

/// See also [unpaidExpenses].
@ProviderFor(unpaidExpenses)
final unpaidExpensesProvider = AutoDisposeProvider<List<Expense>>.internal(
  unpaidExpenses,
  name: r'unpaidExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unpaidExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnpaidExpensesRef = AutoDisposeProviderRef<List<Expense>>;
String _$favoriteExpensesHash() => r'b3cd764439e4b770df44ceb5eb6a0a1b66615530';

/// See also [favoriteExpenses].
@ProviderFor(favoriteExpenses)
final favoriteExpensesProvider = AutoDisposeProvider<List<Expense>>.internal(
  favoriteExpenses,
  name: r'favoriteExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteExpensesRef = AutoDisposeProviderRef<List<Expense>>;
String _$monthlySpendingTrendHash() =>
    r'fbfd67e349688f85307ff7433049ef671d795812';

/// See also [monthlySpendingTrend].
@ProviderFor(monthlySpendingTrend)
final monthlySpendingTrendProvider =
    AutoDisposeProvider<Map<String, double>>.internal(
  monthlySpendingTrend,
  name: r'monthlySpendingTrendProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlySpendingTrendHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlySpendingTrendRef = AutoDisposeProviderRef<Map<String, double>>;
String _$availableTagsHash() => r'555ba8f2a4966ab647d937bc7fae26ba1dd2d3a2';

/// See also [availableTags].
@ProviderFor(availableTags)
final availableTagsProvider = AutoDisposeProvider<List<String>>.internal(
  availableTags,
  name: r'availableTagsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableTagsRef = AutoDisposeProviderRef<List<String>>;
String _$expenseCountHash() => r'ca9d268c989a7968eabc5b3ae0829a9842459344';

/// See also [expenseCount].
@ProviderFor(expenseCount)
final expenseCountProvider = AutoDisposeProvider<int>.internal(
  expenseCount,
  name: r'expenseCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$expenseCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseCountRef = AutoDisposeProviderRef<int>;
String _$averageExpenseAmountHash() =>
    r'433808deced9a49e9ccf6ac1bc96477b1e44783b';

/// See also [averageExpenseAmount].
@ProviderFor(averageExpenseAmount)
final averageExpenseAmountProvider = AutoDisposeProvider<double>.internal(
  averageExpenseAmount,
  name: r'averageExpenseAmountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$averageExpenseAmountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AverageExpenseAmountRef = AutoDisposeProviderRef<double>;
String _$topSpendingCategoryHash() =>
    r'd97917e1d660bdfa38cceddc65c5e44af0bfb10e';

/// See also [topSpendingCategory].
@ProviderFor(topSpendingCategory)
final topSpendingCategoryProvider = AutoDisposeProvider<String>.internal(
  topSpendingCategory,
  name: r'topSpendingCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topSpendingCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopSpendingCategoryRef = AutoDisposeProviderRef<String>;
String _$monthlyExpensesHash() => r'a82362552f8a2de874aa169e6420f417ddfb85d6';

/// See also [monthlyExpenses].
@ProviderFor(monthlyExpenses)
final monthlyExpensesProvider = AutoDisposeProvider<Map<int, double>>.internal(
  monthlyExpenses,
  name: r'monthlyExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyExpensesRef = AutoDisposeProviderRef<Map<int, double>>;
String _$averageDailyExpenseHash() =>
    r'63845f0924e95eb5734b45bc7c0f120c118a8710';

/// See also [averageDailyExpense].
@ProviderFor(averageDailyExpense)
final averageDailyExpenseProvider = AutoDisposeProvider<double>.internal(
  averageDailyExpense,
  name: r'averageDailyExpenseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$averageDailyExpenseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AverageDailyExpenseRef = AutoDisposeProviderRef<double>;
String _$expenseNotifierHash() => r'3109ac5fe51b0c24edb4dad0722e80d761c69cbe';

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
