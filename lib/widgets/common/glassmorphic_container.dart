import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A reusable glassmorphic container widget
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.2),
                width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
