import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart' as xp;

class StateManagementDemoScreen extends ConsumerWidget {
  const StateManagementDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Live stats from your real providers
    final total = ref.watch(xp.totalExpensesProvider);
    final count = ref.watch(xp.expenseCountProvider);
    final unpaidCount = ref.watch(xp.unpaidExpensesProvider).length;
    final favoriteCount = ref.watch(xp.favoriteExpensesProvider).length;
    final totalThisMonth = ref.watch(xp.totalExpensesThisMonthProvider);
    final avgDaily = ref.watch(xp.averageDailyExpenseProvider);
    final topCategory = ref.watch(xp.topSpendingCategoryProvider);

    final expensesAsync = ref.watch(xp.expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Demo'),
        backgroundColor: cs.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Seed 50 sample expenses',
            icon: const Icon(Icons.addchart),
            onPressed: () async {
              await ref.read(xp.expenseNotifierProvider.notifier)
                  .seedTestExpenses(count: 50);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added 50 sample expenses')),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Delete all expenses',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await ref.read(xp.expenseNotifierProvider.notifier)
                  .deleteAllExpenses();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All expenses deleted')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total',
                  value: '\$${total.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'This Month',
                  value: '\$${totalThisMonth.toStringAsFixed(2)}',
                  color: Colors.blue,
                  icon: Icons.calendar_month,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Avg Daily (30d)',
                  value: '\$${avgDaily.toStringAsFixed(2)}',
                  color: Colors.teal,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Top Category',
                  value: topCategory,
                  color: Colors.purple,
                  icon: Icons.category,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Expenses',
                  value: '$count',
                  color: Colors.indigo,
                  icon: Icons.list_alt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Unpaid / Fav',
                  value: '$unpaidCount / $favoriteCount',
                  color: Colors.orange,
                  icon: Icons.star_border,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text('Recent Expenses', style: text.titleMedium),
          const SizedBox(height: 8),

          expensesAsync.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
            data: (expenses) {
              if (expenses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No expenses yet. Use the + button on Home or seed here.'),
                );
              }
              final recent = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
              final top5 = recent.take(5).toList();
              return Column(
                children: top5.map((e) {
                  return Card(
                    child: ListTile(
                      dense: false,
                      leading: CircleAvatar(
                        backgroundColor: _categoryColor(e.category).withOpacity(0.2),
                        child: Icon(_categoryIcon(e.category),
                            color: _categoryColor(e.category)),
                      ),
                      title: Text(e.title, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${e.category} • ${_fmtDate(e.date)}'
                          '${e.isPaid ? '' : ' • Unpaid'}'
                          '${e.isFavorite ? ' • ★' : ''}'),
                      trailing: Text('\$${e.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${_m3[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  static const _m3 = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  Color _categoryColor(String c) {
    switch (c.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'shopping': return Colors.purple;
      case 'entertainment': return Colors.pink;
      case 'bills': return Colors.red;
      case 'healthcare': return Colors.green;
      case 'education': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _categoryIcon(String c) {
    switch (c.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'entertainment': return Icons.movie;
      case 'bills': return Icons.receipt;
      case 'healthcare': return Icons.local_hospital;
      case 'education': return Icons.school;
      default: return Icons.category;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}