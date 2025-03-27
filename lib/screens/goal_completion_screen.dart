import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider.dart';
import 'home_screen.dart';

class GoalCompletionScreen extends StatefulWidget {
  const GoalCompletionScreen({super.key});

  @override
  State<GoalCompletionScreen> createState() => _GoalCompletionScreenState();
}

class _GoalCompletionScreenState extends State<GoalCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _coinAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _coinAnimation = Tween<double>(begin: -100, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final goalName = goalProvider.currentGoal?.name ?? "Your Goal";

    return Scaffold(
      backgroundColor: const Color(0xFF006d77),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.savings_rounded,
                    size: 150,
                    color: Colors.white,
                  ),

                  AnimatedBuilder(
                    animation: _coinAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _coinAnimation.value,
                        left: 45,
                        child: child!,
                      );
                    },
                    child: const Icon(
                      Icons.circle,
                      size: 40,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              const Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const Text(
                "You've successfully achieved your savings goal!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
              Text(
                goalName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Provider.of<GoalProvider>(context, listen: false)
                      .deleteGoal();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF006d77),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Complete Goal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
