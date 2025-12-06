import 'package:flutter/material.dart';
import '../models/challenge.dart';
import 'checklist_screen.dart';

// Detail screen showing challenge info and configuration
class DetailScreen extends StatefulWidget {
  final Challenge challenge;

  const DetailScreen({super.key, required this.challenge});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late ChallengeConfig config;
  bool agreedToSafety = false;
  bool showRules = false;

  @override
  void initState() {
    super.initState();
    config = widget.challenge.defaultConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Details'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Challenge icon and title
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Color(widget.challenge.color),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.flashlight_on, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.challenge.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.challenge.category,
                        style: const TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              widget.challenge.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[300], height: 1.5),
            ),
            const SizedBox(height: 24),

            // Detailed Rules (expandable)
            if (widget.challenge.detailedRules.isNotEmpty)
              Card(
                child: InkWell(
                  onTap: () => setState(() => showRules = !showRules),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '📋 Detailed Rules',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(showRules ? Icons.expand_less : Icons.expand_more),
                          ],
                        ),
                        if (showRules) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.challenge.detailedRules,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Safety Warning
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[900]!.withOpacity(0.3),
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        '⚠️ SAFETY WARNING',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.challenge.safetyText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: agreedToSafety,
                          onChanged: (value) {
                            setState(() => agreedToSafety = value!);
                          },
                          activeColor: Colors.red,
                        ),
                        const Expanded(
                          child: Text(
                            'I have read all safety warnings, understand the risks, and agree to stop immediately if I feel unwell.',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.settings, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Session Configuration',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Duration
                    _buildConfigSlider(
                      label: 'Duration (minutes)',
                      value: config.durationMin.toDouble(),
                      min: 1,
                      max: 180,
                      divisions: 179,
                      onChanged: (value) {
                        setState(() {
                          config = config.copyWith(durationMin: value.toInt());
                        });
                      },
                    ),

                    // Min Flashes
                    _buildConfigSlider(
                      label: 'Min Flash Count',
                      value: config.minFlashes.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (value) {
                        setState(() {
                          config = config.copyWith(minFlashes: value.toInt());
                        });
                      },
                    ),

                    // Max Flashes
                    _buildConfigSlider(
                      label: 'Max Flash Count',
                      value: config.maxFlashes.toDouble(),
                      min: config.minFlashes.toDouble(),
                      max: 50,
                      divisions: 50 - config.minFlashes,
                      onChanged: (value) {
                        setState(() {
                          config = config.copyWith(maxFlashes: value.toInt());
                        });
                      },
                    ),

                    // Flash Duration
                    _buildConfigSlider(
                      label: 'Flash Duration (ms)',
                      value: config.flashMs.toDouble(),
                      min: 500,
                      max: 3000,
                      divisions: 25,
                      onChanged: (value) {
                        setState(() {
                          config = config.copyWith(flashMs: value.toInt());
                        });
                      },
                    ),

                    // Alert Mode
                    const SizedBox(height: 16),
                    const Text('Alert Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'silent', label: Text('Silent')),
                        ButtonSegment(value: 'vibrate', label: Text('Vibrate')),
                      ],
                      selected: {config.silentMode},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          config = config.copyWith(silentMode: newSelection.first);
                        });
                      },
                    ),

                    // Headless Mode
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Headless Mode'),
                      subtitle: const Text('Hide UI during session'),
                      value: config.headlessMode,
                      onChanged: (value) {
                        setState(() {
                          config = config.copyWith(headlessMode: value);
                        });
                      },
                      activeThumbColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Start Button
            ElevatedButton(
              onPressed: agreedToSafety
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChecklistScreen(
                            challenge: widget.challenge,
                            config: config,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: agreedToSafety ? Colors.orange : Colors.grey,
              ),
              child: Text(
                agreedToSafety
                    ? '→ Proceed to Safety Checklist'
                    : '⚠️ Accept Safety Agreement First',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Colors.orange,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}