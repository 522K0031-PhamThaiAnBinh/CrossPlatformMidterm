import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense; // For editing existing expenses

  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = 'Food';
  String _selectedPriority = 'medium';
  DateTime _selectedDate = DateTime.now();
  bool _isPaid = false;
  bool _isFavorite = false;
  List<String> _tags = [];

  bool _saving = false;

  // Priority options
  final List<Map<String, dynamic>> _priorities = const [
    {'value': 'low', 'label': 'Low', 'color': Colors.green},
    {'value': 'medium', 'label': 'Medium', 'color': Colors.orange},
    {'value': 'high', 'label': 'High', 'color': Colors.red},
    {'value': 'urgent', 'label': 'Urgent', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _initializeForEditing();
    }
  }

  void _initializeForEditing() {
    final expense = widget.expense!;
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _descriptionController.text = expense.description ?? '';
    _notesController.text = expense.notes ?? '';
    _locationController.text = expense.location ?? '';
    _selectedCategory = expense.category;
    _selectedPriority = expense.priority;
    _selectedDate = expense.date;
    _isPaid = expense.isPaid;
    _isFavorite = expense.isFavorite;
    _tags = List.from(expense.tags);
    _tagsController.text = _tags.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              tooltip: 'Toggle Favorite',
            ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an amount';
                            }
                            final parsed = double.tryParse(value);
                            if (parsed == null) {
                              return 'Please enter a valid number';
                            }
                            if (parsed <= 0) {
                              return 'Amount must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            'Food',
                            'Transport',
                            'Shopping',
                            'Entertainment',
                            'Bills',
                            'Healthcare',
                            'Education',
                            'Other',
                          ].map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value!),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Priority and Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority & Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Priority Selection
                        const Text('Priority Level'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _priorities.map((priority) {
                            final isSelected = _selectedPriority == priority['value'];
                            return ChoiceChip(
                              label: Text(priority['label'] as String),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedPriority = priority['value'] as String);
                                }
                              },
                              selectedColor: (priority['color'] as Color).withOpacity(0.3),
                              avatar: isSelected
                                  ? Icon(Icons.check, size: 16, color: priority['color'] as Color)
                                  : null,
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Status Switches
                        SwitchListTile(
                          title: const Text('Mark as Paid'),
                          subtitle: const Text('Toggle payment status'),
                          value: _isPaid,
                          onChanged: (value) => setState(() => _isPaid = value),
                          secondary: Icon(
                            _isPaid ? Icons.check_circle : Icons.payment,
                            color: _isPaid ? Colors.green : Colors.orange,
                          ),
                        ),

                        SwitchListTile(
                          title: const Text('Add to Favorites'),
                          subtitle: const Text('Quick access to this expense'),
                          value: _isFavorite,
                          onChanged: (value) => setState(() => _isFavorite = value),
                          secondary: Icon(
                            Icons.favorite,
                            color: _isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Additional Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Date Picker
                        ListTile(
                          title: const Text('Date'),
                          subtitle: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          leading: const Icon(Icons.calendar_today),
                          onTap: _pickDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma separated)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag),
                            hintText: 'groceries, weekly, important',
                          ),
                          onChanged: (value) {
                            _tags = value
                                .split(',')
                                .map((tag) => tag.trim())
                                .where((tag) => tag.isNotEmpty)
                                .toList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _saving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Update Expense' : 'Add Expense',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final expense = Expense(
        id: widget.expense?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        tags: _tags,
        isPaid: _isPaid,
        priority: _selectedPriority,
        isFavorite: _isFavorite,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.expense != null) {
        // Update existing expense
        await ref.read(expenseNotifierProvider.notifier).updateExpense(expense.id, expense);
        if (mounted) Navigator.of(context).pop(); // no tab change on edit
      } else {
        // Add new expense
        await ref.read(expenseNotifierProvider.notifier).addExpense(expense);

        // Return to previous screen and tell HomeScreen which tab to open
        // true => Paid tab, false => Unpaid tab
        if (mounted) Navigator.of(context).pop<bool>(expense.isPaid);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save expense: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}