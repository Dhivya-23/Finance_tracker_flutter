class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'category': category,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      isExpense: map['isExpense'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}
