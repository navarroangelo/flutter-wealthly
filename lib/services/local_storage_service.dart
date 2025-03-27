import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';

class LocalStorageService {
  static const _goalKey = 'current_goal';
  static const _txKey = 'transactions';

  static Future<void> saveGoal(Goal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goalJson = jsonEncode(goal.toJson());
    await prefs.setString('currentGoal', goalJson);
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson =
        jsonEncode(transactions.map((tx) => tx.toJson()).toList());
    await prefs.setString('transactions', transactionsJson);
  }

  static Future<Goal?> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goalJson = prefs.getString('currentGoal');
    if (goalJson == null) return null;
    return Goal.fromJson(jsonDecode(goalJson));
  }

  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((tx) => Transaction.fromJson(tx)).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalKey);
    await prefs.remove(_txKey);
  }
}
