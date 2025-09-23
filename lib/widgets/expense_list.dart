import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';

class ExpenseList extends ConsumerWidget {
  final List<Expense> expenses;

  const ExpenseList({super.key, required this.expenses});

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
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final hasDescription = expense.description != null && expense.description!.isNotEmpty;
        final hasNotes = expense.notes != null && expense.notes!.isNotEmpty;
        final hasAdditionalInfo = hasDescription || hasNotes || 
                                 (expense.location != null && expense.location!.isNotEmpty);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Main content row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category avatar
                      CircleAvatar(
                        backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                        child: Icon(
                          _getCategoryIcon(expense.category),
                          color: _getCategoryColor(expense.category),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Main content - takes up remaining space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row with favorite icon
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (expense.isFavorite)
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            
                            // Category and date
                            Text(
                              '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            
                            // Description - NOW VISIBLE! 🎉
                            if (hasDescription) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 12,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        expense.description!,
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            // Notes - NOW VISIBLE! 📝
                            if (hasNotes) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sticky_note_2,
                                      size: 12,
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        expense.notes!,
                                        style: TextStyle(
                                          color: Colors.amber[800],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Amount and priority column
                      SizedBox(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildPriorityChip(expense.priority),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Show additional info indicators if content is long
                  if (hasAdditionalInfo) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Info indicators
                        if (hasDescription && expense.description!.length > 50)
                          _buildInfoChip(Icons.description, 'Full description available', Colors.blue),
                        if (hasDescription && hasNotes)
                          const SizedBox(width: 4),
                        if (hasNotes && expense.notes!.length > 30)
                          _buildInfoChip(Icons.sticky_note_2, 'Additional notes', Colors.amber),
                        
                        const Spacer(),
                        
                        // Location
                        if (expense.location != null && expense.location!.isNotEmpty) ...[
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              expense.location!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Bottom row with status and actions
                  Row(
                    children: [
                      // Payment status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: expense.isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: expense.isPaid ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              expense.isPaid ? Icons.check_circle : Icons.pending,
                              size: 12,
                              color: expense.isPaid ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              expense.isPaid ? 'Paid' : 'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                color: expense.isPaid ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle paid status
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
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
                          
                          const SizedBox(width: 4),
                          
                          // Toggle favorite
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
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
                          
                          const SizedBox(width: 4),
                          
                          // Delete button
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 16,
                              onPressed: () {
                                _showDeleteConfirmation(context, ref, expense);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Tags if available
                  if (expense.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: expense.tags.take(3).map((tag) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String tooltip, Color color) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          size: 10,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final priorityData = _getPriorityData(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priorityData['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priorityData['label'],
        style: TextStyle(
          fontSize: 10,
          color: priorityData['color'],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getPriorityData(String priority) {
    switch (priority) {
      case 'low':
        return {'label': 'Low', 'color': Colors.green};
      case 'medium':
        return {'label': 'Med', 'color': Colors.orange};
      case 'high':
        return {'label': 'High', 'color': Colors.red};
      case 'urgent':
        return {'label': 'Urgent', 'color': Colors.purple};
      default:
        return {'label': 'Med', 'color': Colors.orange};
    }
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
      case 'health':
        return Colors.green;
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
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(expenseNotifierProvider.notifier).deleteExpense(expense.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${expense.title} deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}