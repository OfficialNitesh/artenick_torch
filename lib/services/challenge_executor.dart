import 'package:flutter/material.dart';
import 'package:artenick/models/challenge.dart';
import 'package:artenick/screens/challenge/session/timer_only_session.dart';

// Routes to correct session screen based on challenge type
class ChallengeExecutor {
  static Widget getSessionScreen(Challenge challenge, ChallengeConfig config) {
    switch (challenge.type) {
      case ChallengeType.torchFlash:
        // Use torch flash session (Sniper, Pilot)
        return TorchFlashSession(challenge: challenge, config: config);
      
      case ChallengeType.timerOnly:
        // Use simple timer (Fasting, Meditation)
        return TimerOnlySession(challenge: challenge, config: config);
      
      case ChallengeType.interval:
      case ChallengeType.task:
      case ChallengeType.community:
        // For now, use timer-only for these
        // You can implement specific screens later
        return TimerOnlySession(challenge: challenge, config: config);
    }
  }
}