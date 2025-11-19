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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected
                  ? AppColors.homeAccent
                  : AppColors.homeCardBorder.withOpacity(0.6),
              width: isSelected ? 4.0 : 3.0),
          color: AppColors.homeCardBg.withOpacity(0.8),
          boxShadow: isSelected
              ? [
                  // Outer glow - reduced intensity
                  BoxShadow(
                    color: AppColors.homeAccent.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppColors.homeAccent.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 3,
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
                    borderRadius: BorderRadius.circular(18),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.homeAccent.withOpacity(0.05),
                        AppColors.homeAccent.withOpacity(0.02),
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
                          color: AppColors.homeAccent,
                          fontWeight: FontWeight.bold)),
                  Text(label.toUpperCase(),
                      style: TextStyle(
                          color: AppColors.homeAccent.withOpacity(0.9),
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
