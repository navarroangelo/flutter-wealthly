class Transaction {
  double amount;
  DateTime date;
  double before;
  double after;

  Transaction({
    required this.amount,
    required this.date,
    required this.before,
    required this.after,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
        'before': before,
        'after': after,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        before: json['before'],
        after: json['after'],
      );
}
