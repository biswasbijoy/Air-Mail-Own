import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedMessage {
  final String id;
  final String text;
  final DateTime createdAt;

  const SavedMessage({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedMessage.fromJson(Map<String, dynamic> json) => SavedMessage(
        id: json['id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class SavedMessagesStore extends ChangeNotifier {
  SavedMessagesStore._();
  static final SavedMessagesStore instance = SavedMessagesStore._();

  static const _prefix = 'airmail.saved_messages.';

  List<SavedMessage> _messages = [];
  bool _loading = false;

  List<SavedMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;

  Future<void> load(String userId) async {
    _loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$userId');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _messages = decoded
              .whereType<Map>()
              .map((item) =>
                  SavedMessage.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      } else {
        _messages = [];
      }
    } catch (_) {
      _messages = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<SavedMessage> add(String userId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw ArgumentError('Message cannot be empty');

    final msg = SavedMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_messages.length}',
      text: trimmed,
      createdAt: DateTime.now(),
    );

    _messages.insert(0, msg);
    notifyListeners();

    await _persist(userId);
    return msg;
  }

  Future<void> remove(String userId, String id) async {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
    await _persist(userId);
  }

  Future<void> clear(String userId) async {
    _messages.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$userId');
  }

  Future<void> _persist(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString('$_prefix$userId', encoded);
    } catch (_) {}
  }
}
