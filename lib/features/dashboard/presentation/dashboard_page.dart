import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/core/constants/expense_category.dart';
import 'package:expense_flow/core/utils/currency_formatter.dart';
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/shared/models/expense_model.dart';
import 'package:expense_flow/features/budget/presentation/add_budget_bottom_sheet.dart';
import 'package:expense_flow/features/expense/presentation/add_expense_bottom_sheet.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart';
import 'package:expense_flow/features/dashboard/providers/dashboard_selectors.dart';
import 'package:expense_flow/features/dashboard/widgets/balance_card.dart';
import 'package:expense_flow/features/dashboard/widgets/daily_breakdown_section.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddBudgetBottomSheet(),
    );
  }

  
  void _showEditExpenseSheet(BuildContext context, ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseBottomSheet(expenseToEdit: expense),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayExpenses = ref.watch(todayExpensesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            Text(
              AppFormatters.formatDate(DateTime.now()),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expenseProvider.notifier).loadExpenses();
          await ref.read(budgetProvider.notifier).loadBudgets();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(
                onAddBudgetPressed: () => _showAddBudgetSheet(context),
              ),
              const SizedBox(height: 24),
              const DailyBreakdownSection(),
              const SizedBox(height: 24),

              Text(
                "Today's Transactions",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (todayExpenses.isEmpty)
                CustomCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No expenses recorded today.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayExpenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = todayExpenses[index];

                    
                    return Dismissible(
                      key: Key('dash_expense_${item.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.trash2, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        if (item.id != null) {
                          ref.read(expenseProvider.notifier).deleteExpense(item.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Expense deleted')),
                          );
                        }
                      },
                      child: CustomCard(
                        onTap: () => _showEditExpenseSheet(context, item), 
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: item.category.color.withValues(alpha: 0.15),
                              child: Icon(item.category.icon, color: item.category.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.category.label,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (item.description != null && item.description!.isNotEmpty)
                                    Text(
                                      item.description!,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '-${AppFormatters.formatCurrency(item.amount)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                Text(
                                  item.time,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            
                            IconButton(
                              icon: const Icon(LucideIcons.pencil, size: 18, color: AppColors.primary),
                              onPressed: () => _showEditExpenseSheet(context, item),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}