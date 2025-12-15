import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/challenge.dart';
import '../services/torch_service.dart';
import '../services/alarm_service.dart';
import 'results_screen.dart';

// Main session screen - runs the challenge
class SessionScreen extends StatefulWidget {
  final Challenge challenge;
  final ChallengeConfig config;

  const SessionScreen({super.key, 
    required this.challenge,
    required this.config,
  });

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final TorchService _torchService = TorchService();
  final AlarmService _alarmService = AlarmService();
  
  int _secondsLeft = 0;
  int _flashCount = 0;
  bool _showPanicConfirm = false;
  DateTime? _startTime;
  final List<DateTime> _flashTimes = [];
  
  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.durationMin * 60;
    _checkPermissionsAndStart();
  }

  // Check permissions and start session
  Future<void> _checkPermissionsAndStart() async {
    // Request camera permission (needed for torch)
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      // Check if torch is available
      final hasTorch = await _torchService.hasTorch();
      
      if (!hasTorch) {
        _showError('Torch not available on this device');
        return;
      }
      
      // Start the session
      _startSession();
    } else {
      _showError('Camera permission required for torch control');
    }
  }

  void _startSession() {
    _startTime = DateTime.now();
    
    // Setup callbacks
    _torchService.onTick = (secondsLeft) {
      if (mounted) {
        setState(() {
          _secondsLeft = secondsLeft;
        });
      }
    };
    
    _torchService.onFlash = (flashNumber) {
      if (mounted) {
        setState(() {
          _flashCount = flashNumber;
        });
      }
    };
    
    _torchService.onComplete = () {
      _completeSession();
    };
    
    // Start the torch service
    _torchService.startSession(
      durationMin: widget.config.durationMin,
      minFlashes: widget.config.minFlashes,
      maxFlashes: widget.config.maxFlashes,
      flashMs: widget.config.flashMs,
      minGapMin: widget.config.minGapMin,
      silentMode: widget.config.silentMode,
    );
  }

  void _completeSession() async {
    print('✅ Session completing...');
    
    // Play completion alarm
    await _alarmService.playCompletionAlarm();
    
    final session = SessionRecord(
      challengeId: widget.challenge.id,
      challengeTitle: widget.challenge.title,
      startTime: _startTime!,
      endTime: DateTime.now(),
      configuredDuration: widget.config.durationMin,
      actualDuration: widget.config.durationMin.toDouble(),
      totalFlashesScheduled: _torchService.totalFlashesScheduled,
      flashCount: _flashCount,
      flashTimes: _torchService.flashTimes,
      completed: true,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(session: session),
      ),
    );
  }

  void _handlePanic() {
    if (_showPanicConfirm) {
      // Second tap - abort
      _torchService.stopSession();
      
      final session = SessionRecord(
        challengeId: widget.challenge.id,
        challengeTitle: widget.challenge.title,
        startTime: _startTime!,
        endTime: DateTime.now(),
        configuredDuration: widget.config.durationMin,
        actualDuration: (widget.config.durationMin * 60 - _secondsLeft) / 60,
        totalFlashesScheduled: _torchService.totalFlashesScheduled,
        flashCount: _flashCount,
        flashTimes: _torchService.flashTimes,
        completed: false,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(session: session),
        ),
      );
    } else {
      // First tap - show confirmation
      setState(() {
        _showPanicConfirm = true;
      });
      
      // Reset after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showPanicConfirm = false;
          });
        }
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = widget.config.durationMin * 60;
    final elapsed = total - _secondsLeft;
    return elapsed / total;
  }

  @override
  void dispose() {
    _torchService.dispose();
    _alarmService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config.headlessMode) {
      return _buildHeadlessMode();
    } else {
      return _buildNormalMode();
    }
  }

  Widget _buildHeadlessMode() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer (very subtle)
            Text(
              _formatTime(_secondsLeft),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.challenge.title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            
            // Panic button
            ElevatedButton(
              onPressed: _handlePanic,
              style: ElevatedButton.styleFrom(
                backgroundColor: _showPanicConfirm ? Colors.red : Colors.red[900],
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _showPanicConfirm ? 'TAP AGAIN TO ABORT' : '🚨 PANIC',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (_showPanicConfirm) ...[
              const SizedBox(height: 16),
              Text(
                'Tap again within 3 seconds to abort',
                style: TextStyle(color: Colors.red[300], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNormalMode() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer
                Text(
                  _formatTime(_secondsLeft),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Challenge title
                Text(
                  widget.challenge.title,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Flash count (hidden total)
                Text(
                  'Flash $_flashCount',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Progress bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.red],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Pause button
                ElevatedButton(
                  onPressed: () {
                    _torchService.togglePause();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _torchService.isPaused ? Icons.play_arrow : Icons.pause,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _torchService.isPaused ? 'Resume' : 'Pause',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Panic button
                ElevatedButton(
                  onPressed: _handlePanic,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showPanicConfirm ? Colors.red : Colors.red[900],
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _showPanicConfirm ? '⚠️ TAP AGAIN TO ABORT' : '🚨 PANIC STOP',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_showPanicConfirm) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tap again within 3 seconds to abort session',
                    style: TextStyle(color: Colors.red[300], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}