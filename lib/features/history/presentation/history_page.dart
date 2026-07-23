import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/core/constants/expense_category.dart';
import 'package:expense_flow/core/utils/currency_formatter.dart';
import 'package:expense_flow/shared/widgets/custom_card.dart';
import 'package:expense_flow/shared/models/expense_model.dart';
import 'package:expense_flow/features/expense/presentation/add_expense_bottom_sheet.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart';
import 'package:expense_flow/features/history/providers/history_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  String _formatHeaderDate(String dateStr) {
    final DateTime date = DateTime.parse(dateStr);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return AppFormatters.formatDate(date);
  }

  
  void _showEditExpenseSheet(BuildContext context, ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExpenseBottomSheet(expenseToEdit: expense),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedExpenses = ref.watch(groupedExpensesProvider);
    final selectedCategory = ref.watch(historyCategoryFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    ref.read(historySearchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by description or amount...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: selectedCategory == null,
                          onSelected: (_) {
                            ref.read(historyCategoryFilterProvider.notifier).state = null;
                          },
                        ),
                      ),
                      ...ExpenseCategory.values.map((category) {
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category.label),
                            avatar: Icon(
                              category.icon,
                              size: 14,
                              color: isSelected ? Colors.white : category.color,
                            ),
                            selected: isSelected,
                            selectedColor: category.color,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (_) {
                              ref.read(historyCategoryFilterProvider.notifier).state = category;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          
          Expanded(
            child: groupedExpenses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.receipt, size: 48, color: theme.disabledColor),
                  const SizedBox(height: 12),
                  Text(
                    'No expenses found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: groupedExpenses.keys.length,
              itemBuilder: (context, index) {
                final dateKey = groupedExpenses.keys.elementAt(index);
                final dayExpenses = groupedExpenses[dateKey]!;
                final dayTotal = dayExpenses.fold(0.0, (sum, item) => sum + item.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatHeaderDate(dateKey),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(dayTotal),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ...dayExpenses.map((item) {
                      return Dismissible(
                        key: Key('expense_${item.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
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
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
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
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}