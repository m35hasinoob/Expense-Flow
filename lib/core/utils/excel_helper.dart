import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_flow/core/constants/expense_category.dart';
import 'package:expense_flow/shared/models/expense_model.dart';
import 'package:expense_flow/shared/models/budget_model.dart';

class TransactionEntry {
  final DateTime date;
  final String time;
  final String type;
  final String category;
  final String description;
  final double cashIn;
  final double expense;

  TransactionEntry({
    required this.date,
    required this.time,
    required this.type,
    required this.category,
    required this.description,
    required this.cashIn,
    required this.expense,
  });
}

class ExcelHelper {
  ExcelHelper._();

  static Future<void> exportExpensesToExcel(
      List<ExpenseModel> expenses, {
        List<BudgetModel> budgets = const [],
      }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Statement'];
    excel.setDefaultSheet('Statement');

    List<TransactionEntry> entries = [];

    
    for (var b in budgets) {
      entries.add(
        TransactionEntry(
          date: b.date,
          time: '00:00 AM',
          type: 'BUDGET',
          category: 'Added Balance',
          description: b.note ?? 'Budget Added',
          cashIn: b.amount,
          expense: 0.0,
        ),
      );
    }

    
    for (var e in expenses) {
      entries.add(
        TransactionEntry(
          date: e.date,
          time: e.time,
          type: 'EXPENSE',
          category: e.category.label,
          description: e.description ?? '',
          cashIn: 0.0,
          expense: e.amount,
        ),
      );
    }

    
    entries.sort((a, b) => a.date.compareTo(b.date));

    
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Description'),
      TextCellValue('Cash In (BDT)'),
      TextCellValue('Expense (BDT)'),
    ]);

    
    for (var entry in entries) {
      sheet.appendRow([
        TextCellValue(entry.date.toIso8601String().split('T')[0]),
        TextCellValue(entry.time),
        TextCellValue(entry.type),
        TextCellValue(entry.category),
        TextCellValue(entry.description),
        DoubleCellValue(entry.cashIn),
        DoubleCellValue(entry.expense),
      ]);
    }

    
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([TextCellValue('--- ACCOUNT SUMMARY ---')]);

    double totalBudget = budgets.fold(0.0, (sum, b) => sum + b.amount);
    double totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
    double remainingBalance = totalBudget - totalExpense;

    sheet.appendRow([TextCellValue('Total Added Budget'), DoubleCellValue(totalBudget)]);
    sheet.appendRow([TextCellValue('Total Expense'), DoubleCellValue(totalExpense)]);
    sheet.appendRow([TextCellValue('Remaining Balance'), DoubleCellValue(remainingBalance)]);

    
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/Expense_Flow_Statement_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([XFile(filePath)], text: 'Expense Flow Statement');
    }
  }

  static Future<List<ExpenseModel>> importExpensesFromExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      return [];
    }

    final bytes = File(result.files.single.path!).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final List<ExpenseModel> importedExpenses = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty || row.length < 6) continue;

        try {
          final dateStr = row[0]?.value?.toString() ?? DateTime.now().toIso8601String();
          final timeStr = row[1]?.value?.toString() ?? '12:00 PM';
          final typeStr = row[2]?.value?.toString() ?? '';
          final categoryStr = row[3]?.value?.toString() ?? 'Others';
          final descriptionStr = row[4]?.value?.toString();
          final amountVal = double.tryParse(row[6]?.value?.toString() ?? '0') ?? 0.0;

          if (typeStr.contains('EXPENSE') && amountVal > 0) {
            importedExpenses.add(
              ExpenseModel(
                amount: amountVal,
                category: ExpenseCategory.fromString(categoryStr),
                description: descriptionStr,
                date: DateTime.parse(dateStr),
                time: timeStr,
              ),
            );
          }
        } catch (_) {}
      }
    }

    return importedExpenses;
  }
}