import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const Trappex());
}

class Trappex extends StatelessWidget {
  const Trappex({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

