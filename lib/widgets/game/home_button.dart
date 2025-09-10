import 'package:flutter/material.dart';
import '../common/glassmorphic_container.dart';

/// Home button widget for navigation
class HomeButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const HomeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Home",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
