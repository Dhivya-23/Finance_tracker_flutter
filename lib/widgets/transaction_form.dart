import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Function(Transaction) onSubmit;
  final Function(Transaction)? onEdit;
  final Transaction? transaction;

  TransactionForm({
    required this.onSubmit,
    this.onEdit,
    this.transaction,
  });

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['General', 'Food', 'Transport', 'Shopping', 'Salary', 'Health'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _isExpense = widget.transaction!.isExpense;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  void _submitData() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    final transaction = Transaction(
      id: widget.transaction?.id ?? Uuid().v4(),
      title: title,
      amount: amount,
      isExpense: _isExpense,
      category: _selectedCategory,
      date: _selectedDate,
    );

    if (widget.transaction == null) {
      widget.onSubmit(transaction);
    } else {
      widget.onEdit!(transaction);
    }

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked == null) return;
      setState(() => _selectedDate = picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              child: Text(cat),
                              value: cat,
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val!;
                      });
                    },
                  ),
                ),
                Switch(
                  value: _isExpense,
                  onChanged: (val) {
                    setState(() {
                      _isExpense = val;
                    });
                  },
                ),
                Text(_isExpense ? 'Expense' : 'Income'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat.yMd().format(_selectedDate)}',
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text('Choose Date'),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitData,
              child: Text(widget.transaction == null ? 'Add Transaction' : 'Update Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
