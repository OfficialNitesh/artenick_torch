import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/challenge.dart';

// Database service for persistent storage
class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'artenick_torch.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Challenges table
        await db.execute('''
          CREATE TABLE challenges(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT,
            difficulty TEXT,
            durationMin INTEGER,
            description TEXT,
            detailedRules TEXT,
            safetyText TEXT,
            minFlashes INTEGER,
            maxFlashes INTEGER,
            flashMs INTEGER,
            silentMode TEXT,
            headlessMode INTEGER,
            minGapMin INTEGER,
            color INTEGER
          )
        ''');
        
        // Sessions table
        await db.execute('''
          CREATE TABLE sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            challengeId TEXT,
            challengeTitle TEXT,
            startTime TEXT,
            endTime TEXT,
            configuredDuration INTEGER,
            actualDuration REAL,
            totalFlashesScheduled INTEGER,
            flashCount INTEGER,
            completed INTEGER,
            userFlashCount INTEGER
          )
        ''');
        
        // Statistics table
        await db.execute('''
          CREATE TABLE statistics(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            challengeId TEXT,
            totalSessions INTEGER DEFAULT 0,
            completedSessions INTEGER DEFAULT 0,
            totalDuration REAL DEFAULT 0,
            totalFlashes INTEGER DEFAULT 0,
            perfectMemoryCount INTEGER DEFAULT 0,
            lastAttempt TEXT
          )
        ''');
      },
    );
  }
  
  // Save custom challenge
  Future<int> saveChallenge(Challenge challenge) async {
    final db = await database;
    
    final data = {
      'id': challenge.id,
      'title': challenge.title,
      'category': challenge.category,
      'difficulty': challenge.difficulty,
      'durationMin': challenge.durationMin,
      'description': challenge.description,
      'detailedRules': challenge.detailedRules,
      'safetyText': challenge.safetyText,
      'minFlashes': challenge.defaultConfig.minFlashes,
      'maxFlashes': challenge.defaultConfig.maxFlashes,
      'flashMs': challenge.defaultConfig.flashMs,
      'silentMode': challenge.defaultConfig.silentMode,
      'headlessMode': challenge.defaultConfig.headlessMode ? 1 : 0,
      'minGapMin': challenge.defaultConfig.minGapMin,
      'color': challenge.color,
    };
    
    return await db.insert('challenges', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  // Load custom challenges
  Future<List<Challenge>> loadCustomChallenges() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('challenges');
    
    return maps.map((map) {
      return Challenge(
        id: map['id'],
        title: map['title'],
        category: map['category'],
        difficulty: map['difficulty'],
        durationMin: map['durationMin'],
        description: map['description'],
        detailedRules: map['detailedRules'],
        safetyText: map['safetyText'],
        defaultConfig: ChallengeConfig(
          durationMin: map['durationMin'],
          minFlashes: map['minFlashes'],
          maxFlashes: map['maxFlashes'],
          flashMs: map['flashMs'],
          silentMode: map['silentMode'],
          headlessMode: map['headlessMode'] == 1,
          minGapMin: map['minGapMin'],
        ),
        color: map['color'],
      );
    }).toList();
  }
  
  // Delete challenge
  Future<int> deleteChallenge(String id) async {
    final db = await database;
    return await db.delete('challenges', where: 'id = ?', whereArgs: [id]);
  }
  
  // Save session
  Future<int> saveSession(SessionRecord session) async {
    final db = await database;
    
    final data = {
      'challengeId': session.challengeId,
      'challengeTitle': session.challengeTitle,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime.toIso8601String(),
      'configuredDuration': session.configuredDuration,
      'actualDuration': session.actualDuration,
      'totalFlashesScheduled': session.totalFlashesScheduled,
      'flashCount': session.flashCount,
      'completed': session.completed ? 1 : 0,
      'userFlashCount': session.userFlashCount,
    };
    
    // Update statistics
    await _updateStatistics(session);
    
    return await db.insert('sessions', data);
  }
  
  // Update statistics
  Future<void> _updateStatistics(SessionRecord session) async {
    final db = await database;
    
    final existing = await db.query(
      'statistics',
      where: 'challengeId = ?',
      whereArgs: [session.challengeId],
    );
    
    if (existing.isEmpty) {
      // Create new statistics
      await db.insert('statistics', {
        'challengeId': session.challengeId,
        'totalSessions': 1,
        'completedSessions': session.completed ? 1 : 0,
        'totalDuration': session.actualDuration,
        'totalFlashes': session.flashCount,
        'perfectMemoryCount': (session.userFlashCount == session.totalFlashesScheduled) ? 1 : 0,
        'lastAttempt': session.endTime.toIso8601String(),
      });
    } else {
      // Update existing statistics
      final stats = existing.first;
      await db.update(
        'statistics',
        {
          'totalSessions': (stats['totalSessions'] as int) + 1,
          'completedSessions': (stats['completedSessions'] as int) + (session.completed ? 1 : 0),
          'totalDuration': (stats['totalDuration'] as double) + session.actualDuration,
          'totalFlashes': (stats['totalFlashes'] as int) + session.flashCount,
          'perfectMemoryCount': (stats['perfectMemoryCount'] as int) + ((session.userFlashCount == session.totalFlashesScheduled) ? 1 : 0),
          'lastAttempt': session.endTime.toIso8601String(),
        },
        where: 'challengeId = ?',
        whereArgs: [session.challengeId],
      );
    }
  }
  
  // Load all sessions
  Future<List<SessionRecord>> loadSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'startTime DESC',
    );
    
    return maps.map((map) {
      return SessionRecord(
        challengeId: map['challengeId'],
        challengeTitle: map['challengeTitle'],
        startTime: DateTime.parse(map['startTime']),
        endTime: DateTime.parse(map['endTime']),
        configuredDuration: map['configuredDuration'],
        actualDuration: map['actualDuration'],
        totalFlashesScheduled: map['totalFlashesScheduled'],
        flashCount: map['flashCount'],
        flashTimes: [], // Not stored in simple version
        completed: map['completed'] == 1,
        userFlashCount: map['userFlashCount'],
      );
    }).toList();
  }
  
  // Get statistics for a challenge
  Future<Map<String, dynamic>?> getChallengeStats(String challengeId) async {
    final db = await database;
    final result = await db.query(
      'statistics',
      where: 'challengeId = ?',
      whereArgs: [challengeId],
    );
    
    return result.isNotEmpty ? result.first : null;
  }
  
  // Get overall statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await database;
    
    final sessions = await db.query('sessions');
    final totalSessions = sessions.length;
    final completedSessions = sessions.where((s) => s['completed'] == 1).length;
    
    double totalDuration = 0;
    int totalFlashes = 0;
    int perfectMemory = 0;
    
    for (var session in sessions) {
      totalDuration += session['actualDuration'] as double;
      totalFlashes += session['flashCount'] as int;
      if (session['userFlashCount'] == session['totalFlashesScheduled']) {
        perfectMemory++;
      }
    }
    
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalDuration': totalDuration,
      'totalFlashes': totalFlashes,
      'perfectMemoryCount': perfectMemory,
      'completionRate': totalSessions > 0 ? (completedSessions / totalSessions * 100) : 0.0,
      'averageDuration': totalSessions > 0 ? (totalDuration / totalSessions) : 0.0,
    };
  }
}