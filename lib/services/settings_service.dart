import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  static const String _prefNotifications = 'settings_notifications';
  static const String _prefSound = 'settings_sound';
  static const String _prefVibrate = 'settings_vibrate';
  static const String _prefEnterIsSend = 'settings_enter_is_send';

  bool _notifications = true;
  bool _sound = true;
  bool _vibrate = true;
  bool _enterIsSend = false;
  bool _loaded = false;

  bool get notifications => _notifications;
  bool get sound => _sound;
  bool get vibrate => _vibrate;
  bool get enterIsSend => _enterIsSend;
  bool get isLoaded => _loaded;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notifications = prefs.getBool(_prefNotifications) ?? true;
      _sound = prefs.getBool(_prefSound) ?? true;
      _vibrate = prefs.getBool(_prefVibrate) ?? true;
      _enterIsSend = prefs.getBool(_prefEnterIsSend) ?? false;
      _loaded = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefNotifications, value);
    } catch (_) {}
  }

  Future<void> setSound(bool value) async {
    _sound = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefSound, value);
    } catch (_) {}
  }

  Future<void> setVibrate(bool value) async {
    _vibrate = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefVibrate, value);
    } catch (_) {}
  }

  Future<void> setEnterIsSend(bool value) async {
    _enterIsSend = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnterIsSend, value);
    } catch (_) {}
  }
}
