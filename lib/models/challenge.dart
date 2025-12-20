// Challenge types and models - UPDATED FOR MODULAR SYSTEM

// Challenge types enum
enum ChallengeType {
  torchFlash,    // Uses torch flashing (Sniper Protocol)
  timerOnly,     // Pure timer, no interruptions (Fasting, Meditation)
  interval,      // Regular interval alerts (Workouts)
  task,          // Checklist-based (Habits)
  community,     // Group challenge (Social)
}

// Main Challenge class
class Challenge {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int durationMin;
  final String description;
  final String detailedRules;
  final String safetyText;
  final int color;
  
  // NEW: Challenge type
  final ChallengeType type;
  
  // NEW: Type-specific configuration
  final Map<String, dynamic> typeConfig;
  
  // NEW: Social features
  final bool isPublic;
  final bool allowLeaderboard;
  final String creatorId;
  final DateTime createdAt;
  final List<String> tags;
  
  // Default config (used for all types)
  final ChallengeConfig defaultConfig;

  Challenge({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.durationMin,
    required this.description,
    required this.detailedRules,
    required this.safetyText,
    required this.defaultConfig,
    required this.color,
    this.type = ChallengeType.timerOnly,
    this.typeConfig = const {},
    this.isPublic = false,
    this.allowLeaderboard = true,
    this.creatorId = 'local',
    DateTime? createdAt,
    this.tags = const [],
  }) : this.createdAt = createdAt ?? DateTime.now();
  
  // Convert type enum to string
  String get typeString {
    switch (type) {
      case ChallengeType.torchFlash:
        return 'torch_flash';
      case ChallengeType.timerOnly:
        return 'timer_only';
      case ChallengeType.interval:
        return 'interval';
      case ChallengeType.task:
        return 'task';
      case ChallengeType.community:
        return 'community';
    }
  }
  
  // Convert string to type enum
  static ChallengeType typeFromString(String str) {
    switch (str) {
      case 'torch_flash':
        return ChallengeType.torchFlash;
      case 'timer_only':
        return ChallengeType.timerOnly;
      case 'interval':
        return ChallengeType.interval;
      case 'task':
        return ChallengeType.task;
      case 'community':
        return ChallengeType.community;
      default:
        return ChallengeType.timerOnly;
    }
  }
}

// Configuration for each challenge
class ChallengeConfig {
  final int durationMin;
  final int minFlashes;
  final int maxFlashes;
  final int flashMs;
  final String silentMode;
  final bool headlessMode;
  final int minGapMin;

  ChallengeConfig({
    required this.durationMin,
    this.minFlashes = 0,
    this.maxFlashes = 0,
    this.flashMs = 1000,
    this.silentMode = 'vibrate',
    this.headlessMode = false,
    this.minGapMin = 1,
  });

  ChallengeConfig copyWith({
    int? durationMin,
    int? minFlashes,
    int? maxFlashes,
    int? flashMs,
    String? silentMode,
    bool? headlessMode,
    int? minGapMin,
  }) {
    return ChallengeConfig(
      durationMin: durationMin ?? this.durationMin,
      minFlashes: minFlashes ?? this.minFlashes,
      maxFlashes: maxFlashes ?? this.maxFlashes,
      flashMs: flashMs ?? this.flashMs,
      silentMode: silentMode ?? this.silentMode,
      headlessMode: headlessMode ?? this.headlessMode,
      minGapMin: minGapMin ?? this.minGapMin,
    );
  }
}

// Session record after completion
class SessionRecord {
  final String challengeId;
  final String challengeTitle;
  final DateTime startTime;
  final DateTime endTime;
  final int configuredDuration;
  final double actualDuration;
  final int totalFlashesScheduled;
  final int flashCount;
  final List<DateTime> flashTimes;
  final bool completed;
  final int? userFlashCount;
  
  // NEW: Points earned
  final int pointsEarned;
  
  // NEW: Achievements unlocked
  final List<String> achievementsUnlocked;

  SessionRecord({
    required this.challengeId,
    required this.challengeTitle,
    required this.startTime,
    required this.endTime,
    required this.configuredDuration,
    required this.actualDuration,
    this.totalFlashesScheduled = 0,
    this.flashCount = 0,
    this.flashTimes = const [],
    required this.completed,
    this.userFlashCount,
    this.pointsEarned = 10,
    this.achievementsUnlocked = const [],
  });
}

// Default challenges with proper types
List<Challenge> getDefaultChallenges() {
  return [
    // TORCH FLASH CHALLENGES
    Challenge(
      id: '1',
      title: 'Recon Freeze — 3-Hour Sniper Immobility',
      category: 'Sniper Protocol',
      difficulty: 'Extreme',
      durationMin: 180,
      type: ChallengeType.torchFlash, // USES TORCH
      description: 'Simulate sniper overwatch: remain in prone recon/sniper-crawl position for 3 hours under environmental discomfort with torch-based random attention stimulus. Mentally count flashes and report exact total at end.',
      detailedRules: '''**Position Requirements:**
• Belly on ground/mat/charpai
• Elbows tucked under chest
• Neck slightly raised (no chin drop)
• One knee bent outward
• Face orientation fixed to one side, no turning

**Memory Task:**
• Mentally count every flash
• No writing or digital counters during run
• Report count at end''',
      safetyText: '''⚠️ CRITICAL SAFETY WARNINGS:
• Never use real loaded weapons
• Risk of severe muscle strain
• Stop if you feel chest pain or dizziness''',
      defaultConfig: ChallengeConfig(
        durationMin: 180,
        minFlashes: 12,
        maxFlashes: 20,
        flashMs: 1000,
        silentMode: 'vibrate',
        headlessMode: true,
        minGapMin: 6,
      ),
      color: 0xFFDC2626,
      isPublic: true,
      allowLeaderboard: true,
      tags: ['extreme', 'endurance', 'military'],
    ),
    
    Challenge(
      id: '2',
      title: 'Pilot Breath Protocol',
      category: 'Respiratory Control',
      difficulty: 'Hard',
      durationMin: 45,
      type: ChallengeType.torchFlash, // USES TORCH
      description: '45-minute controlled breathing exercise simulating high-altitude pilot oxygen management. 4-7-8 breathing pattern with random attention checks via torch flash.',
      detailedRules: 'Sit upright, maintain 4-7-8 breathing (4s inhale, 7s hold, 8s exhale). Random torch flashes test attention maintenance. Count each flash mentally.',
      safetyText: 'Do not attempt if you have respiratory conditions, asthma, or panic disorders. Stop if you feel lightheaded or dizzy.',
      defaultConfig: ChallengeConfig(
        durationMin: 45,
        minFlashes: 6,
        maxFlashes: 10,
        flashMs: 800,
        silentMode: 'vibrate',
        headlessMode: false,
        minGapMin: 3,
      ),
      color: 0xFF2563EB,
      isPublic: true,
      allowLeaderboard: true,
      tags: ['breathing', 'meditation', 'focus'],
    ),
    
    // TIMER-ONLY CHALLENGES (NO TORCH)
    Challenge(
      id: '3',
      title: '24-Hour Water Fast',
      category: 'Fasting',
      difficulty: 'Hard',
      durationMin: 1440, // 24 hours
      type: ChallengeType.timerOnly, // NO TORCH
      description: 'Complete 24-hour water-only fast. Test your mental discipline and metabolic adaptation. Only water allowed.',
      detailedRules: '''**Rules:**
• Only water consumption allowed
• No food, coffee, tea, or other beverages
• Track energy levels
• Stay hydrated
• Break fast safely with light food''',
      safetyText: '''⚠️ SAFETY:
• Not for diabetics or pregnant women
• Consult doctor if on medication
• Stop if severe dizziness occurs
• Have someone check on you''',
      defaultConfig: ChallengeConfig(
        durationMin: 1440,
        minFlashes: 0, // No flashes for timer-only
        maxFlashes: 0,
      ),
      color: 0xFF0891B2,
      isPublic: true,
      allowLeaderboard: true,
      tags: ['fasting', 'endurance', 'discipline'],
    ),
    
    Challenge(
      id: '4',
      title: 'Silent Meditation Hour',
      category: 'Meditation',
      difficulty: 'Medium',
      durationMin: 60,
      type: ChallengeType.timerOnly, // NO TORCH
      description: '1 hour of complete silence and stillness. Sit or lie down, focus on breath, observe thoughts without engaging.',
      detailedRules: '''**Guidelines:**
• Find quiet space
• Comfortable position (sitting or lying)
• Focus on natural breathing
• Observe thoughts, let them pass
• No movement except breathing''',
      safetyText: 'Safe for most people. Stop if anxiety increases. Not suitable for severe mental health conditions without supervision.',
      defaultConfig: ChallengeConfig(
        durationMin: 60,
      ),
      color: 0xFF7C3AED,
      isPublic: true,
      allowLeaderboard: true,
      tags: ['meditation', 'mindfulness', 'peace'],
    ),
    
    Challenge(
      id: '5',
      title: 'Cold Shower Endurance',
      category: 'Physical',
      difficulty: 'Hard',
      durationMin: 5,
      type: ChallengeType.timerOnly, // NO TORCH
      description: '5 minutes of cold shower. Build cold resilience, improve circulation, strengthen willpower.',
      detailedRules: '''**Protocol:**
• Water temperature: Cold (not ice)
• Start with 30 seconds if new
• Breathe slowly and deeply
• Focus on breath control
• Gradual exposure''',
      safetyText: '''⚠️ RISKS:
• Hypothermia risk
• Not for heart conditions
• Have warm environment ready
• Start short, build up''',
      defaultConfig: ChallengeConfig(
        durationMin: 5,
      ),
      color: 0xFF06B6D4,
      isPublic: true,
      allowLeaderboard: true,
      tags: ['physical', 'cold', 'willpower'],
    ),
    
    Challenge(
      id: '6',
      title: 'Digital Detox Day',
      category: 'Mental Discipline',
      difficulty: 'Hard',
      durationMin: 1440, // 24 hours
      type: ChallengeType.timerOnly, // NO TORCH
      description: '24 hours without any screens or digital devices. Rediscover analog life, boredom, and deep focus.',
      detailedRules: '''**Rules:**
• No phone (keep for emergencies only)
• No computer, TV, tablets
• No social media
• No digital entertainment
• Read books, write, walk, talk''',
      safetyText: 'Inform emergency contacts. Keep paper with emergency numbers. May cause withdrawal anxiety initially.',
      defaultConfig: ChallengeConfig(
        durationMin: 1440,
      ),
      color: 0xFF16A34A,
      isPublic: true,
      allowLeaderboard: true,
      tags: ['digital detox', 'discipline', 'mindfulness'],
    ),
  ];
}