import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_edge.dart';
import '../services/game_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/audio_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
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

  @override
  void initState() {
    super.initState();
    _gameService.initGame(_selectedGridSize, initialTurn: _nextGameFirstTurn);
    
    // Preload interstitial ad for better user experience
    InterstitialAdService.instance.preloadAd();
  }

  /// Starts a new game from the welcome screen settings
  void _startNewGame() async {
    // Show interstitial ad with 50% probability when opening game screen
    await _showInterstitialAd();
    
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
      
      _gameService.initGame(_selectedGridSize, initialTurn: initialTurn);
      
      // Alternate the first turn for the next game (except for first 1v1 game)
      if (!(_gameMode == AppConstants.oneVsOneMode && _isFirstGame)) {
        _nextGameFirstTurn = _nextGameFirstTurn == 1 ? 2 : 1;
      }
    });
    
    // If it's the computer's turn in vs Computer mode, make AI move
    if (_gameMode == AppConstants.vsComputerMode && _gameService.turn == 2) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _aiTurn();
      });
    }
  }

  /// Handles the player's move
  void _handlePlayerMove(GameEdge move) async {
    // In vs Computer mode, only allow Player 1 to make moves
    // In 1v1 mode, allow both players to make moves
    if (_gameMode == AppConstants.vsComputerMode && _gameService.turn != 1) return;
    
    // Store the current turn before making the move
    final currentTurn = _gameService.turn;
    final claimed = _gameService.handlePlayerMove(move);
    
    // Play move sound based on who made the move (before turn changed)
    if (currentTurn == 1) {
      await AudioService.instance.playPlayer1Move();
    } else {
      await AudioService.instance.playPlayer2Move();
    }
    
    setState(() {}); // Redraw the board

    if (_gameService.allEdgesFilled()) {
      _endGame();
      return;
    }

    if (claimed == 0) {
      // If vs Computer mode and it's now the computer's turn, make AI move
      if (_gameMode == AppConstants.vsComputerMode && _gameService.turn == 2) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _aiTurn();
      }
    }
  }

  /// Executes the computer's turn
  void _aiTurn() async {
    if (_gameService.turn != 2) return;

    _gameService.aiTurn();
    
    // Play computer move sound
    await AudioService.instance.playPlayer2Move();
    
    setState(() {}); // Redraw

    if (_gameService.allEdgesFilled()) {
      _endGame();
    }
  }

  /// Ends the game and shows the game over popup
  void _endGame() async {
    final scores = _gameService.scores;
    
    // Play appropriate sound based on game result
    if (scores[1]! > scores[2]!) {
      // Player 1 wins
      await AudioService.instance.playWinSound();
      if (_gameMode == AppConstants.vsComputerMode) {
        _gameOverTitle = "Player Wins! 🎉";
        _gameOverMessage =
            "Congratulations! You won ${scores[1]} to ${scores[2]}.";
      } else {
        _gameOverTitle = "$_player1Name Wins! 🎉";
        _gameOverMessage =
            "$_player1Name won ${scores[1]} to ${scores[2]}!";
      }
    } else if (scores[2]! > scores[1]!) {
      // Player 2/Computer wins
      if (_gameMode == AppConstants.vsComputerMode) {
        // Player loses to computer
        await AudioService.instance.playLoseSound();
        _gameOverTitle = "Computer Wins! 🤖";
        _gameOverMessage = "The computer won ${scores[2]} to ${scores[1]}.";
      } else {
        // Player 2 wins in 1v1
        await AudioService.instance.playWinSound();
        _gameOverTitle = "$_player2Name Wins! 🎉";
        _gameOverMessage =
            "$_player2Name won ${scores[2]} to ${scores[1]}!";
      }
    } else {
      // Tie - no specific sound for tie
      _gameOverTitle = "It's a Tie! 🤝";
      if (_gameMode == AppConstants.vsComputerMode) {
        _gameOverMessage = "You and the computer both scored ${scores[1]} points.";
      } else {
        _gameOverMessage = "$_player1Name and $_player2Name both scored ${scores[1]} points.";
      }
    }
    
    setState(() {
      _isGameOverVisible = true;
    });
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
    });
    
    // If it's the computer's turn in vs Computer mode, make AI move
    if (_gameMode == AppConstants.vsComputerMode && _gameService.turn == 2) {
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/page_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildGameUI(),
              if (_isGameOverVisible) _buildGameOverPopup(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameUI() {
    return LayoutBuilder(builder: (context, constraints) {
      // Make the UI responsive
      bool isMobile = constraints.maxWidth < 768;
      double topPadding = isMobile ? 8 : 20;

      return Stack(
        children: [
          // Header Row with Exit Button and Game Name
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: topPadding),
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
                      child: Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 32,
                          color: AppColors.p1Color,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Reset Button
                  GestureDetector(
                    onTap: () => _handleResetButton(),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Player 2/Computer Turn Indicator (Top)
          if (_gameService.turn == 2)
            Positioned(
              top: topPadding + 100, // More gap from board
              left: 0,
              right: 0,
              child: Center(
                child: TurnIndicator(
                  turn: _gameService.turn, 
                  gameMode: _gameMode,
                  player1Name: _player1Name,
                  player2Name: _player2Name,
                ),
              ),
            ),
          // Player 1 Turn Indicator (Bottom)
          if (_gameService.turn == 1)
            Positioned(
              bottom: topPadding + 100, // More gap from board
              left: 0,
              right: 0,
              child: Center(
                child: TurnIndicator(
                  turn: _gameService.turn, 
                  gameMode: _gameMode,
                  player1Name: _player1Name,
                  player2Name: _player2Name,
                ),
              ),
            ),
          // Game Board
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GameBoard(
                n: _gameService.n,
                horizontalEdges: _gameService.horizontalEdges,
                verticalEdges: _gameService.verticalEdges,
                boxes: _gameService.boxes,
                turn: _gameService.turn,
                onEdgeHover: (edge) {
                  // In vs Computer mode, only show hover for Player 1
                  // In 1v1 mode, show hover for both players
                  bool canHover = _gameMode == AppConstants.vsComputerMode 
                      ? _gameService.turn == 1 
                      : true;
                  
                  if (canHover && _gameService.isValidMove(edge)) {
                    setState(() => _hoveredEdge = edge);
                  } else {
                    setState(() => _hoveredEdge = null);
                  }
                },
                onEdgeTap: (edge) {
                  _handlePlayerMove(edge);
                },
                hoveredEdge: _hoveredEdge,
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
    });
  }

  Widget _buildGameOverPopup() {
    return PopupOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_gameOverTitle,
              style: const TextStyle(
                  fontSize: 28, color: AppColors.p1Color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(_gameOverMessage,
              style:
                  const TextStyle(fontSize: 16, color: AppColors.mutedColor, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _handlePlayAgainButton(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.p1Color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("Play Again",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 12),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("Go to Home",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
