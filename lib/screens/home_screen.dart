import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider.dart';
import 'records_screen.dart';
import '../models/goal_model.dart';
import 'package:intl/intl.dart';
import '../widgets/progress_bar_painter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final goal = goalProvider.currentGoal;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF006d77),
          centerTitle: true,
          title: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 24), // Adjust this for vertical balance
              child: const Text(
                'WEALTHLY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),

      body: goal == null ? const NoGoalView() : const ActiveGoalView(),

      // ✅ Show FAB only when no goal is set
      floatingActionButton: goal == null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF006d77),
              child: const Icon(Icons.add),
              onPressed: () => _openSetGoalDialog(context),
            )
          : null,

      // ✅ Show Countdown NavBar when a goal exists
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
                'SET NEW GOAL',
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
                            lastDate: DateTime(nowPH.year + 5),
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
                        target == null ||
                        selectedDate == null) {
                      Fluttertoast.showToast(msg: "Please Complete All Fields");
                      return;
                    }

                    Provider.of<GoalProvider>(context, listen: false).setGoal(
                      name,
                      target,
                      selectedDate!,
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Confirm'),
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
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.savings_outlined,
                  size: 60, color: Color(0xFF006d77)),
              const SizedBox(height: 20),
              const Text(
                'NO GOALS SET',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(height: 2, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              const Text(
                'GET STARTED',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const GoalCompleteDialog(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final goal = goalProvider.currentGoal!;
    final percent = (goal.progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Group 1: Progress Bar + Icon
            Stack(
              alignment: Alignment.center,
              clipBehavior:
                  Clip.none, // Ensures content outside the Stack is not clipped
              children: [
                // Progress Bar (Adjusted positioning to prevent clipping)
                Positioned(
                  top: -10, // Added spacing above the outer circle
                  child: SizedBox(
                    width: 180,
                    height: 90, // Half-circle
                    child: CustomPaint(
                      painter: ProgressBarPainter(progress: goal.progress),
                    ),
                  ),
                ),

                // Outer Containing Circle (Reduced by 10%)
                Container(
                  width: 162, // 10% reduction
                  height: 162,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF006d77),
                      width: 1.5, // Thin border
                    ),
                  ),
                ),

                // Piggy Icon (Inside the circle, properly centered)
                const Positioned(
                  top: 20, // Adjusted for new size
                  child: Icon(
                    Icons.savings_rounded,
                    size: 125, // Slightly smaller for spacing
                    color: Color(0xFF006d77),
                  ),
                ),

                // Percentage Label (More spacing from Piggy)
                Positioned(
                  bottom: -12, // Moved lower for more space
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF006d77),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(goal.progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48), // ⬆️ Between Group 1 and Group 2

            // Group 2: Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn("SAVED", goal.savedAmount),
                _buildAmountColumn("REMAINING", goal.remaining),
                _buildAmountColumn("TARGET", goal.targetAmount),
              ],
            ),

            const SizedBox(height: 48), // ⬆️ Between Group 2 and Group 3

            // Group 3: Buttons
            ElevatedButton(
              onPressed: () => _openAddSavingsDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006d77),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("ADD SAVING"),
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
              child: const Text("SEE RECORD"),
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

  void _openAddSavingsDialog(BuildContext context) {
    final controller = TextEditingController();
    final goal = Provider.of<GoalProvider>(context, listen: false).currentGoal;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add to Savings"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) {
                Fluttertoast.showToast(msg: "Amount Must Be Greater Than 0");
                return;
              }
              if (goal != null &&
                  (goal.savedAmount + amount) > goal.targetAmount) {
                Fluttertoast.showToast(
                    msg: "This Will Exceed Your Goal Amount!");
                return;
              }
              Provider.of<GoalProvider>(context, listen: false)
                  .addToSavings(amount);
              Navigator.of(ctx).pop();
            },
            child: const Text("Confirm"),
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
      title: const Text("🎉 Goal Achieved!"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Congratulations! You've reached your savings goal."),
          SizedBox(height: 20),
          Text("🎊🎊🎊", style: TextStyle(fontSize: 30)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<GoalProvider>(context, listen: false).resetGoal();
            Navigator.of(context).pop();
          },
          child: const Text("Reset"),
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

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 20), // ← Increased vertical
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
            '$months Months & $days Days To Target',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
