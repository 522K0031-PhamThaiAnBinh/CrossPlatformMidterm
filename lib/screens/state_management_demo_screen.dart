import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/analytics_provider.dart';

class StateManagementDemoScreen extends ConsumerWidget {
  const StateManagementDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Reactive State Updates',
              'Watch how UI automatically updates when state changes',
              [
                _ReactiveStateDemo(),
                const SizedBox(height: 16),
                const Text(
                  '💡 Riverpod automatically rebuilds only widgets that depend on changed state',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              'Computed State (Derived State)',
              'State that automatically recalculates based on other state',
              [
                _ComputedStateDemo(),
                const SizedBox(height: 16),
                const Text(
                  '💡 Analytics automatically update when expenses change - no manual synchronization needed',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              'State Management Patterns',
              'Different ways to manage state in your app',
              [
                _StatePatternDemo(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              'Performance Benefits',
              'How Riverpod optimizes your app',
              [
                _PerformanceDemo(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String description, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ReactiveStateDemo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalExpenses = ref.watch(totalExpensesProvider);
    final expenseCount = ref.watch(expenseCountProvider);
    final favoriteCount = ref.watch(favoriteExpensesProvider).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatBox(
                title: 'Total',
                value: '\$${totalExpenses.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatBox(
                title: 'Count',
                value: expenseCount.toString(),
                icon: Icons.receipt,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatBox(
                title: 'Favorites',
                value: favoriteCount.toString(),
                icon: Icons.favorite,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '👆 These values update automatically when you add, edit, or delete expenses',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _ComputedStateDemo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyTotal = ref.watch(totalExpensesThisMonthProvider);
    final categoryTotals = ref.watch(expensesByCategoryProvider);
    final topCategory = ref.watch(topSpendingCategoryProvider);
    final averageAmount = ref.watch(averageExpenseAmountProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatBox(
                title: 'This Month',
                value: '\$${monthlyTotal.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatBox(
                title: 'Average',
                value: '\$${averageAmount.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Top Category: $topCategory'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatePatternDemo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PatternExample(
          title: '1. Provider Pattern',
          description: 'Global state accessible anywhere',
          code: 'ref.watch(expenseNotifierProvider)',
          example: 'Your expense list, analytics',
        ),
        const SizedBox(height: 12),
        _PatternExample(
          title: '2. Computed Provider Pattern',
          description: 'Derived state that auto-updates',
          code: 'ref.watch(totalExpensesProvider)',
          example: 'Total calculations, filtered lists',
        ),
        const SizedBox(height: 12),
        _PatternExample(
          title: '3. AsyncNotifier Pattern',
          description: 'Async operations with loading states',
          code: 'class ExpenseNotifier extends AsyncNotifier',
          example: 'Loading/saving expenses',
        ),
        const SizedBox(height: 12),
        _PatternExample(
          title: '4. Family Provider Pattern',
          description: 'Parameterized providers',
          code: 'expensesByPriority(priority)',
          example: 'Filter by priority, category',
        ),
      ],
    );
  }
}

class _PerformanceDemo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _PerformanceBenefit(
          icon: Icons.speed,
          title: 'Selective Rebuilds',
          description: 'Only widgets watching changed providers rebuild',
        ),
        _PerformanceBenefit(
          icon: Icons.memory,
          title: 'Automatic Disposal',
          description: 'Providers dispose when no longer needed',
        ),
        _PerformanceBenefit(
          icon: Icons.cached,
          title: 'Built-in Caching',
          description: 'Computed values cached until dependencies change',
        ),
        _PerformanceBenefit(
          icon: Icons.bug_report,
          title: 'Compile-time Safety',
          description: 'Code generation prevents runtime errors',
        ),
      ],
    );
  }
}

// Helper Widgets
class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _PatternExample extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final String example;

  const _PatternExample({
    required this.title,
    required this.description,
    required this.code,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(description, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          Text(
            'Used in: $example',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _PerformanceBenefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PerformanceBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}