import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart'; // ✅ Add this import!
import '../providers/expense_provider.dart';
import '../widgets/expense_list.dart'; // ✅ Use existing widget for now
import '../widgets/add_expense_fab.dart';
import '../widgets/expense_summary.dart';
import 'analytics_screen.dart';
import 'search_screen.dart';
import 'state_management_demo_screen.dart';
import 'comparison_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showFavoritesOnly = false;
  String _priorityFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // ✅ Fixed method signature
    final expensesAsync = ref.watch(expenseNotifierProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_book),
            tooltip: 'State Management Demos',
            onSelected: (value) {
              switch (value) {
                case 'demo':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StateManagementDemoScreen()),
                  );
                  break;
                case 'comparison':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'demo',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('State Management Demo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'comparison',
                child: Row(
                  children: [
                    Icon(Icons.compare, size: 20),
                    SizedBox(width: 8),
                    Text('Comparison Analysis'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) => Column(
          children: [
            // Enhanced Summary
            ExpenseSummary(total: totalExpenses),
            
            // Quick Filter Controls
            _buildQuickFilters(),
            
            // Favorites Section
            if (_shouldShowFavorites(expenses))
              _buildFavoritesSection(expenses),
            
            // Tab Bar for Paid/Unpaid
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pending, size: 16),
                        const SizedBox(width: 4),
                        Text('Unpaid (${_getUnpaidCount(expenses)})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 16),
                        const SizedBox(width: 4),
                        Text('Paid (${_getPaidCount(expenses)})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Unpaid Expenses
                  _buildExpenseList(
                    _getFilteredExpenses(expenses, false),
                    'No unpaid expenses! 🎉',
                    Icons.pending_outlined,
                  ),
                  // Paid Expenses
                  _buildExpenseList(
                    _getFilteredExpenses(expenses, true),
                    'No paid expenses yet.',
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: const AddExpenseFab(),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Favorites Toggle
          Expanded(
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: _showFavoritesOnly ? Colors.white : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showFavoritesOnly ? 'Favorites' : 'All',
                    style: TextStyle(
                      color: _showFavoritesOnly ? Colors.white : null,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              selected: _showFavoritesOnly,
              onSelected: (_) {
                setState(() {
                  _showFavoritesOnly = !_showFavoritesOnly;
                });
              },
              selectedColor: Colors.red,
              checkmarkColor: Colors.white,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Priority Filter
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _priorityFilter,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                DropdownMenuItem(value: 'urgent', child: Text('🔴 Urgent')),
                DropdownMenuItem(value: 'high', child: Text('🟠 High')),
                DropdownMenuItem(value: 'medium', child: Text('🟡 Medium')),
                DropdownMenuItem(value: 'low', child: Text('🟢 Low')),
              ],
              onChanged: (value) {
                setState(() {
                  _priorityFilter = value!;
                });
              },
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowFavorites(List<Expense> expenses) {
    final favorites = expenses.where((e) => e.isFavorite).toList();
    return favorites.isNotEmpty && !_showFavoritesOnly;
  }

  Widget _buildFavoritesSection(List<Expense> expenses) {
    final favorites = expenses.where((e) => e.isFavorite).take(3).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text(
                'Recent Favorites',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final expense = favorites[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getCategoryIcon(expense.category),
                                size: 16,
                                color: _getCategoryColor(expense.category),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.favorite, color: Colors.red, size: 12),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            expense.category,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses, String emptyMessage, IconData emptyIcon) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
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

    return ExpenseList(expenses: expenses); // Use your existing ExpenseList widget
  }

  List<Expense> _getFilteredExpenses(List<Expense> allExpenses, bool isPaid) {
    List<Expense> filtered = allExpenses.where((expense) => expense.isPaid == isPaid).toList();
    
    if (_showFavoritesOnly) {
      filtered = filtered.where((expense) => expense.isFavorite).toList();
    }
    
    if (_priorityFilter != 'all') {
      filtered = filtered.where((expense) => expense.priority == _priorityFilter).toList();
    }
    
    // Sort by priority (urgent -> high -> medium -> low)
    filtered.sort((a, b) {
      final priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
      final aPriority = priorityOrder[a.priority] ?? 2;
      final bPriority = priorityOrder[b.priority] ?? 2;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      // If same priority, sort by date (newest first)
      return b.date.compareTo(a.date);
    });
    
    return filtered;
  }

  int _getUnpaidCount(List<Expense> expenses) {
    return _getFilteredExpenses(expenses, false).length;
  }

  int _getPaidCount(List<Expense> expenses) {
    return _getFilteredExpenses(expenses, true).length;
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