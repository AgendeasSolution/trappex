import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/audio_service.dart';
import '../services/update_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/home/game_mode_chip.dart';
import '../widgets/home/grid_chip.dart';
import 'other_games_screen.dart';
import '../widgets/common/popup_overlay.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/common/update_bottom_sheet.dart';

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
  bool _isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _player1Controller = TextEditingController(text: widget.player1Name);
    _player2Controller = TextEditingController(text: widget.player2Name);
    _loadSoundState();
    _checkForUpdate();
  }

  /// Check for app updates and show bottom sheet if available
  Future<void> _checkForUpdate() async {
    // Wait a bit for the screen to load before checking
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    try {
      final updateService = UpdateService();
      final hasUpdate = await updateService.checkForUpdate();
      
      if (hasUpdate && mounted) {
        final storeUrl = updateService.getStoreUrl();
        UpdateBottomSheet.show(context, storeUrl);
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
    }
  }

  Future<void> _loadSoundState() async {
    _isSoundEnabled = AudioService.instance.isSoundEnabled;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);
    final bottomPadding = ResponsiveUtils.getResponsiveSpacing(context, 70.0, 75.0, 80.0);
    
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
            Column(
          children: [
            // Main content area
            Expanded(
              child: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          ResponsiveUtils.getResponsiveSpacing(context, 16.0, 20.0, 24.0),
                          horizontalPadding,
                          bottomPadding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title - Responsive with FittedBox to ensure one line
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppConstants.appName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveLogoFontSize(context),
                                  color: AppColors.p1Color,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: ResponsiveUtils.getResponsiveValue(context, 1.0, 1.2, 1.5),
                                  shadows: [
                                    Shadow(
                                      color: AppColors.homeAccentGlow.withOpacity(0.3),
                                      blurRadius: ResponsiveUtils.getResponsiveValue(context, 8, 10, 12),
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: AppColors.homeAccentGlow.withOpacity(0.2),
                                      blurRadius: ResponsiveUtils.getResponsiveValue(context, 12, 14, 16),
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0, 18.0, 20.0)),
                            
                            // Game Mode Selector
                            _buildGameModeSelector(context),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0, 14.0, 16.0)),
                            
                            // Grid Size Selector (Difficulty)
                            _buildGridSelector(context),
                            
                            // Player Name Fields (only shown in 1v1 mode)
                            if (widget.gameMode == AppConstants.oneVsOneMode) ...[
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0, 18.0, 20.0)),
                              _buildPlayerNameFields(context),
                            ],
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0, 18.0, 20.0)),
                            
                            // Play Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await AudioService.instance.playClickSound();
                                  widget.onStartGame();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.homeAccent,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveUtils.getResponsiveValue(context, 10, 12, 14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.getResponsiveValue(context, 12, 14, 16),
                                    ),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ).copyWith(
                                  elevation: MaterialStateProperty.all(0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.getResponsiveValue(context, 12, 14, 16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.homeAccentGlow.withOpacity(0.25),
                                        blurRadius: ResponsiveUtils.getResponsiveValue(context, 6, 8, 10),
                                        spreadRadius: ResponsiveUtils.getResponsiveValue(context, 0, 1, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Start Game",
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18, 20, 22),
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0, 27.0, 30.0)),
                            
                            // How to Play and Sound buttons at top of Explore More Games section
                            if (!_isHowToPlayVisible)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildHowToPlayIconButton(context),
                                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8, 9, 10)),
                                  _buildSoundToggleButton(context),
                                ],
                              ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10.0, 11.0, 12.0)),
                            
                            // Explore More Games Section
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.p1Color,
                                  size: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
                                ),
                                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 6.0, 7.0, 8.0)),
                                Flexible(
                                  child: Text(
                                    "Explore More Games",
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
                                      color: AppColors.p1Color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10.0, 11.0, 12.0)),
                            _buildGamesLinksRow(context),
                            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20.0, 22.0, 24.0)),
                          ],
                        ),
                      ),
                    ),
                    if (_isHowToPlayVisible) _buildHowToPlayPopup(context),
                    // Ad Banner - transparent overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: const AdBanner(),
                    ),
                  ],
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

  Widget _buildSoundToggleButton(BuildContext context) {
    final iconSize = ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18);
    final buttonSize = ResponsiveUtils.getResponsiveValue(context, 36, 38, 40);
    final padding = ResponsiveUtils.getResponsiveValue(context, 6, 7, 8);
    final borderRadius = ResponsiveUtils.getResponsiveValue(context, 6, 7, 8);
    
    return OutlinedButton(
      onPressed: () async {
        await AudioService.instance.toggleSound();
        setState(() {
          _isSoundEnabled = AudioService.instance.isSoundEnabled;
        });
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(padding),
        side: BorderSide(color: AppColors.mutedColor.withOpacity(0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: AppColors.mutedColor.withOpacity(0.1),
        minimumSize: Size(buttonSize, buttonSize),
      ),
      child: Icon(
        _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
        color: _isSoundEnabled ? AppColors.p1Color : AppColors.mutedColor,
        size: iconSize,
      ),
    );
  }

  Widget _buildHowToPlayIconButton(BuildContext context) {
    final iconSize = ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18);
    final buttonSize = ResponsiveUtils.getResponsiveValue(context, 36, 38, 40);
    final padding = ResponsiveUtils.getResponsiveValue(context, 6, 7, 8);
    final borderRadius = ResponsiveUtils.getResponsiveValue(context, 6, 7, 8);
    
    return OutlinedButton(
      onPressed: () async {
        await AudioService.instance.playClickSound();
        setState(() => _isHowToPlayVisible = true);
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(padding),
        side: BorderSide(color: AppColors.mutedColor.withOpacity(0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: AppColors.mutedColor.withOpacity(0.1),
        minimumSize: Size(buttonSize, buttonSize),
      ),
      child: Icon(
        Icons.help_outline,
        color: _isSoundEnabled ? AppColors.p1Color : AppColors.mutedColor,
        size: iconSize,
      ),
    );
  }

  Widget _buildHowToPlayPopup(BuildContext context) {
    final maxHeight = ResponsiveUtils.getResponsiveValue(context, 400, 450, 500);
    final reducedPadding = ResponsiveUtils.getResponsiveValue(context, 8, 10, 12);
    final topMargin = ResponsiveUtils.getResponsiveValue(context, 2, 3, 4);
    
    return PopupOverlay(
      showBackdrop: true,
      onDismiss: () async {
        await AudioService.instance.playClickSound();
        setState(() => _isHowToPlayVisible = false);
      },
      padding: EdgeInsets.all(reducedPadding),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: EdgeInsets.symmetric(horizontal: reducedPadding),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with small top margin like close button
                  Padding(
                    padding: EdgeInsets.only(top: topMargin),
                    child: Text(
                      "How to Play",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24, 26, 28),
                        color: AppColors.p1Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12)),
                  Text(
                    "Objective:",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
                      color: AppColors.p1Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4, 5, 6)),
                  _buildRuleItem(context, "Claim the most squares by completing them with walls"),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12)),
                  Text(
                    "How to Play:",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
                      color: AppColors.p1Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4, 5, 6)),
                  _buildRuleItem(context, "1. Click on any cell/Square's edge to place a wall"),
                  _buildRuleItem(context, "2. Players take turns placing one wall at a time"),
                  _buildRuleItem(context, "3. When you complete a square by placing its 4th wall, you claim it"),
                  _buildRuleItem(context, "4. Claiming a square gives you another turn immediately"),
                  _buildRuleItem(context, "5. The game ends when all possible walls are placed"),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12)),
                  Text(
                    "Winning:",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
                      color: AppColors.p1Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4, 5, 6)),
                  _buildRuleItem(context, "The player with the most claimed squares wins!"),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6, 7, 8)),
                ],
              ),
            ),
          ),
          // Close button at completely top-right corner
          Positioned(
            top: topMargin,
            right: ResponsiveUtils.getResponsiveValue(context, 2, 3, 4),
            child: OutlinedButton(
              onPressed: () async {
                await AudioService.instance.playClickSound();
                setState(() => _isHowToPlayVisible = false);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(
                  ResponsiveUtils.getResponsiveValue(context, 32, 34, 36),
                  ResponsiveUtils.getResponsiveValue(context, 32, 34, 36),
                ),
                side: BorderSide(
                  color: AppColors.homeAccent,
                  width: 1.5,
                ),
                backgroundColor: AppColors.homeBgDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveValue(context, 6, 7, 8),
                  ),
                ),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.homeAccent,
                size: ResponsiveUtils.getResponsiveFontSize(context, 16, 17, 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 4, 5, 6)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.mutedColor,
            height: 1.4,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12, 13, 14),
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }


  Widget _buildGameModeSelector(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12);
    
    return Row(
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
        SizedBox(width: spacing),
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
    );
  }

  Widget _buildPlayerNameFields(BuildContext context) {
    final padding = ResponsiveUtils.getResponsiveValue(context, 16, 18, 20);
    final borderRadius = ResponsiveUtils.getResponsiveValue(context, 12, 14, 16);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.homeCardBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.homeCardBorder.withOpacity(0.6),
          width: ResponsiveUtils.getResponsiveValue(context, 1.5, 1.75, 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Player Names",
            style: TextStyle(
              color: AppColors.p1Color,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12, 14, 16)),
          Row(
            children: [
              Expanded(
                child: _buildPlayerNameField(
                  context,
                  "Player 1",
                  _player1Controller,
                  widget.onPlayer1NameChanged,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildPlayerNameField(
                  context,
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

  Widget _buildPlayerNameField(
    BuildContext context,
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    final borderRadius = ResponsiveUtils.getResponsiveValue(context, 6, 7, 8);
    final horizontalPadding = ResponsiveUtils.getResponsiveValue(context, 10, 11, 12);
    final verticalPadding = ResponsiveUtils.getResponsiveValue(context, 6, 7, 8);
    
    return TextField(
      onChanged: onChanged,
      controller: controller,
      style: TextStyle(
        color: Colors.white,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12, 13, 14),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.mutedColor.withOpacity(0.8),
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10, 11, 12),
        ),
        hintText: "Enter name",
        hintStyle: TextStyle(
          color: AppColors.mutedColor.withOpacity(0.5),
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12, 13, 14),
        ),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.homeCardBorder.withOpacity(0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.homeCardBorder.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.homeAccentGlow,
            width: ResponsiveUtils.getResponsiveValue(context, 1.5, 1.75, 2),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
    );
  }

  Widget _buildGridSelector(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12);
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: ResponsiveUtils.getResponsiveSpacing(context, 8, 10, 12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Difficulty",
              style: TextStyle(
                color: AppColors.mutedColor,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18, 19, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8, 10, 12)),
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
            SizedBox(width: spacing),
            Expanded(
              child: GridChip(
                size: AppConstants.classicGridSize,
                label: "Classic",
                isSelected: widget.selectedGridSize == AppConstants.classicGridSize,
                onTap: () => widget.onGridSizeChanged(AppConstants.classicGridSize),
              ),
            ),
            SizedBox(width: spacing),
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

  Widget _buildGamesLinksRow(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 10, 11, 12);
    
    return Row(
      children: [
        Expanded(child: _buildMobileGamesButton(context)),
        SizedBox(width: spacing),
        Expanded(child: _buildWebGamesButton(context)),
      ],
    );
  }

  Widget _buildMobileGamesButton(BuildContext context) {
    final verticalPadding = ResponsiveUtils.getResponsiveValue(context, 12, 13, 14);
    final borderRadius = ResponsiveUtils.getResponsiveValue(context, 10, 11, 12);
    final borderWidth = ResponsiveUtils.getResponsiveValue(context, 1.25, 1.375, 1.5);
    final iconSize = ResponsiveUtils.getResponsiveFontSize(context, 18, 19, 20);
    
    return OutlinedButton.icon(
      onPressed: () async {
        await AudioService.instance.playClickSound();
        if (!mounted) return;
        Navigator.of(context).push(OtherGamesScreen.createRoute());
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        side: BorderSide(
          color: AppColors.p1Color.withOpacity(0.8),
          width: borderWidth,
        ),
        backgroundColor: AppColors.mutedColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      icon: Icon(
        Icons.phone_iphone,
        color: AppColors.p1Color,
        size: iconSize,
      ),
      label: Text(
        "Mobile Games",
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
          color: AppColors.p1Color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildWebGamesButton(BuildContext context) {
    final verticalPadding = ResponsiveUtils.getResponsiveValue(context, 12, 13, 14);
    final borderRadius = ResponsiveUtils.getResponsiveValue(context, 10, 11, 12);
    final borderWidth = ResponsiveUtils.getResponsiveValue(context, 1.25, 1.375, 1.5);
    final iconSize = ResponsiveUtils.getResponsiveFontSize(context, 18, 19, 20);
    
    return OutlinedButton.icon(
      onPressed: () async {
        await AudioService.instance.playClickSound();
        await _launchWebGames();
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        side: BorderSide(
          color: AppColors.p1Color.withOpacity(0.8),
          width: borderWidth,
        ),
        backgroundColor: AppColors.mutedColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      icon: Icon(
        Icons.language,
        color: AppColors.p1Color,
        size: iconSize,
      ),
      label: Text(
        "Web Games",
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14, 15, 16),
          color: AppColors.p1Color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _launchWebGames() async {
    final uri = Uri.parse(AppConstants.webGamesUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open freegametoplay.com'),
          backgroundColor: Colors.black.withOpacity(0.85),
        ),
      );
    }
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

