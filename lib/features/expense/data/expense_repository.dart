import '../../../core/database/database_helper.dart';
import '../../../shared/models/budget_model.dart';
import '../../../shared/models/expense_model.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  
  Future<List<ExpenseModel>> fetchExpenses() async {
    return await _dbHelper.getAllExpenses();
  }

  Future<int> addExpense(ExpenseModel expense) async {
    return await _dbHelper.insertExpense(expense);
  }

  
  Future<int> updateExpense(ExpenseModel expense) async {
    return await _dbHelper.updateExpense(expense);
  }

  Future<int> deleteExpense(int id) async {
    return await _dbHelper.deleteExpense(id);
  }

  
  Future<List<BudgetModel>> fetchBudgets() async {
    return await _dbHelper.getAllBudgets();
  }

  Future<int> addBudget(BudgetModel budget) async {
    return await _dbHelper.insertBudget(budget);
  }

  Future<void> clearAll() async {
    await _dbHelper.clearAllData();
  }
}