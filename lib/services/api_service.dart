import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/chat_model.dart';
import '../Model/message_model.dart';
import 'session.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ContactLookup {
  const ContactLookup({required this.user, required this.isContact});

  final ChatModel user;
  final bool isContact;
}

class ApiService {
  ApiService({required this.token});

  static const String baseUrl = String.fromEnvironment(
    'AIRMAIL_API_URL',
    defaultValue: 'https://airmail-backend.onrender.com',
  );

  static const Duration _timeout = Duration(seconds: 20);

  final String token;

  static Future<Session> login({
    required String email,
    required String password,
  }) {
    return _authenticate('/api/auth/login', {
      'email': email,
      'password': password,
    });
  }

  static Future<Session> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<Session> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    final data = await _send(
      () => http.post(
        Uri.parse('$baseUrl$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );

    if (data is! Map) {
      throw const ApiException('Unexpected server response');
    }

    final map = Map<String, dynamic>.from(data);
    final user = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : const <String, dynamic>{};
    final token = map['token']?.toString() ?? '';
    final userId = (user['id'] ?? user['_id'])?.toString() ?? '';

    if (token.isEmpty || userId.isEmpty) {
      throw const ApiException('Unexpected server response');
    }

    return Session(
      token: token,
      userId: userId,
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
    );
  }

  Future<List<ChatModel>> fetchChats() async {
    final data = await _get('/api/chats');
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => ChatModel.fromChatJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ChatModel>> fetchContacts() async {
    final data = await _get('/api/contacts');
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => ChatModel.fromUserJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ContactLookup> searchContact(String email) async {
    final data = await _get(
      '/api/contacts/search?email=${Uri.encodeQueryComponent(email)}',
    );
    if (data is! Map) {
      throw const ApiException('Unexpected server response');
    }

    final map = Map<String, dynamic>.from(data);
    final user = map['user'];
    if (user is! Map) {
      throw const ApiException('Unexpected server response');
    }

    return ContactLookup(
      user: ChatModel.fromUserJson(Map<String, dynamic>.from(user)),
      isContact: map['isContact'] == true,
    );
  }

  Future<ChatModel> addContact(String email) async {
    final data = await _post('/api/contacts', {'email': email});
    if (data is! Map) {
      throw const ApiException('Unexpected server response');
    }
    return ChatModel.fromUserJson(Map<String, dynamic>.from(data));
  }

  Future<bool> removeContact(String userId) async {
    final data = await _delete('/api/contacts/$userId');
    return data is Map && data['removed'] == true;
  }

  Future<void> markConversationRead(String userId) async {
    await _post('/api/messages/$userId/read', const {});
  }

  Future<List<MessageModel>> fetchMessages(String userId) async {
    final data = await _get('/api/messages/$userId');
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final data = await _post('/api/messages', {
      'receiverId': receiverId,
      'message': message,
    });

    if (data is! Map) {
      throw const ApiException('Unexpected server response');
    }
    return MessageModel.fromJson(Map<String, dynamic>.from(data));
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<dynamic> _get(String path) {
    return _send(
      () => http.get(Uri.parse('$baseUrl$path'), headers: _headers),
    );
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) {
    return _send(
      () => http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> _delete(String path) {
    return _send(
      () => http.delete(Uri.parse('$baseUrl$path'), headers: _headers),
    );
  }

  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      final data = _decode(response);

      if (response.statusCode == 401) {
        throw const ApiException('Session expired. Please sign in again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final message = data is Map ? data['message']?.toString() : null;
      throw ApiException(message ?? 'Request failed (${response.statusCode})');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } catch (_) {
      throw const ApiException(
          'Connection error. Check your network and try again.');
    }
  }

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }
}
