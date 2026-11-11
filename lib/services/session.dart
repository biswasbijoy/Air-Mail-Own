import 'package:shared_preferences/shared_preferences.dart';

class Session {
  const Session({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  final String token;
  final String userId;
  final String name;
  final String email;
}

class SessionStore {
  SessionStore._();

  static const _tokenKey = 'airmail.token';
  static const _userIdKey = 'airmail.userId';
  static const _nameKey = 'airmail.name';
  static const _emailKey = 'airmail.email';

  static Future<Session?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getString(_userIdKey);

    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return null;
    }

    return Session(
      token: token,
      userId: userId,
      name: prefs.getString(_nameKey) ?? '',
      email: prefs.getString(_emailKey) ?? '',
    );
  }

  static Future<void> save(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_userIdKey, session.userId);
    await prefs.setString(_nameKey, session.name);
    await prefs.setString(_emailKey, session.email);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }
}
