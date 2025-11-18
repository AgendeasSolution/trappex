import 'package:flutter/material.dart';
import '../../models/game_edge.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import 'game_painter.dart';

/// Game board widget that handles user interactions and renders the game
class GameBoard extends StatelessWidget {
  final int n;
  final List<List<int>> horizontalEdges;
  final List<List<int>> verticalEdges;
  final List<List<int>> boxes;
  final int turn;
  final GameEdge? hoveredEdge;
  final ValueChanged<GameEdge> onEdgeTap;
  final ValueChanged<GameEdge> onEdgeHover;

  const GameBoard({
    super.key,
    required this.n,
    required this.horizontalEdges,
    required this.verticalEdges,
    required this.boxes,
    required this.turn,
    required this.hoveredEdge,
    required this.onEdgeTap,
    required this.onEdgeHover,
  });

  /// Converts a local widget offset to the nearest game edge
  GameEdge? _offsetToEdge(
      Offset localPosition, double cellSize, double padding) {
    final x = localPosition.dx - padding;
    final y = localPosition.dy - padding;

    // First, find all possible edges within tolerance
    List<GameEdge> possibleEdges = [];
    
    // Check horizontal edges
    for (int i = 0; i <= n; i++) {
      for (int j = 0; j < n; j++) {
        final edgeY = i * cellSize;
        final edgeX1 = j * cellSize;
        final edgeX2 = (j + 1) * cellSize;
        if (y > edgeY - AppConstants.touchTolerance &&
            y < edgeY + AppConstants.touchTolerance &&
            x > edgeX1 &&
            x < edgeX2) {
          possibleEdges.add(GameEdge(type: 'h', i: i, j: j));
        }
      }
    }

    // Check vertical edges
    for (int i = 0; i < n; i++) {
      for (int j = 0; j <= n; j++) {
        final edgeX = j * cellSize;
        final edgeY1 = i * cellSize;
        final edgeY2 = (i + 1) * cellSize;
        if (x > edgeX - AppConstants.touchTolerance &&
            x < edgeX + AppConstants.touchTolerance &&
            y > edgeY1 &&
            y < edgeY2) {
          possibleEdges.add(GameEdge(type: 'v', i: i, j: j));
        }
      }
    }

    // If no edges found, return null
    if (possibleEdges.isEmpty) return null;

    // If only one edge found, return it
    if (possibleEdges.length == 1) return possibleEdges.first;

    // If multiple edges found, find the closest one
    GameEdge? closestEdge;
    double minDistance = double.infinity;

    for (final edge in possibleEdges) {
      double distance;
      if (edge.type == 'h') {
        final edgeY = edge.i * cellSize;
        distance = (y - edgeY).abs();
      } else {
        final edgeX = edge.j * cellSize;
        distance = (x - edgeX).abs();
      }
      
      if (distance < minDistance) {
        minDistance = distance;
        closestEdge = edge;
      }
    }

    // Additional check: if we're very close to a corner and both edge types are possible,
    // prioritize based on which direction the user is more clearly pointing to
    if (possibleEdges.length > 1 && minDistance < AppConstants.touchTolerance * 0.5) {
      final horizontalEdges = possibleEdges.where((e) => e.type == 'h').toList();
      final verticalEdges = possibleEdges.where((e) => e.type == 'v').toList();
      
      if (horizontalEdges.isNotEmpty && verticalEdges.isNotEmpty) {
        // Calculate the distance to the center of each edge type
        double minHorizontalDistance = double.infinity;
        double minVerticalDistance = double.infinity;
        
        for (final edge in horizontalEdges) {
          final edgeY = edge.i * cellSize;
          final distance = (y - edgeY).abs();
          if (distance < minHorizontalDistance) {
            minHorizontalDistance = distance;
          }
        }
        
        for (final edge in verticalEdges) {
          final edgeX = edge.j * cellSize;
          final distance = (x - edgeX).abs();
          if (distance < minVerticalDistance) {
            minVerticalDistance = distance;
          }
        }
        
        // Choose the edge type that the user is closer to
        if (minVerticalDistance < minHorizontalDistance) {
          closestEdge = verticalEdges.firstWhere((e) => (x - e.j * cellSize).abs() == minVerticalDistance);
        } else {
          closestEdge = horizontalEdges.firstWhere((e) => (y - e.i * cellSize).abs() == minHorizontalDistance);
        }
      }
    }

    return closestEdge;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final cellSize = (size.width - 2 * AppConstants.cellPadding) / n;

          return GestureDetector(
            onTapUp: (details) {
              final edge = _offsetToEdge(
                  details.localPosition, cellSize, AppConstants.cellPadding);
              if (edge != null) onEdgeTap(edge);
            },
            onPanUpdate: (details) {
              final edge = _offsetToEdge(
                  details.localPosition, cellSize, AppConstants.cellPadding);
              if (edge != null) onEdgeHover(edge);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) {
                final edge = _offsetToEdge(
                    event.localPosition, cellSize, AppConstants.cellPadding);
                if (edge != null) onEdgeHover(edge);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.canvasBorderColor, width: 1),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF041738),
                      Color(0xFF052045),
                      Color(0xFF062A5A)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: CustomPaint(
                  size: size,
                  painter: GamePainter(
                    n: n,
                    horizontalEdges: horizontalEdges,
                    verticalEdges: verticalEdges,
                    boxes: boxes,
                    hoveredEdge: hoveredEdge,
                    cellSize: cellSize,
                    padding: AppConstants.cellPadding,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
