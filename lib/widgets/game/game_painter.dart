import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/game_edge.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

/// Custom painter for rendering the game board
class GamePainter extends CustomPainter {
  final int n;
  final List<List<int>> horizontalEdges;
  final List<List<int>> verticalEdges;
  final List<List<int>> boxes;
  final GameEdge? hoveredEdge;
  final double cellSize;
  final double padding;

  GamePainter({
    required this.n,
    required this.horizontalEdges,
    required this.verticalEdges,
    required this.boxes,
    required this.hoveredEdge,
    required this.cellSize,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(padding, padding);

    _drawCompletedBoxes(canvas);
    _drawEdgesWithGlow(canvas);
    _drawGridDots(canvas);
  }

  void _drawCompletedBoxes(Canvas canvas) {
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (boxes[r][c] != 0) {
          final rect =
              Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
          final isPlayer = boxes[r][c] == 1;

          // Draw only the symbol inside the box (no background color)
          final textSpan = TextSpan(
            text: isPlayer ? '★' : '◆', // Star for Player, Diamond for Computer
            style: TextStyle(
              color: isPlayer ? AppColors.p1WallColor : AppColors.p2WallColor,
              fontSize: cellSize * 0.5,
              fontWeight: FontWeight.bold,
            ),
          );
          final textPainter = TextPainter(
              text: textSpan,
              textAlign: TextAlign.center,
              textDirection: ui.TextDirection.ltr);
          textPainter.layout();
          textPainter.paint(
              canvas,
              Offset(rect.center.dx - textPainter.width / 2,
                  rect.center.dy - textPainter.height / 2));
        }
      }
    }
  }

  void _drawEdgesWithGlow(Canvas canvas) {
    // First draw the subtle glow effect for placed walls
    _drawEdgesGlow(canvas);
    // Then draw the solid walls on top
    _drawEdges(canvas);
  }

  void _drawEdgesGlow(Canvas canvas) {
    final p1GlowPaint = Paint()
      ..color = AppColors.p1WallColor.withOpacity(0.2)
      ..strokeWidth = AppConstants.edgeThickness + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final p2GlowPaint = Paint()
      ..color = AppColors.p2WallColor.withOpacity(0.2)
      ..strokeWidth = AppConstants.edgeThickness + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Draw horizontal edges glow
    for (int i = 0; i <= n; i++) {
      for (int j = 0; j < n; j++) {
        if (horizontalEdges[i][j] == 1 || horizontalEdges[i][j] == 2) {
          final p1 = Offset(j * cellSize, i * cellSize);
          final p2 = Offset((j + 1) * cellSize, i * cellSize);
          Paint glowPaint = horizontalEdges[i][j] == 1 ? p1GlowPaint : p2GlowPaint;
          canvas.drawLine(p1, p2, glowPaint);
        }
      }
    }

    // Draw vertical edges glow
    for (int i = 0; i < n; i++) {
      for (int j = 0; j <= n; j++) {
        if (verticalEdges[i][j] == 1 || verticalEdges[i][j] == 2) {
          final p1 = Offset(j * cellSize, i * cellSize);
          final p2 = Offset(j * cellSize, (i + 1) * cellSize);
          Paint glowPaint = verticalEdges[i][j] == 1 ? p1GlowPaint : p2GlowPaint;
          canvas.drawLine(p1, p2, glowPaint);
        }
      }
    }
  }

  void _drawEdges(Canvas canvas) {
    final p1Paint = Paint()
      ..color = AppColors.p1WallColor
      ..strokeWidth = AppConstants.edgeThickness + 2
      ..strokeCap = StrokeCap.round;

    final p2Paint = Paint()
      ..color = AppColors.p2WallColor
      ..strokeWidth = AppConstants.edgeThickness + 2
      ..strokeCap = StrokeCap.round;

    final emptyPaint = Paint()
      ..color = AppColors.emptyWallColor
      ..strokeWidth = AppConstants.edgeThickness
      ..strokeCap = StrokeCap.round;

    final hoverPaint = Paint()
      ..color = AppColors.p1WallColor
      ..strokeWidth = AppConstants.edgeThickness + 3
      ..strokeCap = StrokeCap.round;

    // Draw horizontal edges
    for (int i = 0; i <= n; i++) {
      for (int j = 0; j < n; j++) {
        final p1 = Offset(j * cellSize, i * cellSize);
        final p2 = Offset((j + 1) * cellSize, i * cellSize);
        Paint paint;
        if (horizontalEdges[i][j] == 1)
          paint = p1Paint;
        else if (horizontalEdges[i][j] == 2)
          paint = p2Paint;
        else if (hoveredEdge?.type == 'h' &&
            hoveredEdge?.i == i &&
            hoveredEdge?.j == j)
          paint = hoverPaint;
        else
          paint = emptyPaint;
        canvas.drawLine(p1, p2, paint);
      }
    }

    // Draw vertical edges
    for (int i = 0; i < n; i++) {
      for (int j = 0; j <= n; j++) {
        final p1 = Offset(j * cellSize, i * cellSize);
        final p2 = Offset(j * cellSize, (i + 1) * cellSize);
        Paint paint;
        if (verticalEdges[i][j] == 1)
          paint = p1Paint;
        else if (verticalEdges[i][j] == 2)
          paint = p2Paint;
        else if (hoveredEdge?.type == 'v' &&
            hoveredEdge?.i == i &&
            hoveredEdge?.j == j)
          paint = hoverPaint;
        else
          paint = emptyPaint;
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  void _drawGridDots(Canvas canvas) {
    final dotPaint = Paint()..color = AppColors.canvasBorderColor;
    for (int r = 0; r <= n; r++) {
      for (int c = 0; c <= n; c++) {
        canvas.drawCircle(Offset(c * cellSize, r * cellSize), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    // Repaint if any game state affecting the visuals has changed
    return oldDelegate.horizontalEdges != horizontalEdges ||
        oldDelegate.verticalEdges != verticalEdges ||
        oldDelegate.boxes != boxes ||
        oldDelegate.hoveredEdge != hoveredEdge;
  }
}
