import 'dart:async';
import 'dart:math';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// This service controls the torch/flashlight and manages session timing
class TorchService {
  Timer? _timer;
  List<int> _flashSchedule = [];
  int _flashCount = 0;
  int _secondsElapsed = 0;
  int _totalFlashesScheduled = 0;
  List<DateTime> _flashTimes = [];
  
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Callbacks that screens can listen to
  Function(int secondsLeft)? onTick;
  Function(int flashNumber)? onFlash;
  Function()? onComplete;
  
  // Check if device has torch
  Future<bool> hasTorch() async {
    try {
      return await TorchLight.isTorchAvailable();
    } catch (e) {
      print('Error checking torch: $e');
      return false;
    }
  }
  
  // Generate flash schedule using segment sampling algorithm
  List<int> _generateSchedule(int durationSec, int minFlashes, int maxFlashes, int minGapSec) {
    final random = Random();
    final flashCount = minFlashes + random.nextInt(maxFlashes - minFlashes + 1);
    final schedule = <int>[];
    
    // Divide session into N segments
    final segmentLength = durationSec ~/ flashCount;
    
    for (int i = 0; i < flashCount; i++) {
      final segmentStart = i * segmentLength;
      final segmentEnd = (i + 1) * segmentLength;
      
      // Random time within this segment
      int randomTime = segmentStart + random.nextInt(segmentEnd - segmentStart);
      
      // Ensure minimum gap from previous flash
      if (schedule.isEmpty || randomTime - schedule.last >= minGapSec) {
        schedule.add(randomTime);
      } else {
        // If too close, push it forward by minimum gap
        schedule.add(schedule.last + minGapSec);
      }
    }
    
    _totalFlashesScheduled = flashCount;
    return schedule;
  }
  
  // Start a session
  Future<void> startSession({
    required int durationMin,
    required int minFlashes,
    required int maxFlashes,
    required int flashMs,
    required int minGapMin,
    String silentMode = 'vibrate',
  }) async {
    // Enable wake lock to prevent screen/CPU sleep
    await WakelockPlus.enable();
    
    // Generate flash schedule
    final durationSec = durationMin * 60;
    final minGapSec = minGapMin * 60;
    _flashSchedule = _generateSchedule(durationSec, minFlashes, maxFlashes, minGapSec);
    
    _isRunning = true;
    _isPaused = false;
    _secondsElapsed = 0;
    _flashCount = 0;
    _flashTimes = [];
    
    print('Session started: $durationMin min, ${_flashSchedule.length} flashes scheduled');
    
    // Start countdown timer (ticks every second)
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!_isPaused && _isRunning) {
        _secondsElapsed++;
        
        // Calculate seconds remaining
        final secondsLeft = durationSec - _secondsElapsed;
        onTick?.call(secondsLeft);
        
        // Check if should flash at this second
        if (_flashSchedule.contains(_secondsElapsed)) {
          _flashCount++;
          _flashTimes.add(DateTime.now());
          onFlash?.call(_flashCount);
          
          // Trigger torch flash
          await _triggerFlash(flashMs, silentMode);
        }
        
        // Check if session complete
        if (_secondsElapsed >= durationSec) {
          await stopSession();
          onComplete?.call();
        }
      }
    });
  }
  
  // Trigger a single flash
  Future<void> _triggerFlash(int durationMs, String silentMode) async {
    try {
      // Turn torch ON
      await TorchLight.enableTorch();
      
      // Vibrate if enabled
      if (silentMode == 'vibrate') {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 200);
        }
      }
      
      // Wait for flash duration
      await Future.delayed(Duration(milliseconds: durationMs));
      
      // Turn torch OFF
      await TorchLight.disableTorch();
      
    } catch (e) {
      print('Flash error: $e');
      // If torch fails, at least ensure it's off
      try {
        await TorchLight.disableTorch();
      } catch (_) {}
    }
  }
  
  // Pause session
  void pause() {
    _isPaused = true;
  }
  
  // Resume session
  void resume() {
    _isPaused = false;
  }
  
  // Toggle pause/resume
  void togglePause() {
    _isPaused = !_isPaused;
  }
  
  // Stop session
  Future<void> stopSession() async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    
    // Ensure torch is off
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print('Error disabling torch: $e');
    }
    
    // Disable wake lock
    await WakelockPlus.disable();
    
    print('Session stopped');
  }
  
  // Getters
  int get totalFlashesScheduled => _totalFlashesScheduled;
  int get flashCount => _flashCount;
  int get secondsElapsed => _secondsElapsed;
  List<DateTime> get flashTimes => _flashTimes;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  
  // Clean up
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
  }
}