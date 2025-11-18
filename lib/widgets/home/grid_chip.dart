import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/audio_service.dart';

/// Grid size selection chip widget
class GridChip extends StatelessWidget {
  final int size;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GridChip({
    super.key,
    required this.size,
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: isSelected
                  ? AppColors.homeAccentGlow
                  : AppColors.homeCardBorder.withOpacity(0.6),
              width: isSelected ? 2.0 : 1.5),
          color: AppColors.homeCardBg.withOpacity(0.8),
          boxShadow: isSelected
              ? [
                  // Outer glow - multiple layers for depth
                  BoxShadow(
                    color: AppColors.homeAccentGlow.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.homeAccentGlow.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppColors.homeAccentGlow.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 0),
                ],
        ),
        child: Stack(
          children: [
            // Inner glow effect for selected cards
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.homeAccentGlow.withOpacity(0.15),
                        AppColors.homeAccentGlow.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("$size × $size",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
