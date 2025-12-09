import 'package:shared_preferences/shared_preferences.dart';

// Service to manage app settings
class SettingsService {
  static const String _alarmEnabledKey = 'alarm_enabled';
  static const String _alarmTypeKey = 'alarm_type';
  static const String _alarmVolumeKey = 'alarm_volume';
  
  // Save alarm enabled status
  Future<void> setAlarmEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmEnabledKey, enabled);
  }
  
  // Get alarm enabled status
  Future<bool> getAlarmEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alarmEnabledKey) ?? true; // Default: enabled
  }
  
  // Save alarm type
  Future<void> setAlarmType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmTypeKey, type);
  }
  
  // Get alarm type
  Future<String> getAlarmType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_alarmTypeKey) ?? 'bell'; // Default: bell
  }
  
  // Save alarm volume
  Future<void> setAlarmVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_alarmVolumeKey, volume);
  }
  
  // Get alarm volume
  Future<double> getAlarmVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_alarmVolumeKey) ?? 1.0; // Default: full volume
  }
}