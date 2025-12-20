import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final users = await _userService.getAllUsers();
    final current = await _userService.getCurrentUser();
    
    setState(() {
      _users = users;
      _currentUser = current;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.leaderboard, size: 80, color: Colors.grey[700]),
                        SizedBox(height: 16),
                        Text(
                          'No rankings yet',
                          style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Complete challenges to appear here!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isCurrentUser = _currentUser?.id == user.id;
                      final rank = index + 1;

                      return Card(
                        color: isCurrentUser ? Colors.orange.withOpacity(0.2) : null,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getRankColor(rank),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                rank <= 3 ? _getRankEmoji(rank) : '$rank',
                                style: TextStyle(
                                  fontSize: rank <= 3 ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            user.username,
                            style: TextStyle(
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text('Level ${user.level} • ${user.levelName}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${user.totalPoints} pts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                '${user.completedSessions} sessions',
                                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey[400]!;
      case 3: return Colors.orange[800]!;
      default: return Colors.grey[800]!;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }
}