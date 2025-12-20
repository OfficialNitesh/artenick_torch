import '../../services/challenge_executor.dart';

// In the start button onPressed:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChallengeExecutor.getSessionScreen(challenge, config),
  ),
);