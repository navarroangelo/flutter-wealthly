import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider.dart';
import 'records_screen.dart';
import '../models/goal_model.dart';
import 'package:intl/intl.dart';
import '../widgets/progress_bar_painter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'goal_completion_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final goal = goalProvider.currentGoal;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: AppBar(
          backgroundColor: const Color(0xFF006d77),
          centerTitle: true,
          title: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logotest.webp',
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'WEALTHLY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: goal == null ? const NoGoalView() : const ActiveGoalView(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: goal == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF006d77),
                child: const Icon(Icons.add),
                onPressed: () => _openSetGoalDialog(context),
              ),
            )
          : null,
      bottomNavigationBar: goal != null ? CountdownNavBar(goal: goal) : null,
    );
  }

  void _openSetGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Set New Goal',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Goal Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Goal Amount'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Target Date:"),
                      TextButton(
                        onPressed: () async {
                          final nowPH = DateTime.now()
                              .toUtc()
                              .add(const Duration(hours: 8));
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: nowPH,
                            firstDate: nowPH,
                            lastDate: DateTime(2126),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text(
                          selectedDate != null
                              ? DateFormat('MM/dd/yyyy').format(selectedDate!)
                              : "Choose Date",
                          style: TextStyle(
                            color: selectedDate != null
                                ? Colors.black
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final target =
                            double.tryParse(amountController.text.trim());

                        if (name.isEmpty ||
                            amountController.text.trim().isEmpty ||
                            selectedDate == null) {
                          Fluttertoast.showToast(
                              msg: "Please Complete All Fields");
                          return;
                        }

                        if (target == null) {
                          Fluttertoast.showToast(msg: "Invalid Input");
                          return;
                        }

                        if (target <= 0) {
                          Fluttertoast.showToast(
                              msg: "Amount Must Be Greater Than 0");
                          return;
                        }

                        if (target > 100000000.000) {
                          Fluttertoast.showToast(msg: "Amount Exceeds Maximum");
                          return;
                        }

                        Provider.of<GoalProvider>(context, listen: false)
                            .setGoal(
                          name,
                          target,
                          selectedDate!,
                        );
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class NoGoalView extends StatelessWidget {
  const NoGoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE0F7FA),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: 0.0,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF006d77),
                        ),
                        backgroundColor: const Color(0xFFB2DFDB),
                      ),
                    ),
                    const Icon(
                      Icons.savings_rounded,
                      size: 80,
                      color: Color(0xFF006d77),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Goals Set',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006d77),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Start your savings journey today!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActiveGoalView extends StatefulWidget {
  const ActiveGoalView({super.key});

  @override
  State<ActiveGoalView> createState() => _ActiveGoalViewState();
}

class _ActiveGoalViewState extends State<ActiveGoalView> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final goal = goalProvider.currentGoal!;
    if (goal.isComplete && !_dialogShown) {
      _dialogShown = true;
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const GoalCompletionScreen(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final goal = goalProvider.currentGoal!;
    final percent = (goal.progress * 100).floor();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 114, 190, 183),
                      Color(0xFF006d77)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: 0.3,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Color(0xFF006d77),
                    ),
                    onPressed: () => _openEditGoalDialog(context, goal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -10,
                  child: SizedBox(
                    width: 185,
                    height: 90,
                    child: CustomPaint(
                      painter: ProgressBarPainter(progress: goal.progress),
                    ),
                  ),
                ),
                Container(
                  width: 162,
                  height: 162,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF006d77),
                      width: 1.5,
                    ),
                  ),
                ),
                const Positioned(
                  top: 20,
                  child: Icon(
                    Icons.savings_rounded,
                    size: 125,
                    color: Color(0xFF006d77),
                  ),
                ),
                Positioned(
                  bottom: -12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006d77),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn("SAVED", goal.savedAmount),
                _buildAmountColumn("REMAINING", goal.remaining),
                _buildAmountColumn("TARGET", goal.targetAmount),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _openAddSavingsDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006d77),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("ADD SAVINGS"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const RecordsScreen(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("SEE RECORDS"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String label, double amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('\₱${amount.toStringAsFixed(2)}'),
      ],
    );
  }

  void _openEditGoalDialog(BuildContext context, Goal goal) {
    final nameController = TextEditingController(text: goal.name);
    final amountController =
        TextEditingController(text: goal.targetAmount.toStringAsFixed(2));
    DateTime? selectedDate = goal.deadline;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              "Edit Goal",
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
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Goal Name"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Goal Amount"),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Target Date:"),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2126),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        selectedDate != null
                            ? DateFormat('MM/dd/yyyy').format(selectedDate!)
                            : "Choose Date",
                        style: TextStyle(
                          color:
                              selectedDate != null ? Colors.black : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                      final newName = nameController.text.trim();
                      final newAmount =
                          double.tryParse(amountController.text.trim());

                      if (newName.isEmpty ||
                          newAmount == null ||
                          selectedDate == null) {
                        Fluttertoast.showToast(
                            msg: "Please complete all fields!");
                        return;
                      }

                      if (newAmount > 100000000.000) {
                        Fluttertoast.showToast(msg: "Amount Exceeds Maximum");
                        return;
                      }

                      Provider.of<GoalProvider>(context, listen: false)
                          .updateGoal(newName, newAmount, selectedDate!);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddSavingsDialog(BuildContext context) {
    final controller = TextEditingController();
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final goal = goalProvider.currentGoal;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Add To Savings",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount"),
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
                  final amount = double.tryParse(controller.text);
                  if (amount == null) {
                    Fluttertoast.showToast(msg: "Invalid Input");
                    return;
                  }

                  if (amount <= 0) {
                    Fluttertoast.showToast(
                        msg: "Amount Must Be Greater Than 0");
                    return;
                  }

                  goalProvider.addToSavings(amount);

                  if (goal != null && goal.savedAmount >= goal.targetAmount) {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const GoalCompletionScreen(),
                      ),
                    );
                  } else {
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalCompleteDialog extends StatelessWidget {
  const GoalCompleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF006d77), Color(0xFF83c5be)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          "Goal Achieved",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.celebration_rounded,
            size: 80,
            color: Color(0xFF006d77),
          ),
          const SizedBox(height: 20),
          const Text(
            "Congratulations! You've reached your savings goal.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<GoalProvider>(context, listen: false).resetGoal();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF006d77),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text("End Goal"),
        ),
      ],
    );
  }
}

class CountdownNavBar extends StatelessWidget {
  final Goal goal;
  const CountdownNavBar({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final end = goal.deadline;
    final diff = end.difference(now);

    final months = (diff.inDays / 30).floor();
    final days = diff.inDays % 30;
    final hours = diff.inHours % 24;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: const Color(0xFF006d77),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TARGET ON ${DateFormat('MM/dd/yyyy').format(goal.deadline)}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '$months Months, $days Days, and $hours Hours To Target',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
