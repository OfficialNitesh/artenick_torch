import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/database_service.dart';
import 'detail_screen.dart';
import 'create_challenge_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

// Main home screen showing all challenges
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  List<Challenge> challenges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => isLoading = true);
    
    // Load default challenges
    final defaultChallenges = getDefaultChallenges();
    
    // Load custom challenges from database
    final customChallenges = await _db.loadCustomChallenges();
    
    setState(() {
      challenges = [...defaultChallenges, ...customChallenges];
      isLoading = false;
    });
  }

  void _addCustomChallenge() async {
    final newChallenge = await Navigator.push<Challenge>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateChallengeScreen(),
      ),
    );

    if (newChallenge != null) {
      // Save to database
      await _db.saveChallenge(newChallenge);
      
      // Reload challenges
      await _loadChallenges();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge created and saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteChallenge(Challenge challenge) async {
    // Can only delete custom challenges (not default ones)
    final defaultIds = getDefaultChallenges().map((c) => c.id).toList();
    
    if (defaultIds.contains(challenge.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete default challenges'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Challenge?'),
        content: Text('Are you sure you want to delete "${challenge.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete from database
              await _db.deleteChallenge(challenge.id);
              
              // Reload challenges
              await _loadChallenges();
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Challenge deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.flashlight_on, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Artenick',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: 'History & Stats',
          ),
          IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      },
      tooltip: 'Settings',
    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomChallenge,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Create Challenge'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A0A0A),
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  const Text(
                    'Discipline Protocols',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rituals for discipline, practice for resilience',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${challenges.length} challenges available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Warning banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This app controls your phone\'s torch/flashlight. Ensure your device supports torch control.',
                            style: TextStyle(color: Colors.orange[200]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Challenge cards
                  ...challenges.map((challenge) => ChallengeCard(
                    challenge: challenge,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(challenge: challenge),
                        ),
                      );
                      // Reload to refresh any stats
                      _loadChallenges();
                    },
                    onDelete: () => _deleteChallenge(challenge),
                  )).toList(),
                  
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
      ),
    );
  }
}

// Challenge card widget
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChallengeCard({super.key, 
    required this.challenge,
    required this.onTap,
    required this.onDelete,
  });

  Color get difficultyColor {
    switch (challenge.difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.yellow;
      case 'Hard':
        return Colors.orange;
      case 'Extreme':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isDefaultChallenge {
    final defaultIds = getDefaultChallenges().map((c) => c.id).toList();
    return defaultIds.contains(challenge.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[800]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(challenge.color),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flashlight_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title and category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              challenge.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: difficultyColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          challenge.difficulty,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    challenge.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Info row
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        challenge.durationMin < 60 ? "${challenge.durationMin}m" : "${(challenge.durationMin / 60).toStringAsFixed(1)}h",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.flashlight_on, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.defaultConfig.minFlashes}-${challenge.defaultConfig.maxFlashes} flashes',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const Spacer(),
                      if (!isDefaultChallenge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: const Text(
                            'CUSTOM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Delete button for custom challenges
            if (!isDefaultChallenge)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}