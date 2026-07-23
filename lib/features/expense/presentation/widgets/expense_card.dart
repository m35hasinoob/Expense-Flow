import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/expense_model.dart';
import '../../providers/expense_provider.dart';

class ExpenseCard extends ConsumerWidget {
  final ExpenseModel expense;

  const ExpenseCard({super.key, required this.expense});

  
  String _parseCategoryString(dynamic category) {
    if (category == null) return 'Other';
    if (category is String) return category;
    try {
      return (category as dynamic).name.toString();
    } catch (_) {
      return category.toString();
    }
  }

  void _showEditBottomSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController(text: expense.amount.toString());
    final descriptionController = TextEditingController(text: expense.description ?? '');

    String selectedCategoryStr = _parseCategoryString(expense.category);

    final categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
                        icon: const Icon(LucideIcons.x, size: 20, color: Colors.black54),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: const Icon(LucideIcons.dollarSign, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  
                  DropdownButtonFormField<String>(
                    initialValue: categories.contains(selectedCategoryStr)
                        ? selectedCategoryStr
                        : categories.last,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(LucideIcons.tag, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategoryStr = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final parsedAmount = double.tryParse(amountController.text.trim());
                        if (parsedAmount == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount')),
                          );
                          return;
                        }

                        dynamic categoryToSave = selectedCategoryStr;

                        final updatedExpense = ExpenseModel(
                          id: expense.id,
                          amount: parsedAmount,
                          category: categoryToSave,
                          description: descriptionController.text.trim().isEmpty
                              ? null
                              : descriptionController.text.trim(),
                          date: expense.date,
                          time: expense.time,
                        );

                        await ref.read(expenseProvider.notifier).updateExpense(updatedExpense);

                        if (modalContext.mounted) {
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Expense updated successfully!')),
                          );
                        }
                      },
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (expense.id != null) {
                await ref.read(expenseProvider.notifier).deleteExpense(expense.id!);
              }
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final categoryName = _parseCategoryString(expense.category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(_getCategoryIcon(categoryName), color: AppColors.primary, size: 20),
        ),
        title: Text(
          expense.description?.isNotEmpty == true ? expense.description! : categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '$categoryName • ${expense.date}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical, size: 18, color: Colors.black54),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditBottomSheet(context, ref);
                } else if (value == 'delete') {
                  _confirmDelete(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return LucideIcons.utensils;
      case 'transport':
        return LucideIcons.bus;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'bills':
        return LucideIcons.receipt;
      case 'entertainment':
        return LucideIcons.film;
      default:
        return LucideIcons.wallet;
    }
  }
}