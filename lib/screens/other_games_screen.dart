import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/other_game.dart';
import '../services/other_games_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/game/exit_button.dart';

class OtherGamesScreen extends StatefulWidget {
  const OtherGamesScreen({super.key});

  static Route<void> createRoute() {
    return MaterialPageRoute(builder: (_) => const OtherGamesScreen());
  }

  @override
  State<OtherGamesScreen> createState() => _OtherGamesScreenState();
}

class _OtherGamesScreenState extends State<OtherGamesScreen> {
  final OtherGamesService _service = const OtherGamesService();
  late Future<List<OtherGame>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _service.fetchOtherGames(excludeTitle: AppConstants.appName);
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
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FutureBuilder<List<OtherGame>>(
                            future: _gamesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.p1Color,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                final error = snapshot.error;
                                if (error is SocketException) {
                                  return _buildOfflineState();
                                }
                                return _buildErrorState(error?.toString() ?? 'Something went wrong.');
                              }

                              final games = snapshot.data ?? [];
                              if (games.isEmpty) {
                                return _buildEmptyState();
                              }

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount = _calculateCrossAxisCount(
                                    constraints.maxWidth,
                                  );
                                  final childAspectRatio =
                                      _calculateChildAspectRatio(
                                        constraints.maxWidth,
                                      );

                                  final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);
                                  final bottomPadding = ResponsiveUtils.getResponsiveSpacing(context, 100, 110, 120);
                                  final spacing = ResponsiveUtils.getResponsiveSpacing(context, 14, 15, 16);
                                  
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: GridView.builder(
                                      padding: EdgeInsets.only(bottom: bottomPadding),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            mainAxisSpacing: spacing,
                                            crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16, 17, 18),
                                            childAspectRatio: childAspectRatio,
                                          ),
                                      itemCount: games.length,
                                      itemBuilder: (context, index) {
                                        final game = games[index];
                                        return _OtherGameCard(
                                          game: game,
                                          onPlay: () => _launchGame(game),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: AdBanner(margin: EdgeInsets.zero),
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

  int _calculateCrossAxisCount(double maxWidth) {
    if (maxWidth >= 1200) {
      return 4;
    }
    if (maxWidth >= 900) {
      return 3;
    }
    return 2;
  }

  double _calculateChildAspectRatio(double maxWidth) {
    if (maxWidth >= 1200) {
      return 0.71;
    }
    if (maxWidth >= 900) {
      return 0.69;
    }
    if (maxWidth >= 600) {
      return 0.67;
    }
    return 0.65;
  }

  Widget _buildHeader(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);
    final bottomSpacing = ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16);
    final placeholderWidth = ResponsiveUtils.getResponsiveValue(context, 40, 42, 44);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, bottomSpacing),
      child: Row(
        children: [
          ExitButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'FGTP Labs',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20, 21, 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.92),
                    letterSpacing: ResponsiveUtils.getResponsiveValue(context, 0.3, 0.35, 0.4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: placeholderWidth),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videogame_asset_off,
              size: ResponsiveUtils.getResponsiveValue(context, 48, 52, 56),
              color: AppColors.mutedColor.withOpacity(0.6),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            Text(
              'No other games available right now.',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6, 7, 8)),
            Text(
              'Check back soon for more fun experiences!',
              style: TextStyle(
                color: AppColors.mutedColor,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12, 13, 14),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.getResponsiveValue(context, 48, 52, 56),
              color: AppColors.p1Color.withOpacity(0.8),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            Text(
              'Unable to load games',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18, 19, 20),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6, 7, 8)),
            Text(
              'Something went wrong. Please try again in a moment.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12, 13, 14),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gamesFuture = _service.fetchOtherGames(
                    excludeTitle: AppConstants.appName,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(context, 20, 22, 24),
                  vertical: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  ),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: ResponsiveUtils.getResponsiveValue(context, 48, 52, 56),
              color: AppColors.mutedColor.withOpacity(0.8),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            Text(
              'No internet connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18, 19, 20),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6, 7, 8)),
            Text(
              'Please reconnect to the internet and refresh to explore our other games.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12, 13, 14),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gamesFuture = _service.fetchOtherGames(
                    excludeTitle: AppConstants.appName,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(context, 20, 22, 24),
                  vertical: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  ),
                ),
              ),
              child: Text(
                'Refresh',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchGame(OtherGame game) async {
    final url = _pickStoreUrl(game);
    if (url == null || url.isEmpty) {
      _showSnackBar('No store link available for this game yet.');
      return;
    }

    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      _showSnackBar('Could not open the store page.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      _showSnackBar('Could not open the store page.');
    }
  }

  String? _pickStoreUrl(OtherGame game) {
    if (kIsWeb) {
      return game.playStoreUrl.isNotEmpty
          ? game.playStoreUrl
          : game.appStoreUrl;
    }

    if (Platform.isAndroid) {
      return game.playStoreUrl.isNotEmpty
          ? game.playStoreUrl
          : game.appStoreUrl;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      return game.appStoreUrl.isNotEmpty ? game.appStoreUrl : game.playStoreUrl;
    }

    return game.playStoreUrl.isNotEmpty ? game.playStoreUrl : game.appStoreUrl;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black.withOpacity(0.85),
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

class _OtherGameCard extends StatelessWidget {
  final OtherGame game;
  final VoidCallback onPlay;

  const _OtherGameCard({required this.game, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.homeCardBg.withOpacity(0.8),
        border: Border.all(
          color: AppColors.homeCardBorder.withOpacity(0.6),
          width: ResponsiveUtils.getResponsiveValue(context, 2.5, 3.0, 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  0,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _SquareArtwork(imageUrl: game.imageUrl),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                ),
                child: Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  0,
                  ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                  0,
                ),
                child: SizedBox(
                  height: ResponsiveUtils.getResponsiveValue(context, 36, 38, 40),
                  child: ElevatedButton(
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButtonColor,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 26, 28, 30),
                        ),
                      ),
                      elevation: ResponsiveUtils.getResponsiveValue(context, 4, 5, 6),
                      shadowColor: AppColors.primaryButtonColor.withOpacity(0.4),
                    ),
                    child: Text(
                      'Play Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareArtwork extends StatelessWidget {
  final String imageUrl;

  const _SquareArtwork({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: trimmedUrl.isEmpty
            ? Container(
                color: Colors.white.withOpacity(0.08),
                child: const Icon(
                  Icons.videogame_asset,
                  color: Colors.white70,
                  size: 40,
                ),
              )
            : Image.network(
                trimmedUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withOpacity(0.08),
                  child: const Icon(
                    Icons.videogame_asset,
                    color: Colors.white70,
                    size: 40,
                  ),
                ),
              ),
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
