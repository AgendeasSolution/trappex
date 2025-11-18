import 'package:flutter/material.dart';
import '../common/glassmorphic_container.dart';
import '../../services/audio_service.dart';
import '../../utils/responsive_utils.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
          vertical: ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
        ),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
        ),
      ),
    );
  }
}
