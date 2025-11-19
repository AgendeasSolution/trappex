import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_edge.dart';
import '../services/game_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/audio_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_utils.dart';
import '../widgets/game/game_board.dart';
import '../widgets/game/exit_button.dart';
import '../widgets/game/turn_indicator.dart';
import '../widgets/common/popup_overlay.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/common/glassmorphic_container.dart';
import 'home_screen.dart';

/// Main game screen widget
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game service instance
  final GameService _gameService = GameService();
  
  // UI State Variables
  bool _isWelcomeVisible = true;
  bool _isGameOverVisible = false;
  String _gameOverTitle = "Game Over!";
  String _gameOverMessage = "The game has ended.";
  int _selectedGridSize = AppConstants.classicGridSize;
  String _gameMode = AppConstants.vsComputerMode;
  String _player1Name = "Player 1";
  String _player2Name = "Player 2";
  GameEdge? _hoveredEdge;
  
  // Track who should go first in the next game (alternates between 1 and 2)
  int _nextGameFirstTurn = 1;
  bool _isFirstGame = true; // Track if this is the first game in 1v1 mode
  
  // Displayed turn for indicator (with delay for computer moves)
  int _displayedTurn = 1;

  @override
  void initState() {
    super.initState();
    try {
      _gameService.initGame(_selectedGridSize, initialTurn: _nextGameFirstTurn);
      _displayedTurn = _gameService.turn;
    } catch (e) {
      // Fallback initialization if error occurs
      _gameService.initGame(AppConstants.classicGridSize, initialTurn: 1);
      _displayedTurn = 1;
    }
    
    // Preload interstitial ad for better user experience (non-blocking)
    try {
      InterstitialAdService.instance.preloadAd();
    } catch (e) {
      // Silently fail - ads are not critical
    }
  }

  /// Starts a new game from the welcome screen settings
  void _startNewGame() async {
    try {
      // Show interstitial ad with 50% probability when opening game screen
      try {
        await _showInterstitialAd();
      } catch (e) {
        // Continue if ad fails
      }
      
      if (!mounted) return;
      
      setState(() {
        _isWelcomeVisible = false;
        _isGameOverVisible = false;
        
        // In 1v1 mode, first game always starts with Player 1
        // In vs Computer mode, use the alternating logic
        int initialTurn = _nextGameFirstTurn;
        if (_gameMode == AppConstants.oneVsOneMode && _isFirstGame) {
          initialTurn = 1; // Always start with Player 1 in first 1v1 game
          _isFirstGame = false; // Mark that we've had the first game
        }
        
        try {
          _gameService.initGame(_selectedGridSize, initialTurn: initialTurn);
          _displayedTurn = _gameService.turn;
        } catch (e) {
          // Fallback initialization
          _gameService.initGame(AppConstants.classicGridSize, initialTurn: 1);
          _displayedTurn = 1;
        }
        
        // Alternate the first turn for the next game (except for first 1v1 game)
        if (!(_gameMode == AppConstants.oneVsOneMode && _isFirstGame)) {
          _nextGameFirstTurn = _nextGameFirstTurn == 1 ? 2 : 1;
        }
      });
      
      // If it's the computer's turn in vs Computer mode, make AI move after 1 second
      if (_gameMode == AppConstants.vsComputerMode && _gameService.turn == 2 && mounted) {
        // Update indicator to show computer's turn
        setState(() {
          _displayedTurn = 2;
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _aiTurn();
          }
        });
      }
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        setState(() {
          _isWelcomeVisible = false;
          _isGameOverVisible = false;
        });
      }
    }
  }

  /// Handles the player's move
  void _handlePlayerMove(GameEdge move) async {
    try {
      // In vs Computer mode, only allow Player 1 to make moves
      if (_gameMode == AppConstants.vsComputerMode && _gameService.turn != 1) return;
      
      // In 1v1 mode, ensure only the current player can make moves
      // The turn system already manages this, but we add explicit validation
      // to prevent any edge cases where the wrong player might try to move
      if (_gameMode == AppConstants.oneVsOneMode) {
        // The turn must be 1 or 2 for a valid move
        // This is already enforced by the game service, but we keep this check
        // for clarity and to ensure the game state is valid
        if (_gameService.turn != 1 && _gameService.turn != 2) return;
      }
      
      // Store the current turn before making the move
      final currentTurn = _gameService.turn;
      
      // Validate the move is allowed before processing
      if (!_gameService.isValidMove(move)) return;
      
      final claimed = _gameService.handlePlayerMove(move);
      
      // Play move sound based on who made the move (before turn changed)
      try {
        if (currentTurn == 1) {
          await AudioService.instance.playPlayer1Move();
        } else {
          await AudioService.instance.playPlayer2Move();
        }
      } catch (e) {
        // Continue if sound fails
      }
      
      // Update displayed turn immediately for player moves
      if (mounted) {
        setState(() {
          _displayedTurn = _gameService.turn;
        });
      }

      if (_gameService.allEdgesFilled()) {
        _endGame();
        return;
      }

      if (claimed == 0) {
        // If vs Computer mode and it's now the computer's turn, make AI move after 1 second
        if (_gameMode == AppConstants.vsComputerMode && _gameService.turn == 2) {
          // Update indicator to show computer's turn
          if (mounted) {
            setState(() {
              _displayedTurn = 2;
            });
          }
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            _aiTurn();
          }
        }
      }
    } catch (e) {
      // Handle any errors gracefully - don't crash the app
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Executes the computer's turn
  void _aiTurn() async {
    if (_gameService.turn != 2 || !mounted) return;

    try {
      bool tookAnotherTurn;
      do {
        if (!mounted) return;
        
        // Make one move
        final move = _gameService.findBestAiMove();
        final claimed = _gameService.handlePlayerMove(move);
        
        if (mounted) {
          setState(() {}); // Redraw board
        }
        
        // Play computer move sound synchronized with wall placement
        try {
          await AudioService.instance.playPlayer2Move();
        } catch (e) {
          // Continue if sound fails
        }

        if (_gameService.allEdgesFilled()) {
          _endGame();
          return;
        }

        // If box was claimed, wait 0.5 seconds before placing next wall in same turn
        tookAnotherTurn = claimed > 0;
        if (tookAnotherTurn) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } while (tookAnotherTurn && _gameService.turn == 2 && mounted);

      // After computer finishes all moves, wait 0.25 seconds before changing indicator to player
      if (_gameService.turn == 1 && mounted) {
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted) {
          setState(() {
            _displayedTurn = 1;
          });
        }
      }

      if (_gameService.allEdgesFilled() && mounted) {
        _endGame();
      }
    } catch (e) {
      // Handle errors gracefully
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Ends the game and shows the game over popup
  void _endGame() async {
    if (!mounted) return;
    
    try {
      final scores = _gameService.scores;
      
      // Ensure scores exist with fallback values
      final score1 = scores[1] ?? 0;
      final score2 = scores[2] ?? 0;
      
      // Play appropriate sound based on game result
      try {
        if (score1 > score2) {
          // Player 1 wins
          await AudioService.instance.playWinSound();
        } else if (score2 > score1) {
          // Player 2/Computer wins
          if (_gameMode == AppConstants.vsComputerMode) {
            await AudioService.instance.playLoseSound();
          } else {
            await AudioService.instance.playWinSound();
          }
        }
      } catch (e) {
        // Continue if sound fails
      }
      
      // Set game over message
      if (score1 > score2) {
        if (_gameMode == AppConstants.vsComputerMode) {
          _gameOverTitle = "Player Wins! 🎉";
          _gameOverMessage = "Congratulations! You won $score1 to $score2.";
        } else {
          _gameOverTitle = "$_player1Name Wins! 🎉";
          _gameOverMessage = "$_player1Name won $score1 to $score2!";
        }
      } else if (score2 > score1) {
        if (_gameMode == AppConstants.vsComputerMode) {
          _gameOverTitle = "Computer Wins! 🤖";
          _gameOverMessage = "The computer won $score2 to $score1.";
        } else {
          _gameOverTitle = "$_player2Name Wins! 🎉";
          _gameOverMessage = "$_player2Name won $score2 to $score1!";
        }
      } else {
        // Tie
        _gameOverTitle = "It's a Tie! 🤝";
        if (_gameMode == AppConstants.vsComputerMode) {
          _gameOverMessage = "You and the computer both scored $score1 points.";
        } else {
          _gameOverMessage = "$_player1Name and $_player2Name both scored $score1 points.";
        }
      }
      
      if (mounted) {
        setState(() {
          _isGameOverVisible = true;
        });
      }
    } catch (e) {
      // Fallback game over message if error occurs
      if (mounted) {
        setState(() {
          _gameOverTitle = "Game Over!";
          _gameOverMessage = "The game has ended.";
          _isGameOverVisible = true;
        });
      }
    }
  }
  
  /// Handle restart button press with interstitial ad
  void _handleRestartButton() async {
    // Play click sound
    await AudioService.instance.playClickSound();
    
    // Show interstitial ad with 100% probability
    await _showInterstitialAdAlways();
    
    // Navigate to home screen after ad (or immediately if ad not shown)
    setState(() {
      _isWelcomeVisible = true;
      _isFirstGame = true; // Reset for new 1v1 games
    });
  }
  
  /// Handle play again button press with interstitial ad
  void _handlePlayAgainButton() async {
    // Play click sound
    await AudioService.instance.playClickSound();
    
    // Show interstitial ad with 100% probability
    await _showInterstitialAdAlways();
    
    // Start new game after ad (or immediately if ad not shown)
    _startNewGame();
  }
  
  /// Handle reset button press - resets current game board with interstitial ad
  void _handleResetButton() async {
    // Play click sound
    await AudioService.instance.playClickSound();
    
    // Show interstitial ad with 50% probability
    await _showInterstitialAd();
    
    // Reset the current game with same settings after ad (or immediately if no ad shown)
    _gameService.initGame(_selectedGridSize, initialTurn: _gameService.turn);
    setState(() {
      _hoveredEdge = null; // Clear any hovered edge
      _displayedTurn = _gameService.turn;
    });
    
    // If it's the computer's turn in vs Computer mode, make AI move after 1 second
    if (_gameMode == AppConstants.vsComputerMode && _gameService.turn == 2) {
      // Update indicator to show computer's turn
      setState(() {
        _displayedTurn = 2;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        _aiTurn();
      });
    }
  }
  
  /// Show interstitial ad with 50% probability
  Future<bool> _showInterstitialAd() async {
    try {
      return await InterstitialAdService.instance.showAdWithProbability(
        onAdDismissed: () {
          // Preload next ad after current one is dismissed
          InterstitialAdService.instance.preloadAd();
        },
      );
    } catch (e) {
      // Preload next ad even if current one failed
      InterstitialAdService.instance.preloadAd();
      return false;
    }
  }
  
  /// Show interstitial ad with 100% probability
  Future<bool> _showInterstitialAdAlways() async {
    try {
      return await InterstitialAdService.instance.showAdAlways(
        onAdDismissed: () {
          // Preload next ad after current one is dismissed
          InterstitialAdService.instance.preloadAd();
        },
      );
    } catch (e) {
      // Preload next ad even if current one failed
      InterstitialAdService.instance.preloadAd();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isWelcomeVisible) {
      return HomeScreen(
        onStartGame: _startNewGame,
        selectedGridSize: _selectedGridSize,
        gameMode: _gameMode,
        player1Name: _player1Name,
        player2Name: _player2Name,
        onGridSizeChanged: (size) => setState(() => _selectedGridSize = size),
        onGameModeChanged: (mode) => setState(() => _gameMode = mode),
        onPlayer1NameChanged: (name) => setState(() => _player1Name = name),
        onPlayer2NameChanged: (name) => setState(() => _player2Name = name),
      );
    }
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              child: Stack(
                children: [
                  _buildGameUI(),
                  if (_isGameOverVisible) _buildGameOverPopup(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameUI() {
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);
    final topPadding = ResponsiveUtils.getResponsiveSpacing(context, 8, 10, 12);
    final boardPadding = ResponsiveUtils.getResponsiveSpacing(context, 6, 7, 8);
    final turnIndicatorGap = ResponsiveUtils.getResponsiveSpacing(context, 20, 24, 28);

    return Stack(
      children: [
        // Header Row with Exit Button and Game Name
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Exit Button
                ExitButton(
                  onPressed: () => _handleRestartButton(),
                ),
                // Game Name
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24, 26, 28),
                          color: AppColors.p1Color,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
                              offset: Offset(0, ResponsiveUtils.getResponsiveValue(context, 3, 3.5, 4)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Reset Button
                GestureDetector(
                  onTap: () => _handleResetButton(),
                  child: GlassmorphicContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                      vertical: ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Game Board with Turn Indicators - Centered on screen
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Player 2/Computer Turn Indicator (Top) - Always rendered, visibility controlled
                Visibility(
                  visible: _displayedTurn == 2,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveUtils.getResponsiveSpacing(context, 24, 28, 32),
                    ),
                    child: TurnIndicator(
                      turn: 2, 
                      gameMode: _gameMode,
                      player1Name: _player1Name,
                      player2Name: _player2Name,
                    ),
                  ),
                ),
                // Game Board
                Padding(
                  padding: EdgeInsets.all(boardPadding),
                  child: GameBoard(
                    n: _gameService.n,
                    horizontalEdges: _gameService.horizontalEdges,
                    verticalEdges: _gameService.verticalEdges,
                    boxes: _gameService.boxes,
                    turn: _gameService.turn,
                    onEdgeHover: (edge) {
                      // In vs Computer mode, only show hover for Player 1
                      // In 1v1 mode, only show hover when it's a valid turn (1 or 2)
                      bool canHover = _gameMode == AppConstants.vsComputerMode 
                          ? _gameService.turn == 1 
                          : (_gameService.turn == 1 || _gameService.turn == 2);
                      
                      if (canHover && _gameService.isValidMove(edge)) {
                        setState(() => _hoveredEdge = edge);
                      } else {
                        setState(() => _hoveredEdge = null);
                      }
                    },
                    onEdgeTap: (edge) {
                      // Only process taps if it's a valid turn
                      // This prevents the opposite player from placing walls during the other player's turn
                      if (_gameMode == AppConstants.vsComputerMode) {
                        // In vs Computer mode, only allow Player 1 to tap
                        if (_gameService.turn == 1) {
                          _handlePlayerMove(edge);
                        }
                      } else if (_gameMode == AppConstants.oneVsOneMode) {
                        // In 1v1 mode, only allow taps when it's a valid player's turn (1 or 2)
                        if (_gameService.turn == 1 || _gameService.turn == 2) {
                          _handlePlayerMove(edge);
                        }
                      }
                    },
                    hoveredEdge: _hoveredEdge,
                  ),
                ),
                // Player 1 Turn Indicator (Bottom) - Always rendered, visibility controlled
                Visibility(
                  visible: _displayedTurn == 1,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: ResponsiveUtils.getResponsiveSpacing(context, 24, 28, 32),
                    ),
                    child: TurnIndicator(
                      turn: 1, 
                      gameMode: _gameMode,
                      player1Name: _player1Name,
                      player2Name: _player2Name,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Ad Banner at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: const AdBanner(),
        ),
      ],
    );
  }

  Widget _buildGameOverPopup() {
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);
    
    return PopupOverlay(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _gameOverTitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24, 26, 28),
                color: AppColors.p1Color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
            Text(
              _gameOverMessage,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                color: AppColors.mutedColor,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20, 22, 24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => _handlePlayAgainButton(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.p1Color,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveValue(context, 20, 22, 24),
                        vertical: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
                        ),
                      ),
                    ),
                    child: Text(
                      "Play Again",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12)),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AudioService.instance.playClickSound();
                      setState(() {
                        _isWelcomeVisible = true;
                        _isFirstGame = true; // Reset for new 1v1 games
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.p2Color,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveValue(context, 20, 22, 24),
                        vertical: ResponsiveUtils.getResponsiveValue(context, 10, 11, 12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
                        ),
                      ),
                    ),
                    child: Text(
                      "Go to Home",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
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
