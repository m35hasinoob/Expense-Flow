import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_flow/shared/models/budget_model.dart';
import 'package:expense_flow/shared/models/expense_model.dart';
import 'package:expense_flow/features/expense/data/expense_repository.dart';


final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});


class ExpenseNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;

  ExpenseNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _repository.fetchExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repository.addExpense(expense);
      await loadExpenses(); 
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final expenseProvider =
StateNotifierProvider<ExpenseNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  return ExpenseNotifier(ref.watch(expenseRepositoryProvider));
});


class BudgetNotifier extends StateNotifier<AsyncValue<List<BudgetModel>>> {
  final ExpenseRepository _repository;

  BudgetNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = const AsyncValue.loading();
    try {
      final budgets = await _repository.fetchBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      await _repository.addBudget(budget);
      await loadBudgets();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final budgetProvider =
StateNotifierProvider<BudgetNotifier, AsyncValue<List<BudgetModel>>>((ref) {
  return BudgetNotifier(ref.watch(expenseRepositoryProvider));
});