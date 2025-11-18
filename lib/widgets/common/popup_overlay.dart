import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A reusable popup overlay widget
class PopupOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismiss;
  final bool showBackdrop;
  final EdgeInsets? padding;

  const PopupOverlay({
    super.key,
    required this.child,
    this.onDismiss,
    this.showBackdrop = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showBackdrop)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 20),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.homeAccent,
                width: 2,
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.homeCardBg,
                  AppColors.homeBgMedium,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.homeAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
