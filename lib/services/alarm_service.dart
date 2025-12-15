import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';

// Service to play alarm when session completes
class AlarmService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SettingsService _settings = SettingsService();
  Timer? _alarmTimer;
  
  // Available alarm sounds (built-in system sounds)
  static const Map<String, String> alarmSounds = {
    'notification': 'Notification Sound',
    'alarm': 'Alarm Sound',
    'ringtone': 'Ringtone',
    'beep': 'Beep Sound',
    'success': 'Success Tone',
  };
  
  // Play completion alarm
  Future<void> playCompletionAlarm() async {
    try {
      print('🔔 Playing completion alarm...');
      
      // Check if alarm is enabled
      final isEnabled = await _settings.getAlarmEnabled();
      if (!isEnabled) {
        print('⚠️ Alarm is disabled in settings');
        return;
      }
      
      // Get settings
      final alarmType = await _settings.getAlarmType();
      final volume = await _settings.getAlarmVolume();
      
      print('🔊 Volume: $volume, Type: $alarmType');
      
      // Vibrate pattern
      await _playVibration();
      
      // Play sound in a loop for 5 seconds
      await _playAlarmLoop(alarmType, volume);
      
      print('✅ Alarm completed');
      
    } catch (e) {
      print('❌ Error playing alarm: $e');
      // Fallback: strong vibration
      await _playVibration();
    }
  }
  
  // Play vibration pattern
  Future<void> _playVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Strong vibration pattern: 800ms on, 300ms off, repeated 4 times
        await Vibration.vibrate(
          pattern: [0, 800, 300, 800, 300, 800, 300, 800],
          intensities: [0, 255, 0, 255, 0, 255, 0, 255],
        );
      }
    } catch (e) {
      print('Vibration error: $e');
    }
  }
  
  // Play alarm sound in a loop
  Future<void> _playAlarmLoop(String alarmType, double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      
      // Play notification sound
      await _audioPlayer.setSource(AssetSource('sounds/notification.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
      
      // Stop after 5 seconds
      _alarmTimer = Timer(const Duration(seconds: 5), () {
        stopAlarm();
      });
      
    } catch (e) {
      print('Audio playback error: $e');
      // If audio fails, make longer vibration
      await Vibration.vibrate(duration: 3000);
    }
  }
  
  // Play preview of alarm (for settings screen)
  Future<void> playPreview(String soundType) async {
    try {
      print('🎵 Playing preview...');
      
      final volume = await _settings.getAlarmVolume();
      
      // Quick vibration
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 300);
      }
      
      // Play sound for 2 seconds
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setSource(AssetSource('sounds/notification.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.resume();
      
      // Stop after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      await stopAlarm();
      
    } catch (e) {
      print('Preview error: $e');
      // Fallback vibration
      await Vibration.vibrate(duration: 500);
    }
  }
  
  // Stop alarm
  Future<void> stopAlarm() async {
    try {
      _alarmTimer?.cancel();
      await _audioPlayer.stop();
      await Vibration.cancel();
      print('🛑 Alarm stopped');
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }
  
  // Dispose
  void dispose() {
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
  }
}