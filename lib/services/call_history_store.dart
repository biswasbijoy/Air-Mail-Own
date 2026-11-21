import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Model/call_record_model.dart';

class CallHistoryStore {
  CallHistoryStore._();

  static const String _prefix = 'call_history_';

  static String _key(String? userId) => '$_prefix${userId ?? 'default'}';

  static Future<List<CallRecordModel>> load(String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list
          .whereType<Map>()
          .map((item) =>
              CallRecordModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(String? userId, List<CallRecordModel> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toSave = records.take(100).map((r) => r.toJson()).toList();
      await prefs.setString(_key(userId), jsonEncode(toSave));
    } catch (_) {}
  }

  static Future<void> addRecord(String? userId, CallRecordModel record) async {
    final existing = await load(userId);
    existing.removeWhere((r) => r.id == record.id && r.id.isNotEmpty);
    existing.insert(0, record);
    await save(userId, existing);
  }

  static Future<void> clear(String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(userId));
    } catch (_) {}
  }
}
