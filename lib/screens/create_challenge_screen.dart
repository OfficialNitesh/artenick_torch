import 'package:flutter/material.dart';
import '../models/challenge.dart';

// Screen to create custom challenges
class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  _CreateChallengeScreenState createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _detailedRulesController = TextEditingController();
  final _safetyTextController = TextEditingController();
  
  String _difficulty = 'Medium';
  int _durationMin = 30;
  int _minFlashes = 3;
  int _maxFlashes = 6;
  int _flashMs = 1000;
  String _silentMode = 'vibrate';
  bool _headlessMode = false;
  int _minGapMin = 2;
  int _selectedColor = 0xFF2563EB; // Blue default

  final List<int> colors = [
    0xFF2563EB, // Blue
    0xFFDC2626, // Red
    0xFF7C3AED, // Purple
    0xFF0891B2, // Cyan
    0xFF16A34A, // Green
    0xFFEA580C, // Orange
    0xFFDB2777, // Pink
    0xFFA855F7, // Violet
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _detailedRulesController.dispose();
    _safetyTextController.dispose();
    super.dispose();
  }

  void _saveChallenge() {
    if (_formKey.currentState!.validate()) {
      final newChallenge = Challenge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        difficulty: _difficulty,
        durationMin: _durationMin,
        description: _descriptionController.text.trim(),
        detailedRules: _detailedRulesController.text.trim(),
        safetyText: _safetyTextController.text.trim(),
        defaultConfig: ChallengeConfig(
          durationMin: _durationMin,
          minFlashes: _minFlashes,
          maxFlashes: _maxFlashes,
          flashMs: _flashMs,
          silentMode: _silentMode,
          headlessMode: _headlessMode,
          minGapMin: _minGapMin,
        ),
        color: _selectedColor,
      );

      // Return the challenge to previous screen
      Navigator.pop(context, newChallenge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Challenge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChallenge,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title
              const Text(
                'Create New Challenge',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Challenge Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Challenge Title *',
                  hintText: 'e.g., Desert Survival Protocol',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black38,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  hintText: 'e.g., Endurance, Mental, Physical',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black38,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Short Description *',
                  hintText: 'Brief overview of the challenge',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black38,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Detailed Rules
              TextFormField(
                controller: _detailedRulesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Detailed Rules (Optional)',
                  hintText: 'Position requirements, failure conditions, etc.',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black38,
                ),
              ),
              const SizedBox(height: 16),

              // Safety Text
              TextFormField(
                controller: _safetyTextController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Safety Warning *',
                  hintText: 'Medical contraindications, risks, emergency protocol',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.red.withOpacity(0.1),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Safety warning is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Difficulty
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Difficulty Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Easy', label: Text('Easy')),
                          ButtonSegment(value: 'Medium', label: Text('Medium')),
                          ButtonSegment(value: 'Hard', label: Text('Hard')),
                          ButtonSegment(value: 'Extreme', label: Text('Extreme')),
                        ],
                        selected: {_difficulty},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _difficulty = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Duration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Duration (minutes)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$_durationMin min',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _durationMin.toDouble(),
                        min: 1,
                        max: 180,
                        divisions: 179,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _durationMin = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Flash Configuration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flash Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Min Flashes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Min Flashes'),
                          Text(
                            '$_minFlashes',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _minFlashes.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _minFlashes = value.toInt();
                            if (_maxFlashes < _minFlashes) {
                              _maxFlashes = _minFlashes;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Max Flashes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Max Flashes'),
                          Text(
                            '$_maxFlashes',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _maxFlashes.toDouble(),
                        min: _minFlashes.toDouble(),
                        max: 50,
                        divisions: 50 - _minFlashes,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _maxFlashes = value.toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Flash Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Flash Duration (ms)'),
                          Text(
                            '$_flashMs ms',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _flashMs.toDouble(),
                        min: 500,
                        max: 3000,
                        divisions: 25,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _flashMs = value.toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Min Gap
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Min Gap (minutes)'),
                          Text(
                            '$_minGapMin min',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _minGapMin.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            _minGapMin = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Alert Mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alert Mode',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'silent', label: Text('Silent')),
                          ButtonSegment(value: 'vibrate', label: Text('Vibrate')),
                        ],
                        selected: {_silentMode},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _silentMode = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Headless Mode'),
                        subtitle: const Text('Hide UI during session'),
                        value: _headlessMode,
                        onChanged: (value) {
                          setState(() {
                            _headlessMode = value;
                          });
                        },
                        activeThumbColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Challenge Color',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: colors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(color),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveChallenge,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Create Challenge',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}