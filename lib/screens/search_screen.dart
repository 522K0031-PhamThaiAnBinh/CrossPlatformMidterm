import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list.dart';
import 'add_expense_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Expense> _filteredExpenses = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  DateTimeRange? _selectedDateRange;
  bool _paidOnly = false;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _filteredExpenses = [];
        _isSearching = false;
      });
    }
  }

  void _performSearch(String query) {
    final expenses = ref.read(expenseNotifierProvider).value ?? [];

    setState(() {
      _isSearching = true;
      _filteredExpenses = expenses.where((expense) {
        // Enhanced search - searches ALL fields!
        final searchLower = query.toLowerCase();

        // Title search
        final titleMatch = expense.title.toLowerCase().contains(searchLower);

        // Description search
        final descriptionMatch =
            expense.description?.toLowerCase().contains(searchLower) ?? false;

        // Notes search
        final notesMatch =
            expense.notes?.toLowerCase().contains(searchLower) ?? false;

        // Category search
        final categoryMatch =
            expense.category.toLowerCase().contains(searchLower);

        // Location search
        final locationMatch =
            expense.location?.toLowerCase().contains(searchLower) ?? false;

        // Tags search - searches through all tags
        final tagsMatch =
            expense.tags.any((tag) => tag.toLowerCase().contains(searchLower));

        // Amount search (exact or partial)
        final amountMatch = expense.amount.toString().contains(searchLower);

        // Priority search
        final priorityMatch =
            expense.priority.toLowerCase().contains(searchLower);

        // Date search (formatted date)
        final dateMatch = DateFormat('MMM dd, yyyy')
                .format(expense.date)
                .toLowerCase()
                .contains(searchLower) ||
            DateFormat('yyyy-MM-dd').format(expense.date).contains(searchLower);

        // Payment status search
        final statusMatch =
            (expense.isPaid ? 'paid' : 'pending unpaid').contains(searchLower);

        // Basic search match
        final basicMatch = titleMatch ||
            descriptionMatch ||
            notesMatch ||
            categoryMatch ||
            locationMatch ||
            tagsMatch ||
            amountMatch ||
            priorityMatch ||
            dateMatch ||
            statusMatch;

        // Apply additional filters
        bool passesFilters = true;

        if (_selectedCategory != 'All' &&
            expense.category != _selectedCategory) {
          passesFilters = false;
        }

        if (_selectedPriority != 'All' &&
            expense.priority != _selectedPriority) {
          passesFilters = false;
        }

        if (_paidOnly && !expense.isPaid) {
          passesFilters = false;
        }

        if (_favoritesOnly && !expense.isFavorite) {
          passesFilters = false;
        }

        if (_selectedDateRange != null) {
          final expenseDate = expense.date;
          if (expenseDate.isBefore(_selectedDateRange!.start) ||
              expenseDate.isAfter(_selectedDateRange!.end)) {
            passesFilters = false;
          }
        }

        return basicMatch && passesFilters;
      }).toList();

      // Sort by relevance (favorites first, then by date)
      _filteredExpenses.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return b.date.compareTo(a.date);
      });
    });
  }

  void _addToHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedPriority = 'All';
      _selectedDateRange = null;
      _paidOnly = false;
      _favoritesOnly = false;
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Expenses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search title, description, notes, tags, amount...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _filteredExpenses = [];
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (query) {
                    _addToHistory(query);
                  },
                ),

                // Quick Filter Chips
                if (_hasActiveFilters()) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedCategory != 'All')
                          _buildFilterChip('Category: $_selectedCategory', () {
                            setState(() => _selectedCategory = 'All');
                            _performSearch(_searchController.text);
                          }),
                        if (_selectedPriority != 'All')
                          _buildFilterChip('Priority: $_selectedPriority', () {
                            setState(() => _selectedPriority = 'All');
                            _performSearch(_searchController.text);
                          }),
                        if (_paidOnly)
                          _buildFilterChip('Paid Only', () {
                            setState(() => _paidOnly = false);
                            _performSearch(_searchController.text);
                          }),
                        if (_favoritesOnly)
                          _buildFilterChip('Favorites Only', () {
                            setState(() => _favoritesOnly = false);
                            _performSearch(_searchController.text);
                          }),
                        if (_selectedDateRange != null)
                          _buildFilterChip('Date Range', () {
                            setState(() => _selectedDateRange = null);
                            _performSearch(_searchController.text);
                          }),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: expenses.when(
              data: (allExpenses) {
                if (!_isSearching && _searchController.text.isEmpty) {
                  return _buildSearchSuggestions(allExpenses);
                }

                if (_isSearching &&
                    _filteredExpenses.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return _buildNoResults();
                }

                if (_filteredExpenses.isNotEmpty) {
                  return Column(
                    children: [
                      // Results header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              '${_filteredExpenses.length} result${_filteredExpenses.length == 1 ? '' : 's'} found',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            if (_searchController.text.isNotEmpty)
                              TextButton.icon(
                                onPressed: () =>
                                    _addToHistory(_searchController.text),
                                icon: const Icon(Icons.bookmark_add, size: 16),
                                label: const Text('Save Search'),
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Results list
                      Expanded(
                        child: ExpenseList(expenses: _filteredExpenses),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        deleteIconColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != 'All' ||
        _selectedPriority != 'All' ||
        _paidOnly ||
        _favoritesOnly ||
        _selectedDateRange != null;
  }

  Widget _buildSearchSuggestions(List<Expense> expenses) {
    final categories = expenses.map((e) => e.category).toSet().toList();
    final tags = expenses.expand((e) => e.tags).toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History
          if (_searchHistory.isNotEmpty) ...[
            const Text('Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _searchHistory
                  .map(
                    (search) => ActionChip(
                      label: Text(search),
                      onPressed: () {
                        _searchController.text = search;
                        _performSearch(search);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Categories
          const Text('Search by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: categories
                .map(
                  (category) => ActionChip(
                    avatar: Icon(_getCategoryIcon(category), size: 16),
                    label: Text(category),
                    onPressed: () {
                      _searchController.text = category;
                      _performSearch(category);
                    },
                  ),
                )
                .toList(),
          ),

          // Popular Tags
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Popular Tags',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: tags
                  .take(10)
                  .map(
                    (tag) => ActionChip(
                      label: Text('#$tag'),
                      onPressed: () {
                        _searchController.text = tag;
                        _performSearch(tag);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],

          // Search Tips
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search Tips',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('• Search by title, description, or notes'),
                  const Text('• Use tags like "work" or "personal"'),
                  const Text('• Search amounts like "50" or "100"'),
                  const Text('• Try "paid", "pending", or "urgent"'),
                  const Text('• Search dates like "Jan 2025" or "yesterday"'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Category filter
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  'All',
                  'Food',
                  'Transport',
                  'Shopping',
                  'Entertainment',
                  'Bills',
                  'Healthcare',
                  'Education'
                ]
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => _selectedCategory = value!),
              ),

              const SizedBox(height: 16),

              // Priority filter
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['All', 'low', 'medium', 'high', 'urgent']
                    .map((priority) => DropdownMenuItem(
                        value: priority, child: Text(priority)))
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => _selectedPriority = value!),
              ),

              const SizedBox(height: 16),

              // Toggle filters
              SwitchListTile(
                title: const Text('Paid Only'),
                value: _paidOnly,
                onChanged: (value) => setModalState(() => _paidOnly = value),
              ),

              SwitchListTile(
                title: const Text('Favorites Only'),
                value: _favoritesOnly,
                onChanged: (value) =>
                    setModalState(() => _favoritesOnly = value),
              ),

              const SizedBox(height: 16),

              // Apply filters button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = _selectedCategory;
                          _selectedPriority = _selectedPriority;
                          _paidOnly = _paidOnly;
                          _favoritesOnly = _favoritesOnly;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
