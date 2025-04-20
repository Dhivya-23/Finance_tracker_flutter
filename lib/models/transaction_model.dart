import 'package:flutter/foundation.dart';
import 'transaction.dart'; // Make sure this import points to your actual transaction file

class TransactionModel extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(String id, Transaction updatedTransaction) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  double get totalIncome => _transactions
      .where((tx) => !tx.isExpense) // isExpense == false → income
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.isExpense) // isExpense == true → expense
      .fold(0.0, (sum, tx) => sum + tx.amount);
}
