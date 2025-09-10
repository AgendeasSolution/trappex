import 'package:flutter/material.dart';
import '../common/glassmorphic_container.dart';

/// Score card widget for displaying player scores
class ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const ScoreCard({
    super.key,
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border.all(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(score.toString(),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color, // Use player color for score
                shadows: [
                  Shadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      offset: Offset(0, 1))
                ])),
      ),
    );
  }
}
