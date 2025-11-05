import 'dart:math';
import '../models/game_edge.dart';

/// Service class to handle game logic
class GameService {
  int _n = 5;
  late List<List<int>> _horizontalEdges;
  late List<List<int>> _verticalEdges;
  late List<List<int>> _boxes;
  int _turn = 1;
  Map<int, int> _scores = {1: 0, 2: 0};

  // Getters
  int get n => _n;
  List<List<int>> get horizontalEdges => _horizontalEdges;
  List<List<int>> get verticalEdges => _verticalEdges;
  List<List<int>> get boxes => _boxes;
  int get turn => _turn;
  Map<int, int> get scores => _scores;

  /// Initializes or resets the game state for a given grid size
  void initGame(int n, {int? initialTurn}) {
    _n = n;
    _boxes = List.generate(n, (_) => List.filled(n, 0));
    _horizontalEdges = List.generate(n + 1, (_) => List.filled(n, 0));
    _verticalEdges = List.generate(n, (_) => List.filled(n + 1, 0));
    _scores = {1: 0, 2: 0};
    _turn = initialTurn ?? 1;
  }

  /// Checks if all edges on the board have been filled
  bool allEdgesFilled() {
    for (var row in _horizontalEdges) {
      for (var edge in row) {
        if (edge == 0) return false;
      }
    }
    for (var row in _verticalEdges) {
      for (var edge in row) {
        if (edge == 0) return false;
      }
    }
    // When all edges are filled, do a final check to claim any missed boxes
    checkAllBoxes();
    return true;
  }

  /// Applies a move to the board and checks for completed boxes
  int applyMove(GameEdge move, int player) {
    // Validate and apply the move - ensure wall is assigned to correct player
    if (move.type == 'h') {
      if (_horizontalEdges[move.i][move.j] != 0) {
        return 0; // Prevent overwriting
      }
      _horizontalEdges[move.i][move.j] = player; // Assign to current player
    } else {
      if (_verticalEdges[move.i][move.j] != 0) {
        return 0; // Prevent overwriting
      }
      _verticalEdges[move.i][move.j] = player; // Assign to current player
    }

    // After placing a wall, check all boxes to see if any are now complete
    // This ensures we catch all completed boxes, not just adjacent ones
    return _checkAndClaimBoxes(player);
  }

  /// Checks all boxes on the board and claims any that are complete
  /// Returns the number of boxes claimed by the given player
  int _checkAndClaimBoxes(int player) {
    int claimed = 0;
    
    // Check all boxes to ensure we don't miss any completed boxes
    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        // Only check unclaimed boxes
        if (_boxes[r][c] == 0) {
          // Check if all 4 walls are placed
          bool topWall = _horizontalEdges[r][c] != 0;
          bool bottomWall = _horizontalEdges[r + 1][c] != 0;
          bool leftWall = _verticalEdges[r][c] != 0;
          bool rightWall = _verticalEdges[r][c + 1] != 0;
          
          if (topWall && bottomWall && leftWall && rightWall) {
            // Box is complete - assign to the current player (who placed the completing wall)
            _boxes[r][c] = player;
            claimed++;
          }
        }
      }
    }

    if (claimed > 0) {
      _scores[player] = (_scores[player] ?? 0) + claimed;
    }
    return claimed;
  }

  /// Comprehensive check for any missed boxes - should be called periodically
  /// Returns the number of boxes that were claimed
  int checkAllBoxes() {
    int totalClaimed = 0;
    
    // Check all boxes and determine ownership based on who owns the last wall placed
    // For already completed boxes with all walls, assign to the player who owns most walls
    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        if (_boxes[r][c] == 0) {
          bool topWall = _horizontalEdges[r][c] != 0;
          bool bottomWall = _horizontalEdges[r + 1][c] != 0;
          bool leftWall = _verticalEdges[r][c] != 0;
          bool rightWall = _verticalEdges[r][c + 1] != 0;
          
          if (topWall && bottomWall && leftWall && rightWall) {
            // Box is complete but unclaimed - determine ownership
            // Count walls owned by each player
            int player1Walls = 0;
            int player2Walls = 0;
            
            if (_horizontalEdges[r][c] == 1) player1Walls++;
            else if (_horizontalEdges[r][c] == 2) player2Walls++;
            
            if (_horizontalEdges[r + 1][c] == 1) player1Walls++;
            else if (_horizontalEdges[r + 1][c] == 2) player2Walls++;
            
            if (_verticalEdges[r][c] == 1) player1Walls++;
            else if (_verticalEdges[r][c] == 2) player2Walls++;
            
            if (_verticalEdges[r][c + 1] == 1) player1Walls++;
            else if (_verticalEdges[r][c + 1] == 2) player2Walls++;
            
            // Assign to player with most walls (or player 1 if tie)
            // In normal gameplay, the last wall placed completes the box, so we use majority
            int owner = player1Walls >= player2Walls ? 1 : 2;
            _boxes[r][c] = owner;
            _scores[owner] = (_scores[owner] ?? 0) + 1;
            totalClaimed++;
          }
        }
      }
    }
    
    return totalClaimed;
  }

  /// Handles the player's move
  int handlePlayerMove(GameEdge move) {
    if (!isValidMove(move)) return 0;

    // Store the current turn to ensure wall is assigned to correct player
    final currentPlayer = _turn;
    final claimed = applyMove(move, currentPlayer);
    
    // After move, do a comprehensive check to catch any missed boxes
    checkAllBoxes();
    
    if (claimed == 0) {
      _turn = _turn == 1 ? 2 : 1;
    }
    
    return claimed;
  }

  /// Executes the computer's turn
  List<int> aiTurn() {
    List<int> results = [];
    bool tookAnotherTurn;
    
    do {
      final move = findBestAiMove();
      final claimed = applyMove(move, 2); // Ensure AI (player 2) is assigned correctly
      results.add(claimed);

      // Check for any missed boxes after AI move
      checkAllBoxes();

      if (allEdgesFilled()) {
        // Final check to ensure all boxes are claimed before ending
        checkAllBoxes();
        return results;
      }

      tookAnotherTurn = claimed > 0;
    } while (tookAnotherTurn);

    _turn = 1;
    return results;
  }

  /// The AI logic to determine the best move
  GameEdge findBestAiMove() {
    final moves = getAvailableMoves();

    // 1. Find any move that completes a box
    for (final move in moves) {
      if (simulatedBoxCount(move) > 0) {
        return move;
      }
    }

    // 2. Find "safe" moves that don't give the opponent a point
    final safeMoves = moves.where((m) => !createsSetupForOpponent(m)).toList();
    if (safeMoves.isNotEmpty) {
      return safeMoves[Random().nextInt(safeMoves.length)];
    }

    // 3. If no safe moves, pick a random move
    return moves[Random().nextInt(moves.length)];
  }

  List<GameEdge> getAvailableMoves() {
    final moves = <GameEdge>[];
    for (int i = 0; i <= _n; i++) {
      for (int j = 0; j < _n; j++) {
        if (_horizontalEdges[i][j] == 0)
          moves.add(GameEdge(type: 'h', i: i, j: j));
      }
    }
    for (int i = 0; i < _n; i++) {
      for (int j = 0; j <= _n; j++) {
        if (_verticalEdges[i][j] == 0)
          moves.add(GameEdge(type: 'v', i: i, j: j));
      }
    }
    return moves;
  }

  bool isValidMove(GameEdge move) {
    if (move.type == 'h') {
      return _horizontalEdges[move.i][move.j] == 0;
    } else {
      return _verticalEdges[move.i][move.j] == 0;
    }
  }

  int simulatedBoxCount(GameEdge move) {
    int count = 0;
    // Temporarily apply move to check outcomes
    if (move.type == 'h')
      _horizontalEdges[move.i][move.j] = 2;
    else
      _verticalEdges[move.i][move.j] = 2;

    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        if (_boxes[r][c] == 0 &&
            _horizontalEdges[r][c] != 0 &&
            _horizontalEdges[r + 1][c] != 0 &&
            _verticalEdges[r][c] != 0 &&
            _verticalEdges[r][c + 1] != 0) {
          count++;
        }
      }
    }
    // Revert the temporary move
    if (move.type == 'h')
      _horizontalEdges[move.i][move.j] = 0;
    else
      _verticalEdges[move.i][move.j] = 0;
    return count;
  }

  bool createsSetupForOpponent(GameEdge move) {
    // A move creates a setup if it results in any box having 3 walls
    bool setupCreated = false;
    // Temporarily apply move
    if (move.type == 'h')
      _horizontalEdges[move.i][move.j] = 2;
    else
      _verticalEdges[move.i][move.j] = 2;

    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        int wallCount = 0;
        if (_horizontalEdges[r][c] != 0) wallCount++;
        if (_horizontalEdges[r + 1][c] != 0) wallCount++;
        if (_verticalEdges[r][c] != 0) wallCount++;
        if (_verticalEdges[r][c + 1] != 0) wallCount++;
        if (wallCount == 3) {
          setupCreated = true;
          break;
        }
      }
      if (setupCreated) break;
    }

    // Revert the temporary move
    if (move.type == 'h')
      _horizontalEdges[move.i][move.j] = 0;
    else
      _verticalEdges[move.i][move.j] = 0;
    return setupCreated;
  }
}
