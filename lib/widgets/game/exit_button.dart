import 'package:flutter/material.dart';
import '../common/glassmorphic_container.dart';
import '../../services/audio_service.dart';

/// Exit button widget for navigation
class ExitButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ExitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await AudioService.instance.playClickSound();
        onPressed();
      },
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
      ),
    );
  }
}
