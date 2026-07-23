import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_flow/core/utils/currency_formatter.dart';
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/features/reports/providers/reports_selectors.dart';

class CategoryPieChart extends ConsumerWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTotals = ref.watch(categoryTotalsProvider);
    final totalSpent = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    final theme = Theme.of(context);

    if (totalSpent == 0) {
      return CustomCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No expense data to display chart.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: categoryTotals.entries.map((entry) {
                        final category = entry.key;
                        final amount = entry.value;
                        final percentage =
                        totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;

                        return PieChartSectionData(
                          color: category.color,
                          value: amount > 0 ? amount : 0.001,
                          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                          radius: 40,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryTotals.entries.map((entry) {
                    final category = entry.key;
                    final amount = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: category.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppFormatters.formatCurrency(amount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}