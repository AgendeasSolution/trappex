import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/other_game.dart';
import '../services/other_games_service.dart';
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/page_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
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

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 120),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 18,
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
      return 0.7;
    }
    if (maxWidth >= 900) {
      return 0.68;
    }
    if (maxWidth >= 600) {
      return 0.66;
    }
    return 0.64;
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Row(
        children: [
          ExitButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'FGTP Labs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.92),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videogame_asset_off,
            size: 56,
            color: AppColors.mutedColor.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No other games available right now.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for more fun experiences!',
            style: TextStyle(color: AppColors.mutedColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.p1Color.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load games',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Something went wrong. Please try again in a moment.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gamesFuture = _service.fetchOtherGames(
                    excludeTitle: AppConstants.appName,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.p1Color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 56,
              color: AppColors.mutedColor.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No internet connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please reconnect to the internet and refresh to explore our other games.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gamesFuture = _service.fetchOtherGames(
                    excludeTitle: AppConstants.appName,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.p1Color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
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
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.55),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _SquareArtwork(imageUrl: game.imageUrl),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onPlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.p1Color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.p1Color.withOpacity(0.4),
                    ),
                    child: const Text(
                      'Play Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
