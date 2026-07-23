class BudgetModel {
  final int? id;
  final double amount;
  final String? note;
  final DateTime date;

  const BudgetModel({
    this.id,
    required this.amount,
    this.note,
    required this.date,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
    };
  }
}