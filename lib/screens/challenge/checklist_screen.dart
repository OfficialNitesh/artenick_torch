import 'package:flutter/material.dart';
import '../models/challenge.dart';
import 'session_screen.dart';

// Pre-session safety checklist
class ChecklistScreen extends StatefulWidget {
  final Challenge challenge;
  final ChallengeConfig config;

  const ChecklistScreen({super.key, 
    required this.challenge,
    required this.config,
  });

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  Map<String, bool> checks = {
    'brightness': false,
    'charger': false,
    'emergency': false,
    'weapon': false,
    'position': false,
    'testRun': false,
    'placement': false,
    'health': false,
  };

  bool get allChecked => checks.values.every((v) => v);

  final List<CheckItem> checkItems = [
    CheckItem(
      key: 'brightness',
      icon: '🔆',
      label: 'Phone brightness set to MAXIMUM',
    ),
    CheckItem(
      key: 'charger',
      icon: '🔌',
      label: 'Phone connected to charger / power bank',
    ),
    CheckItem(
      key: 'emergency',
      icon: '📞',
      label: 'Emergency contact is AWARE and available',
    ),
    CheckItem(
      key: 'weapon',
      icon: '🔫',
      label: 'Weapon prop verified SAFE (unloaded, slide not racked)',
    ),
    CheckItem(
      key: 'position',
      icon: '🧘',
      label: 'Position tested and comfortable (stones/pens placed)',
    ),
    CheckItem(
      key: 'testRun',
      icon: '✅',
      label: 'Completed test run (2 minutes minimum)',
    ),
    CheckItem(
      key: 'placement',
      icon: '📱',
      label: 'Phone secured behind you, torch pointing at face area',
    ),
    CheckItem(
      key: 'health',
      icon: '❤️',
      label: 'Feel physically well, no chest pain, dizziness, or numbness',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Checklist'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[900]!.withOpacity(0.3),
                      border: Border.all(color: Colors.orange, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.shield, color: Colors.orange, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Pre-Session Safety Checklist',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Complete ALL items before starting. This ensures your safety and session quality.',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Checklist items
                  ...checkItems.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: checks[item.key],
                          onChanged: (value) {
                            setState(() {
                              checks[item.key] = value!;
                            });
                          },
                          activeColor: Colors.orange,
                          title: Row(
                            children: [
                              Text(
                                item.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),

                  const SizedBox(height: 16),

                  // Final warning
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[900]!.withOpacity(0.3),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🚨 Remember: Press PANIC at ANY time if you feel unwell. Safety comes first.',
                      style: TextStyle(
                        color: Colors.red[200],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: Colors.grey[800]!)),
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: allChecked
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionScreen(
                                challenge: widget.challenge,
                                config: widget.config,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: allChecked ? Colors.orange : Colors.grey,
                  ),
                  child: Text(
                    allChecked
                        ? '🚀 BEGIN SESSION'
                        : '⚠️ Complete All Checklist Items',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckItem {
  final String key;
  final String icon;
  final String label;

  CheckItem({
    required this.key,
    required this.icon,
    required this.label,
  });
}