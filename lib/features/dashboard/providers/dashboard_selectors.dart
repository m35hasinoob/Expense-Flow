import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/expense_category.dart';
import '../../../shared/models/expense_model.dart';
import '../../expense/providers/expense_provider.dart';


final totalBudgetProvider = Provider<double>((ref) {
  final budgetAsync = ref.watch(budgetProvider);
  return budgetAsync.maybeWhen(
    data: (budgets) => budgets.fold(0.0, (sum, item) => sum + item.amount),
    orElse: () => 0.0,
  );
});


final totalExpenseProvider = Provider<double>((ref) {
  final expenseAsync = ref.watch(expenseProvider);
  return expenseAsync.maybeWhen(
    data: (expenses) => expenses.fold(0.0, (sum, item) => sum + item.amount),
    orElse: () => 0.0,
  );
});


final remainingBalanceProvider = Provider<double>((ref) {
  final totalBudget = ref.watch(totalBudgetProvider);
  final totalExpense = ref.watch(totalExpenseProvider);
  return totalBudget - totalExpense;
});


final todayExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  final expenseAsync = ref.watch(expenseProvider);
  final now = DateTime.now();

  return expenseAsync.maybeWhen(
    data: (expenses) {
      return expenses.where((e) {
        return e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day;
      }).toList();
    },
    orElse: () => [],
  );
});


final todayTotalExpenseProvider = Provider<double>((ref) {
  final todayExpenses = ref.watch(todayExpensesProvider);
  return todayExpenses.fold(0.0, (sum, item) => sum + item.amount);
});


final todayCategoryBreakdownProvider =
Provider.family<double, ExpenseCategory>((ref, category) {
  final todayExpenses = ref.watch(todayExpensesProvider);
  return todayExpenses
      .where((e) => e.category == category)
      .fold(0.0, (sum, item) => sum + item.amount);
});