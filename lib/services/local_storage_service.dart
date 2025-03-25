import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';

class LocalStorageService {
  static const _goalKey = 'current_goal';
  static const _txKey = 'transactions';

  static Future<void> saveGoal(Goal goal) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_goalKey, jsonEncode(goal.toJson()));
  }

  static Future<void> saveTransactions(List<Transaction> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = txs.map((e) => e.toJson()).toList();
    prefs.setString(_txKey, jsonEncode(jsonList));
  }

  static Future<Goal?> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_goalKey);
    if (data == null) return null;
    return Goal.fromJson(jsonDecode(data));
  }

  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_txKey);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((e) => Transaction.fromJson(e)).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalKey);
    await prefs.remove(_txKey);
  }
}
