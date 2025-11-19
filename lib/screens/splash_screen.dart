import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'game_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set system UI overlay style for full screen immediately
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
    
    // Navigate to game screen after shorter delay for faster startup
    // Reduced from 3 seconds to 2 seconds for better UX
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GameScreen()),
          );
        } catch (e) {
          // Handle navigation errors gracefully
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const GameScreen()),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.homeBgDark,
              AppColors.homeBgMedium,
              AppColors.homeBgLight,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles/glow effect
            _buildParticleBackground(context),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Spacer to push content to center
                  const Spacer(),
                  // Game name as logo - perfectly centered
                  Center(
                    child: Text(
                      AppConstants.appName.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 48,
                        color: AppColors.p1Color,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                          // Very subtle glow effect
                          Shadow(
                            color: AppColors.homeAccentGlow.withOpacity(0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Spacer to push developer text to bottom
                  const Spacer(),
                  // Developer text at bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Column(
                      children: [
                        Text(
                          'DEVELOPED BY',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.mutedColor.withOpacity(0.7),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'FGTP LABS',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.mutedColor, // Same as home page subheading
                            fontWeight: FontWeight.w500, // Same as home page subheading
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build animated particle background effect
  Widget _buildParticleBackground(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(),
      ),
    );
  }
}

/// Custom painter for particle background effect
class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    // Draw subtle glowing particles scattered across the background
    final particles = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.25, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.2),
      Offset(size.width * 0.6, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.2),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.55, size.height * 0.65),
      Offset(size.width * 0.7, size.height * 0.75),
      Offset(size.width * 0.85, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.85),
      Offset(size.width * 0.5, size.height * 0.9),
      Offset(size.width * 0.8, size.height * 0.85),
    ];

    for (final particle in particles) {
      // Outer glow
      paint.color = AppColors.homeAccentGlow.withOpacity(0.05);
      canvas.drawCircle(particle, 8, paint);
      
      // Middle glow
      paint.color = AppColors.homeAccentGlow.withOpacity(0.08);
      canvas.drawCircle(particle, 5, paint);
      
      // Inner bright point
      paint.color = AppColors.homeAccentGlow.withOpacity(0.15);
      canvas.drawCircle(particle, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
