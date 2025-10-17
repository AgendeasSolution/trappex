import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';

/// Game mode selection chip widget
class GameModeChip extends StatelessWidget {
  final String mode;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const GameModeChip({
    super.key,
    required this.mode,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await AudioService.instance.playClickSound();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: isSelected
                  ? AppColors.p1Color
                  : Colors.white.withOpacity(0.4),
              width: 2),
          color: isSelected
              ? AppColors.p1Color
              : Colors.black.withOpacity(0.6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.p1Color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 0)
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0),
                  BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 1)
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 24),
            const SizedBox(height: 8),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
