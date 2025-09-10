import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/home/game_mode_chip.dart';
import '../widgets/home/grid_chip.dart';
import '../widgets/common/popup_overlay.dart';

/// Home screen widget for game setup and welcome
class HomeScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  final int selectedGridSize;
  final String gameMode;
  final String player1Name;
  final String player2Name;
  final ValueChanged<int> onGridSizeChanged;
  final ValueChanged<String> onGameModeChanged;
  final ValueChanged<String> onPlayer1NameChanged;
  final ValueChanged<String> onPlayer2NameChanged;

  const HomeScreen({
    super.key,
    required this.onStartGame,
    required this.selectedGridSize,
    required this.gameMode,
    required this.player1Name,
    required this.player2Name,
    required this.onGridSizeChanged,
    required this.onGameModeChanged,
    required this.onPlayer1NameChanged,
    required this.onPlayer2NameChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _player1Controller;
  late TextEditingController _player2Controller;
  bool _isHowToPlayVisible = false;

  @override
  void initState() {
    super.initState();
    _player1Controller = TextEditingController(text: widget.player1Name);
    _player2Controller = TextEditingController(text: widget.player2Name);
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 36,
                        color: AppColors.p1Color,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Game Mode Selector
                    _buildGameModeSelector(),
                    const SizedBox(height: 16),
                    
                    // Grid Size Selector
                    _buildGridSelector(context),
                    const SizedBox(height: 40),
                    
                    // Play Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onStartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.p1Color,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.p1Color.withOpacity(0.3),
                        ),
                        child: const Text(
                          "Start Game",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (_isHowToPlayVisible) _buildHowToPlayPopup(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHowToPlayButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => setState(() => _isHowToPlayVisible = true),
      icon: const Icon(Icons.help_outline, color: AppColors.mutedColor, size: 18),
      label: const Text(
        "How to Play",
        style: TextStyle(
          fontSize: 14,
          color: AppColors.mutedColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        side: BorderSide(color: AppColors.mutedColor.withOpacity(0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppColors.mutedColor.withOpacity(0.1),
      ),
    );
  }

  Widget _buildHowToPlayPopup() {
    return PopupOverlay(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How to Play",
                style: TextStyle(
                  fontSize: 28,
                  color: AppColors.p1Color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Objective:",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.p1Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _buildRuleItem("Claim the most squares by completing them with walls"),
              const SizedBox(height: 12),
              const Text(
                "How to Play:",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.p1Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _buildRuleItem("1. Click on any cell/Square's edge to place a wall"),
              _buildRuleItem("2. Players take turns placing one wall at a time"),
              _buildRuleItem("3. When you complete a square by placing its 4th wall, you claim it"),
              _buildRuleItem("4. Claiming a square gives you another turn immediately"),
              _buildRuleItem("5. The game ends when all possible walls are placed"),
              const SizedBox(height: 12),
              const Text(
                "Winning:",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.p1Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _buildRuleItem("The player with the most claimed squares wins!"),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isHowToPlayVisible = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.p1Color,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Got it!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.mutedColor,
            height: 1.4,
            fontSize: 14,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildGameModeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GameModeChip(
                mode: AppConstants.vsComputerMode,
                label: "vs Computer",
                icon: Icons.computer,
                isSelected: widget.gameMode == AppConstants.vsComputerMode,
                onTap: () => widget.onGameModeChanged(AppConstants.vsComputerMode),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GameModeChip(
                mode: AppConstants.oneVsOneMode,
                label: "1 vs 1",
                icon: Icons.people,
                isSelected: widget.gameMode == AppConstants.oneVsOneMode,
                onTap: () => widget.onGameModeChanged(AppConstants.oneVsOneMode),
              ),
            ),
          ],
        ),
        if (widget.gameMode == AppConstants.oneVsOneMode) ...[
          const SizedBox(height: 20),
          _buildPlayerNameFields(),
        ],
      ],
    );
  }

  Widget _buildPlayerNameFields() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mutedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mutedColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Player Names",
            style: TextStyle(
              color: AppColors.mutedColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPlayerNameField(
                  "Player 1",
                  _player1Controller,
                  widget.onPlayer1NameChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlayerNameField(
                  "Player 2",
                  _player2Controller,
                  widget.onPlayer2NameChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerNameField(String label, TextEditingController controller, ValueChanged<String> onChanged) {
    return TextField(
      onChanged: onChanged,
      controller: controller,
      style: TextStyle(
        color: AppColors.mutedColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.mutedColor.withOpacity(0.7),
          fontSize: 12,
        ),
        hintText: "Enter name",
        hintStyle: TextStyle(
          color: AppColors.mutedColor.withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.mutedColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mutedColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mutedColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mutedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildGridSelector(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Difficulty",
              style: TextStyle(
                color: AppColors.mutedColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildCompactHowToPlayButton(context),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: GridChip(
                size: AppConstants.easyGridSize,
                label: "Easy",
                isSelected: widget.selectedGridSize == AppConstants.easyGridSize,
                onTap: () => widget.onGridSizeChanged(AppConstants.easyGridSize),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GridChip(
                size: AppConstants.classicGridSize,
                label: "Classic",
                isSelected: widget.selectedGridSize == AppConstants.classicGridSize,
                onTap: () => widget.onGridSizeChanged(AppConstants.classicGridSize),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GridChip(
                size: AppConstants.hardGridSize,
                label: "Hard",
                isSelected: widget.selectedGridSize == AppConstants.hardGridSize,
                onTap: () => widget.onGridSizeChanged(AppConstants.hardGridSize),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
