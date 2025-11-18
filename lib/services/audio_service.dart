import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio service to manage all sound effects in the game
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioService get instance => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
    } catch (e) {
      _isSoundEnabled = true; // Default to enabled
    }
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _isSoundEnabled;

  /// Toggle sound on/off
  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _isSoundEnabled);
    } catch (e) {
      // Error saving sound preference - continue silently
    }
  }

  /// Play a sound effect
  Future<void> _playSound(String assetPath) async {
    if (!_isSoundEnabled) return;

    try {
      // Stop any currently playing sound to allow new sound to play
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Error playing sound - continue silently
    }
  }

  /// Play move sound for player 1
  Future<void> playPlayer1Move() async {
    await _playSound('audio/move_1.mp3');
  }

  /// Play move sound for player 2/computer
  Future<void> playPlayer2Move() async {
    await _playSound('audio/move_2.mp3');
  }

  /// Play win sound (for 1vs1 or player win vs computer)
  Future<void> playWinSound() async {
    await _playSound('audio/win_1.mp3');
  }

  /// Play lose sound (for player lose vs computer)
  Future<void> playLoseSound() async {
    await _playSound('audio/fail_3.mp3');
  }

  /// Play button click sound
  Future<void> playClickSound() async {
    await _playSound('audio/mouse_click_5.mp3');
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
