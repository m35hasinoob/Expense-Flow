import '../../core/constants/expense_category.dart';

class ExpenseModel {
  final int? id;
  final double amount;
  final ExpenseCategory category;
  final String? description;
  final DateTime date;
  final String time; 

  const ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.time,
  });

  
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(map['category'] as String),
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category': category.name,
      'description': description,
      'date': date.toIso8601String().split('T')[0], 
      'time': time,
    };
  }

  ExpenseModel copyWith({
    int? id,
    double? amount,
    ExpenseCategory? category,
    String? description,
    DateTime? date,
    String? time,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}