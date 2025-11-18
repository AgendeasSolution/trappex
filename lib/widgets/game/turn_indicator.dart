import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive_utils.dart';

/// Turn indicator widget showing whose turn it is
class TurnIndicator extends StatelessWidget {
  final int turn;
  final String gameMode;
  final String? player1Name;
  final String? player2Name;
  
  const TurnIndicator({
    super.key,
    required this.turn,
    required this.gameMode,
    this.player1Name,
    this.player2Name,
  });

  @override
  Widget build(BuildContext context) {
    String playerName;
    IconData playerIcon;
    Color playerColor;
    
    if (gameMode == AppConstants.vsComputerMode) {
      if (turn == 1) {
        playerName = "Player";
        playerIcon = Icons.person_rounded;
        playerColor = AppColors.p1WallColor;
      } else {
        playerName = "Computer";
        playerIcon = Icons.computer_rounded;
        playerColor = AppColors.p2WallColor;
      }
    } else {
      if (turn == 1) {
        playerName = player1Name ?? "Player 1";
        playerIcon = Icons.person_rounded;
        playerColor = AppColors.p1WallColor;
      } else {
        playerName = player2Name ?? "Player 2";
        playerIcon = Icons.group_rounded;
        playerColor = AppColors.p2WallColor;
      }
    }
    
    return Transform.rotate(
      angle: (turn == 2 && gameMode != AppConstants.vsComputerMode) ? pi : 0, // 180 degrees for player 2 in 1v1 mode only
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveValue(context, 12, 14, 16),
          vertical: ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveValue(context, 12, 14, 16),
          ),
          color: playerColor.withOpacity(0.1),
          border: Border.all(
            color: playerColor,
            width: ResponsiveUtils.getResponsiveValue(context, 1.5, 1.75, 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              playerIcon,
              color: playerColor,
              size: ResponsiveUtils.getResponsiveFontSize(context, 20, 22, 24),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 6, 7, 8)),
            Text(
              playerName,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18, 19, 20),
                fontWeight: FontWeight.w700,
                color: playerColor,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: ResponsiveUtils.getResponsiveValue(context, 3, 3.5, 4),
                    offset: Offset(0, ResponsiveUtils.getResponsiveValue(context, 1.5, 1.75, 2)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
