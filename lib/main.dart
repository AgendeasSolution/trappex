import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'screens/splash_screen.dart';
import 'constants/app_constants.dart';
import 'services/audio_service.dart';
import 'services/firebase_analytics_service.dart';
import 'services/onesignal_service.dart';

/// Initialize ads with timeout and error handling
Future<void> _initializeAds() async {
  try {
    await MobileAds.instance.initialize().timeout(
      const Duration(seconds: 5),
    );
  } catch (e) {
    // Silently handle ad initialization errors - app should still work
  }
}

/// Initialize audio service with timeout and error handling
Future<void> _initializeAudio() async {
  try {
    await AudioService.instance.initialize().timeout(
      const Duration(seconds: 3),
    );
  } catch (e) {
    // Silently handle audio initialization errors
  }
}

/// Initialize Firebase with timeout and error handling
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 10),
    );
    // Log app open event after successful initialization
    await FirebaseAnalyticsService.instance.logAppOpen();
  } catch (e) {
    // Log error but don't crash the app
    debugPrint('Firebase initialization error: $e');
  }
}

/// Initialize OneSignal with timeout and error handling
Future<void> _initializeOneSignal() async {
  try {
    await OneSignalService.instance.initialize(
      appId: '9833657f-496b-4ffb-aafc-8cde39d3b82d',
    ).timeout(
      const Duration(seconds: 10),
    );
  } catch (e) {
    // Log error but don't crash the app
    debugPrint('OneSignal initialization error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services with error handling to prevent crashes
  // Run initialization in parallel for faster startup
  try {
    await Future.wait([
      // Initialize Firebase first (required for other Firebase services)
      _initializeFirebase(),
      
      // Initialize Google Mobile Ads SDK with timeout and error handling
      _initializeAds(),
      
      // Initialize Audio Service with timeout
      _initializeAudio(),
      
      // Initialize OneSignal push notifications
      _initializeOneSignal(),
    ], eagerError: false); // Don't fail if one service fails
  } catch (e) {
    // Continue even if initialization fails - app should still be usable
    debugPrint('Service initialization error: $e');
  }
  
  // Set preferred orientations to portrait only
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    // Continue if orientation setting fails
  }
  
  // Run app with error boundary
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
      // Add error handling
      builder: (context, child) {
        // Wrap with error boundary
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

