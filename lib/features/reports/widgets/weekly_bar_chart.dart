import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/features/reports/providers/reports_selectors.dart';

class WeeklyBarChart extends ConsumerWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last7Days = ref.watch(last7DaysSpendingProvider);
    final theme = Theme.of(context);

    double maxAmount = 100.0;
    for (var day in last7Days) {
      if (day.amount > maxAmount) {
        maxAmount = day.amount;
      }
    }

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 Days Spending',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.2,
                barTouchData: BarTouchDataNotifier().touchData,
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < last7Days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              last7Days[index].dayName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: last7Days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: day.amount,
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarTouchDataNotifier {
  BarTouchData get touchData => BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        return BarTooltipItem(
          '${rod.toY.toStringAsFixed(0)} BDT',
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );
}