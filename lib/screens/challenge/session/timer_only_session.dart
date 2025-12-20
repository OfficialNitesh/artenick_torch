import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../models/challenge.dart';
import '../../../services/alarm_service.dart';
import '../../results/results_screen.dart';

class TimerOnlySession extends StatefulWidget {
  final Challenge challenge;
  final ChallengeConfig config;

  const TimerOnlySession({
    required this.challenge,
    required this.config,
  });

  @override
  _TimerOnlySessionState createState() => _TimerOnlySessionState();
}

class _TimerOnlySessionState extends State<TimerOnlySession> {
  final AlarmService _alarmService = AlarmService();
  
  int _secondsLeft = 0;
  bool _showPanicConfirm = false;
  DateTime? _startTime;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.durationMin * 60;
    _startSession();
  }

  void _startSession() async {
    _startTime = DateTime.now();
    await WakelockPlus.enable();
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
        
        if (_secondsLeft <= 0) {
          _completeSession();
        }
      });
    });
  }

  void _completeSession() async {
    _timer?.cancel();
    await WakelockPlus.disable();
    
    // Play alarm
    await _alarmService.playCompletionAlarm();
    
    final session = SessionRecord(
      challengeId: widget.challenge.id,
      challengeTitle: widget.challenge.title,
      startTime: _startTime!,
      endTime: DateTime.now(),
      configuredDuration: widget.config.durationMin,
      actualDuration: widget.config.durationMin.toDouble(),
      totalFlashesScheduled: 0,
      flashCount: 0,
      completed: true,
      pointsEarned: _calculatePoints(),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(session: session),
      ),
    );
  }

  int _calculatePoints() {
    int points = 10; // Base
    if (widget.config.durationMin >= 180) points += 50;
    if (widget.config.durationMin >= 60) points += 20;
    return points;
  }

  void _handlePanic() {
    if (_showPanicConfirm) {
      _timer?.cancel();
      WakelockPlus.disable();
      Navigator.pop(context);
    } else {
      setState(() => _showPanicConfirm = true);
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) setState(() => _showPanicConfirm = false);
      });
    }
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alarmService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer
              Text(
                _formatTime(_secondsLeft),
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: 16),
              
              // Challenge title
              Text(
                widget.challenge.title,
                style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              
              // Panic button
              ElevatedButton(
                onPressed: _handlePanic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showPanicConfirm ? Colors.red : Colors.red[900],
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                ),
                child: Text(
                  _showPanicConfirm ? 'TAP AGAIN TO ABORT' : '🚨 PANIC',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}