
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? Center(child: Text('No transactions added yet!'))
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, idx) {
              final tx = transactions[idx];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.isExpense ? Colors.red : Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FittedBox(
                          child: Text('₹${tx.amount.toStringAsFixed(0)}')),
                    ),
                  ),
                  title: Text(tx.title),
                  subtitle: Text(
                      '${tx.category} • ${DateFormat.yMMMd().format(tx.date)}'),
                ),
              );
            },
          );
  }
}
