import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';

class EnhancedExpenseList extends ConsumerWidget {
  final List<Expense> expenses;
  final bool isPaidSection;
  final String emptyMessage;

  const EnhancedExpenseList({
    super.key,
    required this.expenses,
    required this.isPaidSection,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaidSection ? Icons.check_circle_outline : Icons.pending_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpenseScreen(expense: expense),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Priority indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(expense.priority),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Category avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: _getCategoryColor(expense.category),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Main content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (expense.isFavorite)
                                const Icon(Icons.favorite, color: Colors.red, size: 14),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${expense.category} • ${DateFormat('MMM dd').format(expense.date)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount and actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPriorityChip(expense.priority),
                            const SizedBox(width: 4),
                            // Quick action buttons
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                onPressed: () {
                                  ref.read(expenseNotifierProvider.notifier)
                                      .togglePaidStatus(expense.id);
                                },
                                icon: Icon(
                                  expense.isPaid ? Icons.undo : Icons.check,
                                  color: expense.isPaid ? Colors.orange : Colors.green,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 14,
                                onPressed: () {
                                  ref.read(expenseNotifierProvider.notifier)
                                      .toggleFavorite(expense.id);
                                },
                                icon: Icon(
                                  expense.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityChip(String priority) {
    final priorityData = _getPriorityData(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: priorityData['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priorityData['label'],
        style: TextStyle(
          fontSize: 9,
          color: priorityData['color'],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getPriorityData(String priority) {
    switch (priority) {
      case 'urgent': return {'label': 'URG', 'color': Colors.purple};
      case 'high': return {'label': 'HIGH', 'color': Colors.red};
      case 'medium': return {'label': 'MED', 'color': Colors.orange};
      case 'low': return {'label': 'LOW', 'color': Colors.green};
      default: return {'label': 'MED', 'color': Colors.orange};
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent': return Colors.purple;
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.orange;
    }
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
}