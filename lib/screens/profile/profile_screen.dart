import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/achievement.dart';
import '../../services/user_service.dart';
import '../settings/settings_screen.dart';
import '../settings/history_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(child: Text('No user found')),
      );
    }

    final achievements = getAllAchievements();
    final unlockedCount = _user!.achievementIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
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
            // Avatar & Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange,
                    child: Text(
                      _user!.username[0].toUpperCase(),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _user!.username,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Level ${_user!.level} • ${_user!.levelName}',
                    style: TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Level Progress
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level Progress'),
                        Text(
                          '${_user!.totalPoints} / ${_user!.pointsForNextLevel()} pts',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _user!.levelProgress(),
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Sessions',
                    _user!.totalSessions.toString(),
                    Icons.fitness_center,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    _user!.completedSessions.toString(),
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Streak',
                    '${_user!.currentStreak} days',
                    Icons.local_fire_department,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Points',
                    _user!.totalPoints.toString(),
                    Icons.star,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Achievements
            Text(
              'Achievements ($unlockedCount/${achievements.length})',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = _user!.achievementIds.contains(achievement.id);
                
                return Card(
                  color: isUnlocked ? Colors.orange.withOpacity(0.2) : Colors.grey[900],
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 32,
                        color: isUnlocked ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}