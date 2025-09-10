import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: isSelected
                  ? AppColors.p1Color
                  : Colors.white.withOpacity(0.1),
              width: 2),
          color: isSelected
              ? AppColors.p1Color
              : Colors.white.withOpacity(0.05),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.p1Color.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: -4)
                ]
              : [],
        ),
        child: Column(
          children: [
            Text("$size × $size",
                style: TextStyle(
                    color:
                        isSelected ? Colors.black : AppColors.mutedColor,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? Colors.black.withOpacity(0.8)
                        : AppColors.mutedColor.withOpacity(0.8),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
