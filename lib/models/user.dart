// User model for profile and social features

class User {
  final String id;
  String username;
  String? email;
  String? bio;
  String avatarUrl;
  
  // Stats
  int totalSessions;
  int completedSessions;
  int currentStreak;
  int longestStreak;
  int totalPoints;
  int level;
  
  // Social
  List<String> following;
  List<String> followers;
  List<String> achievementIds;
  
  // Settings
  bool isPublic;
  bool allowFollowers;
  bool showOnLeaderboard;
  
  // Timestamps
  DateTime createdAt;
  DateTime lastActive;
  DateTime? lastSessionDate;

  User({
    required this.id,
    required this.username,
    this.email,
    this.bio,
    this.avatarUrl = '',
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPoints = 0,
    this.level = 1,
    this.following = const [],
    this.followers = const [],
    this.achievementIds = const [],
    this.isPublic = true,
    this.allowFollowers = true,
    this.showOnLeaderboard = true,
    DateTime? createdAt,
    DateTime? lastActive,
    this.lastSessionDate,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.lastActive = lastActive ?? DateTime.now();

  // Calculate level from points
  int calculateLevel() {
    if (totalPoints < 100) return 1;
    if (totalPoints < 500) return 2;
    if (totalPoints < 1000) return 3;
    if (totalPoints < 2500) return 4;
    if (totalPoints < 5000) return 5;
    if (totalPoints < 10000) return 6;
    return 7;
  }
  
  // Get level name
  String get levelName {
    switch (level) {
      case 1: return 'Beginner';
      case 2: return 'Learner';
      case 3: return 'Practitioner';
      case 4: return 'Expert';
      case 5: return 'Master';
      case 6: return 'Legend';
      case 7: return 'Grand Master';
      default: return 'Unknown';
    }
  }
  
  // Points needed for next level
  int pointsForNextLevel() {
    switch (level) {
      case 1: return 100;
      case 2: return 500;
      case 3: return 1000;
      case 4: return 2500;
      case 5: return 5000;
      case 6: return 10000;
      default: return 0;
    }
  }
  
  // Progress to next level (0.0 to 1.0)
  double levelProgress() {
    final nextLevel = pointsForNextLevel();
    if (nextLevel == 0) return 1.0;
    
    int previousLevelPoints = 0;
    if (level > 1) {
      switch (level - 1) {
        case 1: previousLevelPoints = 100; break;
        case 2: previousLevelPoints = 500; break;
        case 3: previousLevelPoints = 1000; break;
        case 4: previousLevelPoints = 2500; break;
        case 5: previousLevelPoints = 5000; break;
      }
    }
    
    final pointsInCurrentLevel = totalPoints - previousLevelPoints;
    final pointsNeededForLevel = nextLevel - previousLevelPoints;
    
    return (pointsInCurrentLevel / pointsNeededForLevel).clamp(0.0, 1.0);
  }
  
  // Update streak
  void updateStreak(DateTime sessionDate) {
    if (lastSessionDate == null) {
      currentStreak = 1;
    } else {
      final daysDiff = sessionDate.difference(lastSessionDate!).inDays;
      
      if (daysDiff == 1) {
        // Consecutive day
        currentStreak++;
      } else if (daysDiff == 0) {
        // Same day, keep streak
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }
    
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    
    lastSessionDate = sessionDate;
  }
  
  // Add points and recalculate level
  void addPoints(int points) {
    totalPoints += points;
    level = calculateLevel();
  }
  
  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'level': level,
      'following': following.join(','),
      'followers': followers.join(','),
      'achievementIds': achievementIds.join(','),
      'isPublic': isPublic ? 1 : 0,
      'allowFollowers': allowFollowers ? 1 : 0,
      'showOnLeaderboard': showOnLeaderboard ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'lastSessionDate': lastSessionDate?.toIso8601String(),
    };
  }
  
  // Create from map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      bio: map['bio'],
      avatarUrl: map['avatarUrl'] ?? '',
      totalSessions: map['totalSessions'] ?? 0,
      completedSessions: map['completedSessions'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      level: map['level'] ?? 1,
      following: (map['following'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      followers: (map['followers'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      achievementIds: (map['achievementIds'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      isPublic: map['isPublic'] == 1,
      allowFollowers: map['allowFollowers'] == 1,
      showOnLeaderboard: map['showOnLeaderboard'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      lastSessionDate: map['lastSessionDate'] != null ? DateTime.parse(map['lastSessionDate']) : null,
    );
  }
}