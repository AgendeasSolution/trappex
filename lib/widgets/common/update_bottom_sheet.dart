import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../../services/audio_service.dart';

/// Bottom sheet widget to show update available popup
class UpdateBottomSheet extends StatelessWidget {
  final String storeUrl;

  const UpdateBottomSheet({
    super.key,
    required this.storeUrl,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvasBgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: AppColors.p1Color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Trappex logo with subtle glow effect
            Container(
              width: ResponsiveUtils.getResponsiveValue(context, 120, 140, 160),
              height: ResponsiveUtils.getResponsiveValue(context, 120, 140, 160),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.p1Color.withOpacity(0.25),
                    blurRadius: ResponsiveUtils.getResponsiveValue(context, 12, 15, 18),
                    spreadRadius: ResponsiveUtils.getResponsiveValue(context, 2, 3, 4),
                  ),
                  BoxShadow(
                    color: AppColors.p1Color.withOpacity(0.15),
                    blurRadius: ResponsiveUtils.getResponsiveValue(context, 18, 20, 22),
                    spreadRadius: ResponsiveUtils.getResponsiveValue(context, 3, 4, 5),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/img/trappex.png',
                fit: BoxFit.contain,
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16, 18, 20)),
            
            // Title
            Text(
              'Update Available',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 22, 24, 26),
                color: AppColors.p1Color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            
            // Message
            Text(
              'A new version of Trappex is available. Update now to enjoy the latest features and improvements!',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                color: AppColors.mutedColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24, 26, 28)),
            
            // Buttons
            Row(
              children: [
                // Update button (first)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AudioService.instance.playClickSound();
                      final uri = Uri.parse(storeUrl);
                      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                      
                      if (launched && context.mounted) {
                        Navigator.of(context).pop();
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Could not open store'),
                            backgroundColor: Colors.black.withOpacity(0.85),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.p1Color,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getResponsiveValue(context, 12, 13, 14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                        ),
                      ),
                    ),
                    child: Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
                
                // Later button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await AudioService.instance.playClickSound();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getResponsiveValue(context, 12, 13, 14),
                      ),
                      side: BorderSide(
                        color: AppColors.mutedColor.withOpacity(0.6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                        ),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                        color: AppColors.mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16, 18, 20)),
          ],
        ),
      ),
    );
  }

  /// Show the update bottom sheet
  static Future<void> show(BuildContext context, String storeUrl) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => UpdateBottomSheet(storeUrl: storeUrl),
    );
  }
}

