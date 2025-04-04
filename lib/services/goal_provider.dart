import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';
import 'local_storage_service.dart';

class GoalProvider with ChangeNotifier {
  Goal? _currentGoal;
  List<Transaction> _transactions = [];

  Goal? get currentGoal => _currentGoal;
  List<Transaction> get transactions => _transactions;

  GoalProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _currentGoal = await LocalStorageService.loadGoal();
    _transactions = await LocalStorageService.loadTransactions();
    notifyListeners();
  }

  Future<void> setGoal(String name, double target, DateTime deadline) async {
    _currentGoal = Goal(
      name: name,
      targetAmount: target,
      savedAmount: 0.0,
      deadline: deadline,
    );
    _transactions = [];
    await _persist();
    notifyListeners();
  }

  Future<void> addToSavings(double amount) async {
    if (_currentGoal == null) return;

    final before = _currentGoal!.savedAmount;
    _currentGoal!.savedAmount += amount;
    final after = _currentGoal!.savedAmount;

    _transactions.add(Transaction(
      amount: amount,
      date: DateTime.now(),
      before: before,
      after: after,
    ));

    await _persist();
    notifyListeners();
  }

  Future<void> deleteTransaction(int index) async {
    if (_currentGoal == null) return;

    final tx = _transactions.removeAt(index);
    _currentGoal!.savedAmount -= tx.amount;

    await _persist();
    notifyListeners();
  }

  Future<void> resetGoal() async {
    if (_currentGoal != null) {
      _currentGoal!.savedAmount = 0.0;
      _transactions = [];
      await _persist();
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    if (_currentGoal != null) {
      await LocalStorageService.saveGoal(_currentGoal!);
      await LocalStorageService.saveTransactions(_transactions);
    }
  }

  Future<void> editTransaction(int index, double newAmount) async {
    if (_currentGoal == null) return;

    final tx = _transactions[index];
    final difference = newAmount - tx.amount;

    _transactions[index] = Transaction(
      amount: newAmount,
      date: tx.date,
      before: tx.before,
      after: tx.before + newAmount,
    );

    _currentGoal!.savedAmount += difference;

    await _persist();
    notifyListeners();
  }

  Future<void> deleteGoal() async {
    _currentGoal = null;
    _transactions = [];
    await LocalStorageService.clearAll();
    notifyListeners();
  }

  void updateGoal(
      String newName, double newTargetAmount, DateTime newDeadline) {
    if (_currentGoal != null) {
      _currentGoal!.name = newName;
      _currentGoal!.targetAmount = newTargetAmount;
      _currentGoal!.deadline = newDeadline;
      notifyListeners();
      _persist();
    }
  }
}
