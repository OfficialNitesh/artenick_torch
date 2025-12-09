import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/challenge.dart';
import '../services/database_service.dart';

// History screen showing past sessions
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService();
  List<SessionRecord> sessions = [];
  Map<String, dynamic>? overallStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final loadedSessions = await _db.loadSessions();
    final stats = await _db.getOverallStats();
    
    setState(() {
      sessions = loadedSessions;
      overallStats = stats;
      isLoading = false;
    });
  }

  void _exportCSV() {
    if (sessions.isEmpty) return;
    
    // Create CSV content
    final buffer = StringBuffer();
    buffer.writeln('Challenge,Date,Time,Duration (min),Flashes Scheduled,Flashes Seen,User Count,Completed,Accuracy');
    
    for (var session in sessions) {
      final accuracy = session.userFlashCount != null && session.totalFlashesScheduled > 0
          ? ((session.userFlashCount! / session.totalFlashesScheduled) * 100).toStringAsFixed(1)
          : 'N/A';
      
      buffer.writeln([
        '"${session.challengeTitle}"',
        session.startTime.toLocal().toString().split(' ')[0],
        session.startTime.toLocal().toString().split(' ')[1].substring(0, 5),
        session.actualDuration.toStringAsFixed(1),
        session.totalFlashesScheduled,
        session.flashCount,
        session.userFlashCount ?? 'N/A',
        session.completed ? 'Yes' : 'No',
        accuracy,
      ].join(','));
    }
    
    // Share CSV
    Share.share(
      buffer.toString(),
      subject: 'Artenick Challenge History - ${DateTime.now().toString().split(' ')[0]}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Statistics'),
        actions: [
          if (sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportCSV,
              tooltip: 'Export CSV',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : sessions.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overall statistics
                      _buildOverallStats(),
                      const SizedBox(height: 24),
                      
                      // Session list
                      const Text(
                        'Session History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...sessions.map((session) => _buildSessionCard(session)).toList(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: TextStyle(fontSize: 24, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a challenge to see history',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    if (overallStats == null) return const SizedBox.shrink();
    
    return Card(
      color: Colors.orange.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.orange),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Overall Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Sessions',
                    '${overallStats!['totalSessions']}',
                    Icons.fitness_center,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    '${overallStats!['completedSessions']}',
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Time',
                    '${(overallStats!['totalDuration'] / 60).toStringAsFixed(1)}h',
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Perfect Memory',
                    '${overallStats!['perfectMemoryCount']}',
                    Icons.psychology,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Completion Rate',
                    '${overallStats!['completionRate'].toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Flashes',
                    '${overallStats!['totalFlashes']}',
                    Icons.flashlight_on,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange[300], size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionRecord session) {
    final isAccurate = session.userFlashCount != null &&
        session.userFlashCount == session.totalFlashesScheduled;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.challengeTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.completed ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.completed ? 'COMPLETED' : 'ABORTED',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              '${_formatDate(session.startTime)} at ${_formatTime(session.startTime)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildSessionStat(
                  Icons.timer,
                  '${session.actualDuration.toStringAsFixed(1)}m',
                ),
                const SizedBox(width: 16),
                _buildSessionStat(
                  Icons.flashlight_on,
                  '${session.flashCount}/${session.totalFlashesScheduled}',
                ),
                if (session.userFlashCount != null) ...[
                  const SizedBox(width: 16),
                  _buildSessionStat(
                    Icons.psychology,
                    '${session.userFlashCount}',
                    color: isAccurate ? Colors.green : Colors.orange,
                  ),
                  if (isAccurate)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStat(IconData icon, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}