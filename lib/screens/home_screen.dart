import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final snapshot = await firestore.FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();

    final loaded = snapshot.docs.map((doc) {
      return Transaction.fromMap(doc.data());
    }).toList();

    setState(() {
      _transactions.clear();
      _transactions.addAll(loaded);
    });
  }

  void _addTransaction(Transaction transaction) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await firestore.FirebaseFirestore.instance
        .collection('transactions')
        .add(transaction.toMap(userId ?? ''));

    setState(() {
      _transactions.add(transaction);
    });
  }

  void _deleteTransaction(String id) async {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });

    final snapshot = await firestore.FirebaseFirestore.instance
        .collection('transactions')
        .where('id', isEqualTo: id)
        .get();

    for (var doc in snapshot.docs) {
      await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .doc(doc.id)
          .delete();
    }
  }

  void _editTransaction(Transaction updatedTx) async {
    final index = _transactions.indexWhere((tx) => tx.id == updatedTx.id);
    if (index != -1) {
      setState(() {
        _transactions[index] = updatedTx;
      });

      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .where('id', isEqualTo: updatedTx.id)
          .get();

      for (var doc in snapshot.docs) {
        await firestore.FirebaseFirestore.instance
            .collection('transactions')
            .doc(doc.id)
            .update(updatedTx.toMap(FirebaseAuth.instance.currentUser?.uid ?? ''));
      }
    }
  }

  void _startAddTransaction([Transaction? transaction]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TransactionForm(
            onSubmit: _addTransaction,
            onEdit: _editTransaction,
            transaction: transaction,
          ),
        );
      },
    );
  }

  double get totalIncome =>
      _transactions.where((tx) => !tx.isExpense).fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense =>
      _transactions.where((tx) => tx.isExpense).fold(0.0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddTransaction(),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text("Income: ₹${totalIncome.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.green, fontSize: 16)),
                  Text("Expense: ₹${totalExpense.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                  Text(
                      "Balance: ₹${(totalIncome - totalExpense).toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? Center(child: Text("No transactions added yet!"))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                tx.isExpense ? Colors.red : Colors.green,
                            child: Icon(
                                tx.isExpense ? Icons.remove : Icons.add,
                                color: Colors.white),
                          ),
                          title: Text(tx.title),
                          subtitle: Text(
                              '${tx.category} - ${DateFormat.yMMMd().format(tx.date)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _startAddTransaction(tx),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTransaction(tx.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddTransaction(),
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
