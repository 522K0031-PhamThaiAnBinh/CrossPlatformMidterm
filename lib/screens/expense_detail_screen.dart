import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseNotifierProvider);

    return expensesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Expense Detail')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (expenses) {
        final expense = expenses.firstWhere(
          (e) => e.id == expenseId,
          orElse: () => null as Expense, // will be handled below
        );

        if (expense == null) {
          // If expense was deleted while viewing details
          return Scaffold(
            appBar: AppBar(title: const Text('Expense Detail')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('This expense no longer exists.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        final cs = Theme.of(context).colorScheme;
        final dateStr = DateFormat('MMM dd, yyyy').format(expense.date);

        return Scaffold(
          appBar: AppBar(
            title: Text(expense.title),
            backgroundColor: cs.inversePrimary,
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(expense: expense),
                    ),
                  );
                  // On return, Riverpod will refresh the detail with latest state automatically
                },
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref, expense),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => ref.read(expenseNotifierProvider.notifier).togglePaidStatus(expense.id),
            icon: Icon(expense.isPaid ? Icons.undo : Icons.check_circle),
            label: Text(expense.isPaid ? 'Mark Unpaid' : 'Mark Paid'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Amount + priority
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                          child: Icon(
                            _getCategoryIcon(expense.category),
                            color: _getCategoryColor(expense.category),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('${expense.category} • $dateStr',
                                  style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                        _priorityChip(expense.priority),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Status + favorite
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _statusChip(expense.isPaid),
                        const SizedBox(width: 8),
                        _favoriteChip(context, ref, expense),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Toggle Favorite',
                          icon: Icon(
                            expense.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => ref.read(expenseNotifierProvider.notifier).toggleFavorite(expense.id),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                if ((expense.description ?? '').isNotEmpty) ...[
                  _labeledSection(
                    icon: Icons.description,
                    label: 'Description',
                    child: Text(
                      expense.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Notes
                if ((expense.notes ?? '').isNotEmpty) ...[
                  _labeledSection(
                    icon: Icons.sticky_note_2,
                    label: 'Notes',
                    child: Text(
                      expense.notes!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Location
                if ((expense.location ?? '').isNotEmpty) ...[
                  _labeledSection(
                    icon: Icons.location_on,
                    label: 'Location',
                    child: Text(expense.location!, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 12),
                ],

                // Tags
                if (expense.tags.isNotEmpty) ...[
                  _labeledSection(
                    icon: Icons.tag,
                    label: 'Tags',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: expense.tags
                          .map((t) => Chip(
                                label: Text('#$t'),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _labeledSection({required IconData icon, required String label, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String priority) {
    final map = {
      'urgent': {'label': 'URGENT', 'color': Colors.purple},
      'high': {'label': 'HIGH', 'color': Colors.red},
      'medium': {'label': 'MEDIUM', 'color': Colors.orange},
      'low': {'label': 'LOW', 'color': Colors.green},
    };
    final p = map[priority] ?? map['medium']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: (p['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(
        p['label'] as String,
        style: TextStyle(fontSize: 11, color: p['color'] as Color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _statusChip(bool isPaid) {
    final color = isPaid ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPaid ? Icons.check_circle : Icons.pending, size: 14, color: color),
          const SizedBox(width: 6),
          Text(isPaid ? 'Paid' : 'Pending',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _favoriteChip(BuildContext context, WidgetRef ref, Expense e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.favorite, size: 14, color: Colors.red),
          SizedBox(width: 6),
          Text('Favorite', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Expense e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete "${e.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(expenseNotifierProvider.notifier).deleteExpense(e.id);
              Navigator.pop(context);
              Navigator.pop(context); // leave detail screen
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.title} deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'bills':
        return Colors.red;
      case 'healthcare':
        return Colors.green;
      case 'education':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}