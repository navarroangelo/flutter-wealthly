import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/goal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const WealthlyApp());
}

class WealthlyApp extends StatelessWidget {
  const WealthlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wealthly',
        theme: ThemeData(
          fontFamily: 'Nunito',
          scaffoldBackgroundColor: const Color(0xFFedf6f9),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006d77)),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
