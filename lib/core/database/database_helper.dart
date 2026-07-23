import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../shared/models/budget_model.dart';
import '../../shared/models/expense_model.dart';

class DatabaseHelper {
  static const String _dbName = 'expense_flow.db';
  static const int _dbVersion = 1;

  
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC, id DESC');
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  
  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  

  Future<int> insertBudget(BudgetModel budget) async {
    final db = await instance.database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets', orderBy: 'date DESC');
    return result.map((map) => BudgetModel.fromMap(map)).toList();
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('expenses');
    await db.delete('budgets');
  }
}