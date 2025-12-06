// This file defines the structure of a Challenge
class Challenge {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int durationMin; // Duration in minutes
  final String description;
  final String detailedRules;
  final String safetyText;
  final ChallengeConfig defaultConfig;
  final int color; // Color as hex value

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
  });
}

// Configuration for each challenge session
class ChallengeConfig {
  final int durationMin;
  final int minFlashes;
  final int maxFlashes;
  final int flashMs; // Flash duration in milliseconds
  final String silentMode; // 'silent', 'vibrate', 'beep'
  final bool headlessMode;
  final int minGapMin; // Minimum gap between flashes in minutes

  ChallengeConfig({
    required this.durationMin,
    required this.minFlashes,
    required this.maxFlashes,
    required this.flashMs,
    required this.silentMode,
    required this.headlessMode,
    required this.minGapMin,
  });

  // Create a copy with modified values
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

  SessionRecord({
    required this.challengeId,
    required this.challengeTitle,
    required this.startTime,
    required this.endTime,
    required this.configuredDuration,
    required this.actualDuration,
    required this.totalFlashesScheduled,
    required this.flashCount,
    required this.flashTimes,
    required this.completed,
    this.userFlashCount,
  });
}

// Default challenges
List<Challenge> getDefaultChallenges() {
  return [
    Challenge(
      id: '1',
      title: 'Recon Freeze — 3-Hour Sniper Immobility',
      category: 'Sniper Protocol',
      difficulty: 'Extreme',
      durationMin: 180,
      description: 'Simulate sniper overwatch: remain in prone recon/sniper-crawl position for 3 hours under environmental discomfort with torch-based random attention stimulus. Mentally count flashes and report exact total at end.',
      detailedRules: '''**Position Requirements:**
• Belly on ground/mat/charpai
• Elbows tucked under chest
• Neck slightly raised (no chin drop)
• One knee bent outward
• Face orientation fixed to one side, no turning

**Stillness Protocol:**
• No deliberate repositioning during session
• Slow, controlled breathing (4s inhale / 6s exhale)
• No exaggerated breaths on flashes

**Weapon Prop Rules:**
• Toy Glock allowed as prop only
• Slide must NOT be racked
• Gun must point at harmless object (foam bottle, cushion)
• Never toward person

**Memory Task:**
• Mentally count every flash
• No writing or digital counters during run
• Report count at end

**Failure Conditions:**
• Motion repositioning elbows, shoulders, neck >3cm
• Lifting chest more than breathing lift
• Reaching for water or adjusting gun
• Touching phone during session
• Passing out or medical assistance needed''',
      safetyText: '''⚠️ CRITICAL SAFETY WARNINGS:

**Medical Contraindications:**
• Heart conditions or cardiovascular disease
• Epilepsy or seizure history
• Neurological conditions
• Severe back, neck, or joint problems
• Diabetes or blood sugar issues
• Pregnancy
• Under 18 years old

**Weapon Safety:**
• NEVER use a real loaded firearm
• Toy prop only - confirm magazine removed
• Zero chance of firing - verify before session
• Gun must point at harmless object only

**Physical Risks:**
• Risk of muscle strain, numbness, circulation issues
• Risk of pressure injuries
• Risk of heat exhaustion
• Risk of fainting, dizziness

**Emergency Protocol:**
• If chest pain, severe dizziness, vision loss - STOP IMMEDIATELY
• Press PANIC button - no hesitation
• Have someone aware of your session
• Keep phone accessible for emergency calls''',
      defaultConfig: ChallengeConfig(
        durationMin: 180,
        minFlashes: 12,
        maxFlashes: 20,
        flashMs: 1000,
        silentMode: 'vibrate',
        headlessMode: true,
        minGapMin: 6,
      ),
      color: 0xFFDC2626, // Red
    ),
    Challenge(
      id: '2',
      title: 'Pilot Breath Protocol',
      category: 'Respiratory Control',
      difficulty: 'Hard',
      durationMin: 45,
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
      color: 0xFF2563EB, // Blue
    ),
    Challenge(
      id: '3',
      title: 'Astronaut Stillness',
      category: 'Zero-G Simulation',
      difficulty: 'Medium',
      durationMin: 30,
      description: '30-minute float simulation. Lie flat on back, arms at sides, legs uncrossed. Simulate zero-gravity stillness with minimal movement.',
      detailedRules: 'Supine position, completely flat. No scratching, no adjusting. Torch flashes simulate mission alerts. Mental counting required.',
      safetyText: 'Safe for most people. Stop if you experience back pain or discomfort. Not suitable for pregnant individuals.',
      defaultConfig: ChallengeConfig(
        durationMin: 30,
        minFlashes: 4,
        maxFlashes: 8,
        flashMs: 1000,
        silentMode: 'silent',
        headlessMode: false,
        minGapMin: 2,
      ),
      color: 0xFF7C3AED, // Purple
    ),
    Challenge(
      id: '4',
      title: 'Rain Loop Protocol',
      category: 'Endurance',
      difficulty: 'Medium',
      durationMin: 60,
      description: '1-hour meditation in simulated rain conditions. Maintain stillness despite discomfort. Torch flashes represent lightning.',
      detailedRules: 'Sit cross-legged or in chair. Close eyes. Environmental discomfort optional (damp cloth on shoulders). Count lightning flashes mentally.',
      safetyText: 'Generally safe. Stop if you experience severe discomfort. Keep room temperature moderate.',
      defaultConfig: ChallengeConfig(
        durationMin: 60,
        minFlashes: 8,
        maxFlashes: 12,
        flashMs: 1500,
        silentMode: 'vibrate',
        headlessMode: false,
        minGapMin: 3,
      ),
      color: 0xFF0891B2, // Cyan
    ),
  ];
}