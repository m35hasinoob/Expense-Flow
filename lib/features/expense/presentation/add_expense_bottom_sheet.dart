import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:expense_flow/core/constants/app_colors.dart';
import 'package:expense_flow/core/constants/expense_category.dart';
import 'package:expense_flow/core/utils/currency_formatter.dart';
import 'package:expense_flow/shared/models/expense_model.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart';

class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final ExpenseModel? expenseToEdit; 

  const AddExpenseBottomSheet({
    super.key,
    this.expenseToEdit,
  });

  @override
  ConsumerState<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;

  bool get isEditing => widget.expenseToEdit != null; 

  @override
  void initState() {
    super.initState();
    
    final expense = widget.expenseToEdit;
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(0) : '',
    );
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _selectedCategory = expense?.category ?? ExpenseCategory.lunch;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim();
      final formattedTime = isEditing
          ? widget.expenseToEdit!.time
          : AppFormatters.formatTime(DateTime.now());

      if (isEditing) {
        
        final updatedExpense = widget.expenseToEdit!.copyWith(
          amount: amount,
          category: _selectedCategory,
          description: description.isEmpty ? null : description,
          date: _selectedDate,
          time: formattedTime,
        );
        ref.read(expenseProvider.notifier).updateExpense(updatedExpense);
      } else {
        
        final expense = ExpenseModel(
          amount: amount,
          category: _selectedCategory,
          description: description.isEmpty ? null : description,
          date: _selectedDate,
          time: formattedTime,
        );
        ref.read(expenseProvider.notifier).addExpense(expense);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Expense' : 'Add New Expense',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: !isEditing,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (BDT)',
                  prefixText: '৳ ',
                  prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) {
                    return 'Enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category.label),
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    selected: isSelected,
                    selectedColor: category.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Chicken Biryani, Coffee',
                  prefixIcon: const Icon(LucideIcons.fileText, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            AppFormatters.formatDate(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveExpense,
                  icon: Icon(isEditing ? LucideIcons.checkCheck : LucideIcons.check),
                  label: Text(
                    isEditing ? 'Update Expense' : 'Save Expense',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}