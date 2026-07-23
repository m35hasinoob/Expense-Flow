import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/core/utils/currency_formatter.dart';
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/features/dashboard/providers/dashboard_selectors.dart';

class BalanceCard extends ConsumerWidget {
  final VoidCallback onAddBudgetPressed;

  const BalanceCard({
    super.key,
    required this.onAddBudgetPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBudget = ref.watch(totalBudgetProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final remainingBalance = ref.watch(remainingBalanceProvider);

    final double progress =
    totalBudget > 0 ? (totalExpense / totalBudget).clamp(0.0, 1.0) : 0.0;

    final theme = Theme.of(context);

    return CustomCard(
      color: AppColors.primary,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              IconButton(
                onPressed: onAddBudgetPressed,
                icon: const Icon(LucideIcons.plusCircle, color: Colors.white),
                tooltip: 'Add Budget / Income',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.formatCurrency(remainingBalance),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: progress > 0.9 ? AppColors.error : Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                label: 'Total Budget',
                amount: AppFormatters.formatCurrency(totalBudget),
                icon: LucideIcons.arrowDownLeft,
                iconColor: Colors.white,
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                label: 'Total Spent',
                amount: AppFormatters.formatCurrency(totalExpense),
                icon: LucideIcons.arrowUpRight,
                iconColor: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}