import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/alarm_service.dart';

// Settings screen for alarm customization
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final AlarmService _alarm = AlarmService();
  
  bool _alarmEnabled = true;
  String _alarmType = 'bell';
  double _alarmVolume = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _settings.getAlarmEnabled();
    final type = await _settings.getAlarmType();
    final volume = await _settings.getAlarmVolume();
    
    setState(() {
      _alarmEnabled = enabled;
      _alarmType = type;
      _alarmVolume = volume;
      _isLoading = false;
    });
  }

  Future<void> _updateAlarmEnabled(bool value) async {
    await _settings.setAlarmEnabled(value);
    setState(() => _alarmEnabled = value);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Completion alarm enabled' : 'Completion alarm disabled'),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _updateAlarmType(String value) async {
    await _settings.setAlarmType(value);
    setState(() => _alarmType = value);
    
    // Play preview
    _alarm.playPreview(value);
  }

  Future<void> _updateAlarmVolume(double value) async {
    await _settings.setAlarmVolume(value);
    setState(() => _alarmVolume = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your Artenick experience',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 32),

                  // Completion Alarm Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.alarm, color: Colors.orange),
                              SizedBox(width: 12),
                              Text(
                                'Completion Alarm',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Play alarm sound when session completes',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Enable/Disable Alarm
                          SwitchListTile(
                            title: const Text('Enable Completion Alarm'),
                            subtitle: Text(
                              _alarmEnabled 
                                  ? 'Alarm will play when timer ends'
                                  : 'No alarm will play',
                              style: const TextStyle(fontSize: 12),
                            ),
                            value: _alarmEnabled,
                            onChanged: _updateAlarmEnabled,
                            activeThumbColor: Colors.orange,
                          ),

                          if (_alarmEnabled) ...[
                            const Divider(),
                            const SizedBox(height: 16),

                            // Alarm Type Selection
                            const Text(
                              'Alarm Sound',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ...AlarmService.alarmSounds.entries.map((entry) {
                              return RadioListTile<String>(
                                title: Text(entry.value),
                                subtitle: Text(
                                  'Tap to preview',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                                value: entry.key,
                                groupValue: _alarmType,
                                onChanged: (value) {
                                  if (value != null) _updateAlarmType(value);
                                },
                                activeColor: Colors.orange,
                              );
                            }).toList(),

                            const Divider(),
                            const SizedBox(height: 16),

                            // Volume Control
                            const Text(
                              'Alarm Volume',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Icon(Icons.volume_down, color: Colors.grey[400]),
                                Expanded(
                                  child: Slider(
                                    value: _alarmVolume,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    activeColor: Colors.orange,
                                    onChanged: _updateAlarmVolume,
                                  ),
                                ),
                                const Icon(Icons.volume_up, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  '${(_alarmVolume * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Test Alarm Button
                            ElevatedButton.icon(
                              onPressed: () => _alarm.playPreview(_alarmType),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Test Alarm'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Info Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: 12),
                              Text(
                                'About Artenick',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('App Name', 'Artenick'),
                          _buildInfoRow('Version', '1.0.0'),
                          _buildInfoRow('Build', 'Release'),
                          const SizedBox(height: 12),
                          Text(
                            'A torch-controlled discipline training app for building mental resilience and physical endurance.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _alarm.dispose();
    super.dispose();
  }
}