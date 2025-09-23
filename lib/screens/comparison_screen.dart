import 'package:flutter/material.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Comparison'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ComparisonTable(),
            const SizedBox(height: 24),
            _UseCaseComparison(),
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'State Management Solutions Comparison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                _buildTableRow(['Feature', 'Riverpod', 'BLoC', 'Provider', 'setState'], isHeader: true),
                _buildTableRow(['Learning Curve', 'Medium', 'Hard', 'Easy', 'Easy']),
                _buildTableRow(['Boilerplate', 'Low', 'High', 'Medium', 'None']),
                _buildTableRow(['Performance', 'Excellent', 'Good', 'Good', 'Poor']),
                _buildTableRow(['Testing', 'Excellent', 'Excellent', 'Good', 'Hard']),
                _buildTableRow(['Code Generation', 'Yes', 'No', 'No', 'No']),
                _buildTableRow(['Async Support', 'Built-in', 'Built-in', 'Manual', 'Manual']),
                _buildTableRow(['DevTools', 'Good', 'Excellent', 'Basic', 'None']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(color: Colors.grey.shade200) : null,
      children: cells.map((cell) => 
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            cell,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 12 : 11,
            ),
          ),
        ),
      ).toList(),
    );
  }
}

class _UseCaseComparison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Riverpod for This Expense Tracker?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _UseCaseItem(
              icon: Icons.speed,
              title: 'Reactive Analytics',
              description: 'Automatic recalculation of totals, averages, and charts when expenses change',
              riverpodAdvantage: 'Built-in computed providers handle this automatically',
            ),
            _UseCaseItem(
              icon: Icons.filter_list,
              title: 'Complex Filtering',
              description: 'Filter by priority, payment status, favorites, categories',
              riverpodAdvantage: 'Family providers make parameterized filtering simple',
            ),
            _UseCaseItem(
              icon: Icons.storage,
              title: 'Persistent Storage',
              description: 'Save/load expenses with loading states',
              riverpodAdvantage: 'AsyncNotifier handles async operations elegantly',
            ),
            _UseCaseItem(
              icon: Icons.timeline,
              title: 'State Dependencies',
              description: 'Analytics depend on expenses, filters depend on search terms',
              riverpodAdvantage: 'Automatic dependency tracking prevents inconsistencies',
            ),
          ],
        ),
      ),
    );
  }
}

class _UseCaseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String riverpodAdvantage;

  const _UseCaseItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.riverpodAdvantage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '✅ $riverpodAdvantage',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}