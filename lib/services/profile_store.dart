import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _prefix = 'airmail.profile_avatar.';
  final Map<String, String> _avatars = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
      for (final k in keys) {
        final userId = k.substring(_prefix.length);
        final val = prefs.getString(k);
        if (val != null && val.isNotEmpty) {
          _avatars[userId] = val;
        }
      }
      _initialized = true;
      notifyListeners();
    } catch (_) {}
  }

  String? getAvatar(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    return _avatars[userId];
  }

  Future<void> setAvatar(String userId, String? avatarData) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (avatarData == null || avatarData.isEmpty) {
      _avatars.remove(userId);
      await prefs.remove('$_prefix$userId');
    } else {
      _avatars[userId] = avatarData;
      await prefs.setString('$_prefix$userId', avatarData);
    }
    notifyListeners();
  }
}
