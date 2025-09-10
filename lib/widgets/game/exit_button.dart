import 'package:flutter/material.dart';
import '../common/glassmorphic_container.dart';

/// Exit button widget for navigation
class ExitButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ExitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
