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
      body: transactions.isEmpty
          ? const Center(child: Text("No transactions yet."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ListTile(
                  title: Text('\$${tx.amount.toStringAsFixed(2)}'),
                  subtitle:
                      Text(DateFormat('yyyy-MM-dd – hh:mm a').format(tx.date)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _openDetailDialog(context, index, tx),
                );
              },
            ),
    );
  }

  void _openDetailDialog(BuildContext context, int index, Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Transaction Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Date:", DateFormat('yyyy-MM-dd').format(tx.date)),
            _detailRow("Time:", DateFormat('hh:mm a').format(tx.date)),
            _detailRow("Amount:", '\$${tx.amount.toStringAsFixed(2)}'),
            _detailRow("Before:", '\$${tx.before.toStringAsFixed(2)}'),
            _detailRow("After:", '\$${tx.after.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GoalProvider>(context, listen: false)
                  .deleteTransaction(index);
              Navigator.of(ctx).pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
