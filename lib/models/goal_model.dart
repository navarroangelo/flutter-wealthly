class Goal {
  String name;
  double targetAmount;
  double savedAmount;
  DateTime deadline;

  Goal({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
  });

  double get remaining => targetAmount - savedAmount;
  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
  bool get isComplete => savedAmount >= targetAmount;

  Map<String, dynamic> toJson() => {
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': deadline.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        name: json['name'],
        targetAmount: json['targetAmount'],
        savedAmount: json['savedAmount'],
        deadline: DateTime.parse(json['deadline']),
      );
}
