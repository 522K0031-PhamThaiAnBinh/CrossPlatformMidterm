import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// Prefix imports to disambiguate similarly named providers
import '../providers/analytics_provider.dart' as ap;
import '../providers/expense_provider.dart' as xp;

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(xp.expenseNotifierProvider);
    final rawCategoryData = ref.watch(xp.expensesByCategoryProvider);

    // Use the analytics providers via the `ap.` prefix
    final monthlyData = ref.watch(ap.monthlyExpensesProvider);
    final averageDaily = ref.watch(ap.averageDailyExpenseProvider);

    // Normalize and clean categories (merge case variants, remove gift/travel into "Other")
    final categoryData = _normalizeCategoryData(rawCategoryData);

    // High-contrast colors from theme
    final cs = Theme.of(context).colorScheme;
    final axisTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: cs.onSurface, // much higher contrast than grey
    );

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
                      value: '\$${ref.watch(xp.totalExpensesProvider).toStringAsFixed(2)}',
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

              // Category Pie Chart
              const Text(
                'Expenses by Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pie
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
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend with "top category" highlight
                  Expanded(
                    flex: 1,
                    child: _LegendWithHighlight(categoryData: categoryData),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Monthly Trends
              const Text(
                'Monthly Trends (Last 6 Months)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Right padding to keep tooltips inside
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  height: 300,
                  child: monthlyData.isEmpty
                      ? const Center(child: Text('No data available'))
                      : LineChart(
                          LineChartData(
                            // Tooltips: keep inside chart area
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.black87,
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipItems: (touchedSpots) => touchedSpots
                                    .map(
                                      (ts) => LineTooltipItem(
                                        '\$${ts.y.toStringAsFixed(2)}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                            // Tiny x padding so last point isn't flush to the border
                            minX: -0.15,
                            maxX: 5.15,

                            // Y config
                            minY: 0,
                            maxY: _getMaxY(monthlyData),

                            // Don’t clip line/dots to the chart rect
                            clipData: const FlClipData(
                              left: false,
                              top: false,
                              right: false,
                              bottom: false,
                            ),

                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) =>
                                  FlLine(color: cs.outlineVariant.withOpacity(0.35), strokeWidth: 1),
                              getDrawingVerticalLine: (value) =>
                                  FlLine(color: cs.outlineVariant.withOpacity(0.25), strokeWidth: 1),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) =>
                                      _bottomMonthTitle(context, value, meta, axisTextStyle),
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 54, // a little more room for bigger text
                                  getTitlesWidget: (value, meta) => Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Text(
                                      '\$${value.toInt()}',
                                      style: axisTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: cs.outlineVariant.withOpacity(0.5), width: 1),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _buildLineChartSpots(monthlyData),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.blue,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  ),
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
                    title: Text(_titleCase(entry.key)),
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

  // Normalize categories: case-insensitive, fold unknowns and gift/travel into "other"
  Map<String, double> _normalizeCategoryData(Map<String, double> data) {
    const allowed = {
      'food',
      'transport',
      'shopping',
      'entertainment',
      'bills',
      'healthcare',
      'education',
      'other',
    };

    const aliasMap = {
      'foods': 'food',
      'meal': 'food',
      'transportation': 'transport',
      'transit': 'transport',
      'health': 'healthcare',
      'medical': 'healthcare',
      'medicine': 'healthcare',
      'others': 'other',
      'misc': 'other',
      'miscellaneous': 'other',
      'gift': 'other',
      'gifts': 'other',
      'travel': 'other',
      'trip': 'other',
      'bill': 'bills',
    };

    final Map<String, double> result = {};
    for (final entry in data.entries) {
      var key = entry.key.trim().toLowerCase();
      key = aliasMap[key] ?? key;
      if (!allowed.contains(key)) {
        key = 'other';
      }
      result.update(key, (v) => v + entry.value, ifAbsent: () => entry.value);
    }

    // Sort by value descending for nicer pie/legend order
    final sorted = result.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    return data.entries.map((entry) {
      final categoryColor = _getCategoryColor(entry.key);
      final percentage = total == 0 ? 0 : (entry.value / total * 100);
      return PieChartSectionData(
        color: categoryColor,
        value: entry.value,
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2)],
        ),
      );
    }).toList();
  }

  List<FlSpot> _buildLineChartSpots(Map<int, double> monthlyData) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final month = monthDate.month;
      final amount = monthlyData[month] ?? 0.0;
      spots.add(FlSpot((5 - i).toDouble(), amount));
    }
    return spots;
  }

  // Bottom month titles with high-contrast style
  Widget _bottomMonthTitle(BuildContext context, double value, TitleMeta meta, TextStyle baseStyle) {
    final now = DateTime.now();
    final monthIndex = value.toInt();
    if (monthIndex < 0 || monthIndex > 5) return const SizedBox.shrink();
    final monthDate = DateTime(now.year, now.month - (5 - monthIndex), 1);
    const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        monthNames[monthDate.month - 1],
        style: baseStyle,
      ),
    );
  }

  double _getMaxY(Map<int, double> monthlyData) {
    if (monthlyData.isEmpty) return 100;
    final maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 100;
    return maxValue * 1.2;
  }

  // Color/icon helpers
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'shopping': return Colors.purple;
      case 'entertainment': return Colors.pink;
      case 'bills': return Colors.red;
      case 'healthcare': return Colors.green;
      case 'education': return Colors.teal;
      case 'other': return Colors.grey;
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

  String _titleCase(String key) {
    final lower = key.toLowerCase();
    if (lower == 'other') return 'Other';
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}

class _LegendWithHighlight extends StatelessWidget {
  final Map<String, double> categoryData;

  const _LegendWithHighlight({required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalAmount = categoryData.values.fold(0.0, (a, b) => a + b);
    final maxVal = categoryData.isEmpty
        ? 0.0
        : categoryData.values.reduce((a, b) => a > b ? a : b);
    final topKeys = categoryData.entries
        .where((e) => e.value == maxVal)
        .map((e) => e.key)
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryData.entries.map((entry) {
        final categoryColor = _getCategoryColor(entry.key);
        final perc = totalAmount == 0 ? 0 : (entry.value / totalAmount * 100);
        final isTop = topKeys.contains(entry.key);

        final labelStyle = TextStyle(
          fontSize: 13,
          fontWeight: isTop ? FontWeight.w900 : FontWeight.w600,
          color: isTop ? cs.primary : cs.onSurface,
        );

        final valueStyle = TextStyle(
          fontSize: 11,
          fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
          color: isTop ? cs.primary : Colors.grey[600],
        );

        final rowChild = Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: categoryColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_titleCase(entry.key), style: labelStyle, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 6),
            Text('${perc.toStringAsFixed(1)}%', style: valueStyle),
            if (isTop) ...[
              const SizedBox(width: 6),
              Icon(Icons.star, size: 14, color: cs.primary),
            ],
          ],
        );

        // Subtle highlight background for the top entry/entries
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: isTop
              ? Container(
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.primary.withOpacity(0.25)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: rowChild,
                )
              : rowChild,
        );
      }).toList(),
    );
  }

  // Local helpers (duplicate small ones to avoid making them public)
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'shopping': return Colors.purple;
      case 'entertainment': return Colors.pink;
      case 'bills': return Colors.red;
      case 'healthcare': return Colors.green;
      case 'education': return Colors.teal;
      case 'other': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _titleCase(String key) {
    final lower = key.toLowerCase();
    if (lower == 'other') return 'Other';
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}