import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A reusable popup overlay widget
class PopupOverlay extends StatelessWidget {
  final Widget child;
  
  const PopupOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: -10)
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
