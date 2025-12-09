import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/database_service.dart';

// Results screen after session completion
class ResultsScreen extends StatefulWidget {
  final SessionRecord session;

  const ResultsScreen({required this.session});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _countController = TextEditingController();
  bool _showComparison = false;
  int? _userCount;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Auto-save session to database
    _saveSession();
  }

  Future<void> _saveSession() async {
    try {
      await _db.saveSession(widget.session);
      setState(() => _isSaved = true);
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  void _compareCount() async {
    final count = int.tryParse(_countController.text);
    if (count != null) {
      setState(() {
        _userCount = count;
        _showComparison = true;
      });
      
      // Update session with user count
      final updatedSession = SessionRecord(
        challengeId: widget.session.challengeId,
        challengeTitle: widget.session.challengeTitle,
        startTime: widget.session.startTime,
        endTime: widget.session.endTime,
        configuredDuration: widget.session.configuredDuration,
        actualDuration: widget.session.actualDuration,
        totalFlashesScheduled: widget.session.totalFlashesScheduled,
        flashCount: widget.session.flashCount,
        flashTimes: widget.session.flashTimes,
        completed: widget.session.completed,
        userFlashCount: count,
      );
      
      await _db.saveSession(updatedSession);
    }
  }

  bool get _isCorrect => _userCount == widget.session.totalFlashesScheduled;
  
  int get _difference => (_userCount ?? 0 - widget.session.totalFlashesScheduled).abs();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Go back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Session Results'),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Status icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.session.completed ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.session.completed ? Icons.check : Icons.close,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Title
              Text(
                widget.session.completed ? 'Session Completed' : 'Session Aborted',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                widget.session.challengeTitle,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: '${widget.session.actualDuration.toStringAsFixed(1)}m',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.flashlight_on,
                      label: 'Flashes Seen',
                      value: '${widget.session.flashCount}',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.scatter_plot,
                      label: 'Total Scheduled',
                      value: '${widget.session.totalFlashesScheduled}',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.access_time,
                      label: 'Start Time',
                      value: _formatTime(widget.session.startTime),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Memory test
              if (widget.session.completed) ...[
                Card(
                  color: Colors.purple[900]!.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.purple),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.purple[300]),
                            SizedBox(width: 12),
                            Text(
                              '🧠 Memory Test',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'How many flashes did you count mentally during the session?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[300],
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _countController,
                                keyboardType: TextInputType.number,
                                enabled: !_showComparison,
                                decoration: InputDecoration(
                                  labelText: 'Your count',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.black38,
                                ),
                                style: TextStyle(fontSize: 18, fontFamily: 'monospace'),
                              ),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _showComparison ? null : _compareCount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              ),
                              child: Text('Compare'),
                            ),
                          ],
                        ),

                        if (_showComparison) ...[
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isCorrect
                                  ? Colors.green[900]!.withOpacity(0.4)
                                  : Colors.red[900]!.withOpacity(0.4),
                              border: Border.all(
                                color: _isCorrect ? Colors.green : Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isCorrect ? '✅' : '❌',
                                  style: TextStyle(fontSize: 32),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _isCorrect
                                      ? 'Perfect Memory!'
                                      : 'Memory Mismatch',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _isCorrect ? Colors.green[300] : Colors.red[300],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _isCorrect
                                      ? 'You counted exactly ${widget.session.totalFlashesScheduled} flashes. Exceptional focus and discipline.'
                                      : 'You counted $_userCount, but there were ${widget.session.totalFlashesScheduled} flashes. Difference: $_difference ${_difference == 1 ? 'flash' : 'flashes'}.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                if (!_isCorrect) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'This is normal during intense focus. Practice improves attention and memory under stress.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],

              // Return button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.orange,
                ),
                child: Text(
                  'Return to Challenges',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}