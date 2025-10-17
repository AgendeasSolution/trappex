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
                  ? AppColors.p1Color
                  : Colors.white.withOpacity(0.5),
              width: 2),
          color: isSelected
              ? AppColors.p1Color
              : Colors.black.withOpacity(0.7),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.p1Color.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 0)
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 0),
                  BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 18,
                      spreadRadius: 1)
                ],
        ),
        child: Column(
          children: [
            Text("$size × $size",
                style: TextStyle(
                    color:
                        isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? Colors.black.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
