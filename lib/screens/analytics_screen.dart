import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../providers/expense_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseNotifierProvider);
    final categoryData = ref.watch(expensesByCategoryProvider);
    final monthlyData = ref.watch(monthlyExpensesProvider);
    final averageDaily = ref.watch(averageDailyExpenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: expensesAsync.when(
        data: (expenses) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Expenses',
                      value: '\$${ref.watch(totalExpensesProvider).toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Daily Average',
                      value: '\$${averageDaily.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Pie Chart with Legend
              const Text(
                'Expenses by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 300,
                      child: categoryData.isEmpty
                          ? const Center(child: Text('No data available'))
                          : PieChart(
                              PieChartData(
                                sections: _buildPieChartSections(categoryData),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    // Add touch interaction if needed
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryData.entries.map((entry) {
                        final categoryColor = _getCategoryColor(entry.key);
                        final totalAmount = categoryData.values.fold(0.0, (a, b) => a + b);
                        final percentage = (entry.value / totalAmount * 100);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Monthly Trends - FIXED
              const Text(
                'Monthly Trends (Last 6 Months)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: monthlyData.isEmpty
                    ? const Center(child: Text('No data available'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return _getBottomTitleWidget(value, meta);
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: _getMaxY(monthlyData),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _buildLineChartSpots(monthlyData),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.blue,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Category Breakdown List
              const SizedBox(height: 24),
              const Text(
                'Category Breakdown',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...categoryData.entries.map(
                (entry) => Card(
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(entry.key).withOpacity(0.2),
                      child: Icon(
                        _getCategoryIcon(entry.key),
                        color: _getCategoryColor(entry.key),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // Updated pie chart sections with matching category colors
  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    return data.entries.map((entry) {
      final categoryColor = _getCategoryColor(entry.key); // Use actual category color
      final totalAmount = data.values.fold(0.0, (a, b) => a + b);
      final percentage = (entry.value / totalAmount * 100);
      
      return PieChartSectionData(
        color: categoryColor, // ✅ Now uses the correct category color
        value: entry.value,
        title: percentage > 5 // Only show percentage if slice is big enough
            ? '${percentage.toStringAsFixed(1)}%' 
            : '',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );
    }).toList();
  }

  // FIXED: Better line chart spots generation
  List<FlSpot> _buildLineChartSpots(Map<int, double> monthlyData) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
    // Create spots for the last 6 months
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final month = monthDate.month;
      final amount = monthlyData[month] ?? 0.0;
      spots.add(FlSpot((5 - i).toDouble(), amount));
    }
    
    return spots;
  }

  // Helper method to get bottom title widgets (month names)
  Widget _getBottomTitleWidget(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    );
    
    final now = DateTime.now();
    final monthIndex = value.toInt();
    
    if (monthIndex < 0 || monthIndex > 5) {
      return const Text('');
    }
    
    final monthDate = DateTime(now.year, now.month - (5 - monthIndex), 1);
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        monthNames[monthDate.month - 1],
        style: style,
      ),
    );
  }

  // Helper method to calculate maximum Y value for the chart
  double _getMaxY(Map<int, double> monthlyData) {
    if (monthlyData.isEmpty) return 100;
    
    final maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 100;
    
    // Add 20% padding to the max value
    return maxValue * 1.2;
  }

  // Helper methods for category colors and icons
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}