import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../screens/expense_detail_screen.dart';
import '../screens/add_expense_screen.dart';

class ExpenseList extends ConsumerWidget {
  final List<Expense> expenses;
  final bool compact; // show more items per screen

  const ExpenseList({
    super.key,
    required this.expenses,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet.\nTap + to add your first expense!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final e = expenses[index];

        void openDetail() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpenseDetailScreen(expenseId: e.id),
            ),
          );
        }

        if (compact) {
          // Compact card: denser and shows up to 2 tags
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: openDetail,
              onLongPress: () {
                // Quick edit on long-press
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: e)));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _getCategoryColor(e.category).withOpacity(0.2),
                      child: Icon(_getCategoryIcon(e.category), color: _getCategoryColor(e.category), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(
                                e.title,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (e.isFavorite) const Icon(Icons.favorite, size: 14, color: Colors.red),
                          ]),
                          const SizedBox(height: 2),
                          Text(
                            '${e.category} • ${DateFormat('MMM dd, yyyy').format(e.date)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (e.tags.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: e.tags.take(2).map((t) => _smallTagChip(t)).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        _priorityChip(e.priority),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Regular detailed card with description/notes boxes and tags
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 2,
          child: InkWell(
            onTap: openDetail,
            onLongPress: () {
              // Quick edit on long-press
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: e)));
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: _getCategoryColor(e.category).withOpacity(0.2),
                        child: Icon(_getCategoryIcon(e.category), color: _getCategoryColor(e.category), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              if (e.isFavorite) const Icon(Icons.favorite, color: Colors.red, size: 16),
                            ]),
                            const SizedBox(height: 4),
                            Text('${e.category} • ${DateFormat('MMM dd, yyyy').format(e.date)}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            // Description box (blue)
                            if ((e.description ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _infoBox(
                                color: Colors.blue,
                                icon: Icons.description,
                                text: e.description!,
                                italic: true,
                                maxLines: 3,
                              ),
                            ],
                            // Notes box (amber)
                            if ((e.notes ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _infoBox(
                                color: Colors.amber,
                                icon: Icons.sticky_note_2,
                                text: e.notes!,
                                bold: true,
                                maxLines: 2,
                              ),
                            ],
                            // Location (subtle)
                            if ((e.location ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      e.location!,
                                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            _priorityChip(e.priority),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tags
                  if (e.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: e.tags.map((t) => _tagChip(t)).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Bottom row: status + quick actions
                  Row(
                    children: [
                      _statusChip(e.isPaid),
                      const Spacer(),
                      _actionIcon(
                        icon: e.isPaid ? Icons.undo : Icons.check,
                        color: e.isPaid ? Colors.orange : Colors.green,
                        onTap: () => ref.read(expenseNotifierProvider.notifier).togglePaidStatus(e.id),
                      ),
                      const SizedBox(width: 6),
                      _actionIcon(
                        icon: e.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        onTap: () => ref.read(expenseNotifierProvider.notifier).toggleFavorite(e.id),
                      ),
                      const SizedBox(width: 6),
                      _actionIcon(
                        icon: Icons.delete,
                        color: Colors.red,
                        onTap: () => _confirmDelete(context, ref, e),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Styled info box for description/notes
  Widget _infoBox({
    required MaterialColor color, // MaterialColor so shade700/shade800 are valid
    required IconData icon,
    required String text,
    int maxLines = 2,
    bool italic = false,
    bool bold = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cap width to avoid spanning the entire card; shrink-to-fit smaller text
        final maxWidth = constraints.maxWidth * 0.85;

        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // shrink to content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 14, color: color.shade700),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: color.shade800,
                        fontSize: 12,
                        fontStyle: italic ? FontStyle.italic : null,
                        fontWeight: bold ? FontWeight.w600 : null,
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _smallTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('#$tag', style: const TextStyle(fontSize: 10, color: Colors.blue)),
    );
  }

  Widget _priorityChip(String priority) {
    final map = {
      'urgent': {'label': 'URG', 'color': Colors.purple},
      'high': {'label': 'HIGH', 'color': Colors.red},
      'medium': {'label': 'MED', 'color': Colors.orange},
      'low': {'label': 'LOW', 'color': Colors.green},
    };
    final p = map[priority] ?? map['medium']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: (p['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(p['label'] as String, style: TextStyle(fontSize: 10, color: p['color'] as Color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statusChip(bool isPaid) {
    final color = isPaid ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isPaid ? Icons.check_circle : Icons.pending, size: 12, color: color),
        const SizedBox(width: 4),
        Text(isPaid ? 'Paid' : 'Pending', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _actionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: Colors.grey.withOpacity(0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.title} deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}