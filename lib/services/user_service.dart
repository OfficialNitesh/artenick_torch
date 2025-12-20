import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/achievement.dart';

// Service to manage current user
class UserService {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  
  User? _currentUser;
  Database? _database;

  // Get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'artenick_users.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT,
            bio TEXT,
            avatarUrl TEXT,
            totalSessions INTEGER DEFAULT 0,
            completedSessions INTEGER DEFAULT 0,
            currentStreak INTEGER DEFAULT 0,
            longestStreak INTEGER DEFAULT 0,
            totalPoints INTEGER DEFAULT 0,
            level INTEGER DEFAULT 1,
            following TEXT,
            followers TEXT,
            achievementIds TEXT,
            isPublic INTEGER DEFAULT 1,
            allowFollowers INTEGER DEFAULT 1,
            showOnLeaderboard INTEGER DEFAULT 1,
            createdAt TEXT,
            lastActive TEXT,
            lastSessionDate TEXT
          )
        ''');
      },
    );
  }

  // Check if onboarding is complete
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  // Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  // Create new user
  Future<User> createUser(String username) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    final db = await database;
    await db.insert('users', user.toMap());

    // Save as current user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, user.id);

    _currentUser = user;
    return user;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserIdKey);

    if (userId == null) return null;

    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;

    _currentUser = User.fromMap(results.first);
    return _currentUser;
  }

  // Update user
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    _currentUser = user;
  }

  // Record session completion
  Future<void> recordSession({
    required bool completed,
    required int durationMin,
    required DateTime sessionDate,
  }) async {
    final user = await getCurrentUser();
    if (user == null) return;

    user.totalSessions++;
    if (completed) {
      user.completedSessions++;
      
      // Calculate points
      int points = 10; // Base points
      if (durationMin >= 180) points += 50; // 3+ hour bonus
      if (durationMin >= 60) points += 20; // 1+ hour bonus
      
      user.addPoints(points);
      user.updateStreak(sessionDate);
      
      // Check for new achievements
      await _checkAchievements(user);
    }

    user.lastActive = DateTime.now();
    await updateUser(user);
  }

  // Check and unlock achievements
  Future<List<String>> _checkAchievements(User user) async {
    final allAchievements = getAllAchievements();
    final newAchievements = <String>[];

    for (var achievement in allAchievements) {
      // Skip if already unlocked
      if (user.achievementIds.contains(achievement.id)) continue;

      bool unlocked = false;

      switch (achievement.type) {
        case AchievementType.session:
          if (user.completedSessions >= _getRequiredSessions(achievement.id)) {
            unlocked = true;
          }
          break;
        case AchievementType.streak:
          if (user.currentStreak >= _getRequiredStreak(achievement.id)) {
            unlocked = true;
          }
          break;
        case AchievementType.points:
          if (user.totalPoints >= achievement.pointsRequired) {
            unlocked = true;
          }
          break;
        case AchievementType.special:
          // Handle special achievements
          break;
      }

      if (unlocked) {
        user.achievementIds.add(achievement.id);
        newAchievements.add(achievement.id);
      }
    }

    return newAchievements;
  }

  int _getRequiredSessions(String achievementId) {
    switch (achievementId) {
      case 'first_step': return 1;
      case 'dedicated': return 10;
      case 'committed': return 50;
      default: return 0;
    }
  }

  int _getRequiredStreak(String achievementId) {
    switch (achievementId) {
      case 'week_warrior': return 7;
      case 'month_master': return 30;
      default: return 0;
    }
  }

  // Get all users for leaderboard
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'showOnLeaderboard = ?',
      whereArgs: [1],
      orderBy: 'totalPoints DESC',
      limit: 100,
    );

    return results.map((map) => User.fromMap(map)).toList();
  }

  // Update username
  Future<void> updateUsername(String newUsername) async {
    final user = await getCurrentUser();
    if (user == null) return;

    user.username = newUsername;
    await updateUser(user);
  }

  // Update bio
  Future<void> updateBio(String? newBio) async {
    final user = await getCurrentUser();
    if (user == null) return;

    user.bio = newBio;
    await updateUser(user);
  }
}