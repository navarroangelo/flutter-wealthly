import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<GoalProvider>(context).transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Savings Records"),
        backgroundColor: const Color(0xFF006d77),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No Transactions Yet"))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return ListTile(
                        title: Text('₱${tx.amount.toStringAsFixed(2)}'),
                        subtitle: Text(
                            DateFormat('yyyy-MM-dd – hh:mm a').format(tx.date)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _openDetailDialog(context, index, tx),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(
                      context,
                      title: "Reset Goal",
                      message:
                          "Are you sure you want to reset your goal? This will clear all progress and records but retain the goal.",
                      confirmAction: () {
                        Provider.of<GoalProvider>(context, listen: false)
                            .resetGoal();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Goal Has Been Reset!")),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF83c5be),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Reset Goal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(
                      context,
                      title: "Delete Goal",
                      message:
                          "Are you sure you want to delete your goal? This action cannot be undone.",
                      confirmAction: () {
                        Provider.of<GoalProvider>(context, listen: false)
                            .deleteGoal();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Goal Has Been Deleted!")),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006d77),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Delete Goal"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEditDialog(BuildContext context, int index, Transaction tx) {
    final TextEditingController amountController =
        TextEditingController(text: tx.amount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Edit Transaction",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "New Amount",
            prefixText: "₱",
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final newAmount = double.tryParse(amountController.text);
                  if (newAmount != null && newAmount > 0) {
                    Provider.of<GoalProvider>(context, listen: false)
                        .editTransaction(index, newAmount);
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid Amount Entered")),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback confirmAction,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  confirmAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Confirm"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDetailDialog(BuildContext context, int index, Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Transaction Details",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Date:", DateFormat('yyyy-MM-dd').format(tx.date)),
            _detailRow("Time:", DateFormat('hh:mm a').format(tx.date)),
            _detailRow("Amount:", '₱${tx.amount.toStringAsFixed(2)}'),
            _detailRow("Before:", '₱${tx.before.toStringAsFixed(2)}'),
            _detailRow("After:", '₱${tx.after.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Close"),
              ),
              TextButton(
                onPressed: () {
                  _openEditDialog(context, index, tx);
                },
                child: const Text("Edit"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showDeleteConfirmationDialog(context, index);
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Confirm Deletion",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this transaction? This action cannot be undone.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<GoalProvider>(context, listen: false)
                      .deleteTransaction(index);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction Deleted!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }
}
