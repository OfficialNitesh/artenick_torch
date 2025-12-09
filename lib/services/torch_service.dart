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
  
  // Generate flash schedule - TRULY RANDOM VERSION
  List<int> _generateSchedule(int durationSec, int minFlashes, int maxFlashes, int minGapSec) {
    final random = Random();
    
    // Pick random number between min and max
    int targetFlashes = minFlashes + random.nextInt(maxFlashes - minFlashes + 1);
    
    print('🎯 Target flashes: $targetFlashes for $durationSec seconds');
    
    // Reserve 5 seconds at start and end
    final startPadding = 5;
    final endPadding = 5;
    final usableDuration = durationSec - startPadding - endPadding;
    
    // Calculate minimum possible gap
    final minPossibleGap = (usableDuration / targetFlashes).floor();
    int adjustedMinGap = minGapSec;
    if (minGapSec * targetFlashes > usableDuration) {
      adjustedMinGap = max(minPossibleGap, 5); // At least 5 seconds
      print('⚠️ Min gap adjusted to ${adjustedMinGap}s');
    }
    
    final schedule = <int>[];
    
    // TRULY RANDOM: Generate completely random times
    final possibleTimes = <int>[];
    for (int t = startPadding; t < (durationSec - endPadding); t++) {
      possibleTimes.add(t);
    }
    
    // Shuffle all possible times
    possibleTimes.shuffle(random);
    
    // Pick flashes ensuring minimum gap
    for (int time in possibleTimes) {
      if (schedule.isEmpty) {
        schedule.add(time);
      } else {
        // Check if this time is far enough from all previous flashes
        bool validTime = true;
        for (int prevTime in schedule) {
          if ((time - prevTime).abs() < adjustedMinGap) {
            validTime = false;
            break;
          }
        }
        if (validTime) {
          schedule.add(time);
        }
      }
      
      // Stop when we have enough flashes
      if (schedule.length >= targetFlashes) {
        break;
      }
    }
    
    // Sort chronologically for easier checking
    schedule.sort();
    
    _totalFlashesScheduled = schedule.length;
    print('✅ Scheduled ${schedule.length} RANDOM flashes at: $schedule');
    
    return schedule;
  }
  
  int max(int a, int b) => a > b ? a : b;
  
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
    
    print('\n🚀 Starting session: $durationMin min, $minFlashes-$maxFlashes flashes, min gap: $minGapMin min');
    
    _flashSchedule = _generateSchedule(durationSec, minFlashes, maxFlashes, minGapSec);
    
    _isRunning = true;
    _isPaused = false;
    _secondsElapsed = 0;
    _flashCount = 0;
    _flashTimes = [];
    
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
          print('💡 Flash #$_flashCount at ${_secondsElapsed}s');
          onFlash?.call(_flashCount);
          
          // Trigger torch flash
          await _triggerFlash(flashMs, silentMode);
        }
        
        // Check if session complete
        if (_secondsElapsed >= durationSec) {
          print('✅ Session complete: $_flashCount flashes seen, $_totalFlashesScheduled scheduled');
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