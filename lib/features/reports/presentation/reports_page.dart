import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/core/utils/currency_formatter.dart';
import 'package:expense_flow/core/utils/excel_helper.dart'; 
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart'; 
import 'package:expense_flow/features/reports/providers/reports_selectors.dart';
import 'package:expense_flow/features/reports/widgets/category_pie_chart.dart';
import 'package:expense_flow/features/reports/widgets/weekly_bar_chart.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthTotal = ref.watch(currentMonthTotalExpenseProvider);
    final yearTotal = ref.watch(currentYearTotalExpenseProvider);
    final avgDaily = ref.watch(averageDailyExpenseProvider);
    final highestCategory = ref.watch(highestCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          
          IconButton(
            icon: const Icon(LucideIcons.fileSpreadsheet, color: AppColors.primary),
            tooltip: 'Export Statement to Excel',
            onPressed: () async {
              final expensesAsync = ref.read(expenseProvider);
              final budgetsAsync = ref.read(budgetProvider);

              final expenses = expensesAsync.value ?? [];
              final budgets = budgetsAsync.value ?? [];

              if (expenses.isEmpty && budgets.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No data available to export!')),
                );
                return;
              }

              
              await ExcelHelper.exportExpensesToExcel(expenses, budgets: budgets);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.calendarDays, color: AppColors.primary, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          'This Month Spent',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(monthTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.calendar, color: AppColors.dinner, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          'This Year Spent',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(yearTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.trendingUp, color: AppColors.info, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          'Avg Daily Spend',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatCurrency(avgDaily),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.pieChart, color: AppColors.warning, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          'Highest Category',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          highestCategory != null ? highestCategory.label : 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const CategoryPieChart(),
            const SizedBox(height: 16),

            const WeeklyBarChart(),
          ],
        ),
      ),
    );
  }
}