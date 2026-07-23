import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_flow/core/constants/expense_category.dart';
import 'package:expense_flow/shared/models/expense_model.dart';
import 'package:expense_flow/features/expense/providers/expense_provider.dart';


final historySearchQueryProvider = StateProvider<String>((ref) => '');


final historyCategoryFilterProvider = StateProvider<ExpenseCategory?>((ref) => null);


final filteredExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  final expenseAsync = ref.watch(expenseProvider);
  final searchQuery = ref.watch(historySearchQueryProvider).toLowerCase().trim();
  final selectedCategory = ref.watch(historyCategoryFilterProvider);

  return expenseAsync.maybeWhen(
    data: (expenses) {
      return expenses.where((expense) {
        
        final matchesQuery = searchQuery.isEmpty ||
            (expense.description?.toLowerCase().contains(searchQuery) ?? false) ||
            expense.amount.toString().contains(searchQuery);

        
        final matchesCategory =
            selectedCategory == null || expense.category == selectedCategory;

        return matchesQuery && matchesCategory;
      }).toList();
    },
    orElse: () => [],
  );
});


final groupedExpensesProvider = Provider<Map<String, List<ExpenseModel>>>((ref) {
  final filteredExpenses = ref.watch(filteredExpensesProvider);
  final Map<String, List<ExpenseModel>> grouped = {};

  for (var expense in filteredExpenses) {
    final dateKey = expense.date.toIso8601String().split('T')[0];
    if (!grouped.containsKey(dateKey)) {
      grouped[dateKey] = [];
    }
    grouped[dateKey]!.add(expense);
  }

  return grouped;
});