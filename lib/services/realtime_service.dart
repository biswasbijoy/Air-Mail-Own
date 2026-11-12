import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../Model/call_event.dart';
import '../Model/chat_model.dart';
import '../Model/message_model.dart';
import 'api_service.dart';
import 'session.dart';

class RealtimeService {
  RealtimeService._();

  static final RealtimeService instance = RealtimeService._();

  final ValueNotifier<Set<String>> onlineUsers =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<Set<String>> typingUsers =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<bool> connected = ValueNotifier<bool>(false);
  final StreamController<MessageModel> _messages =
      StreamController<MessageModel>.broadcast();
  final StreamController<CallEvent> _callEvents =
      StreamController<CallEvent>.broadcast();
  final Map<String, Timer> _typingTimers = <String, Timer>{};

  io.Socket? _socket;
  String? _token;
  bool _hasPresence = false;

  Stream<MessageModel> get messages => _messages.stream;

  Stream<CallEvent> get callEvents => _callEvents.stream;

  bool get hasPresence => _hasPresence;

  bool get isConnected => _socket?.connected == true;

  bool isOnline(String? userId) {
    return userId != null && onlineUsers.value.contains(userId);
  }

  bool effectiveOnline(String? userId, {bool fallback = false}) {
    if (_hasPresence) return isOnline(userId);
    return fallback;
  }

  bool isTyping(String? userId) {
    return userId != null && typingUsers.value.contains(userId);
  }

  void sendTyping(String receiverId, bool typing) {
    _emit('typing', {'receiverId': receiverId, 'typing': typing});
  }

  Future<Map<String, dynamic>> inviteCall(String receiverId) {
    return _emitWithAck('call_invite', {
      'receiverId': receiverId,
      'callType': 'audio',
    });
  }

  Future<Map<String, dynamic>> acceptCall(String callId) {
    return _emitWithAck('call_accept', {'callId': callId});
  }

  Future<Map<String, dynamic>> rejectCall(String callId) {
    return _emitWithAck('call_reject', {'callId': callId});
  }

  void endCall(String callId) {
    _emit('call_end', {'callId': callId});
  }

  void sendCallSignal(String callId, Map<String, dynamic> data) {
    _emit('webrtc_signal', {'callId': callId, 'data': data});
  }

  void _emit(String event, Map<String, dynamic> data) {
    final socket = _socket;
    if (socket == null || !socket.connected) return;
    socket.emit(event, data);
  }

  Future<Map<String, dynamic>> _emitWithAck(
    String event,
    Map<String, dynamic> data,
  ) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      return Future<Map<String, dynamic>>.value({
        'ok': false,
        'error': 'You are not connected.',
      });
    }

    final completer = Completer<Map<String, dynamic>>();

    try {
      socket.emitWithAck(
        event,
        data,
        ack: (dynamic response) {
          if (completer.isCompleted) return;
          if (response is Map) {
            completer.complete(Map<String, dynamic>.from(response));
          } else {
            completer.complete({
              'ok': false,
              'error': 'Unexpected server response.',
            });
          }
        },
      );
    } catch (_) {
      return Future<Map<String, dynamic>>.value({
        'ok': false,
        'error': 'Could not reach the server.',
      });
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => {
        'ok': false,
        'error': 'The server did not respond in time.',
      },
    );
  }

  void _clearTyping() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    typingUsers.value = <String>{};
  }

  void _stopTypingFor(String userId) {
    _typingTimers.remove(userId)?.cancel();
    if (!typingUsers.value.contains(userId)) return;
    typingUsers.value = Set<String>.from(typingUsers.value)..remove(userId);
  }

  void _handleCallSocketEvent(String event, dynamic data) {
    if (data is! Map) return;
    final callEvent = CallEvent.fromSocketEvent(
      event,
      Map<String, dynamic>.from(data),
    );
    if (callEvent != null) {
      _callEvents.add(callEvent);
    }
  }

  void updateOnlineStatuses(Iterable<ChatModel> users) {
    final next = Set<String>.from(onlineUsers.value);
    var changed = false;

    for (final user in users) {
      final id = user.id;
      if (id == null || id.isEmpty) continue;

      if (user.status == 'online') {
        changed = next.add(id) || changed;
      } else {
        changed = next.remove(id) || changed;
      }
    }

    _hasPresence = true;
    if (changed) {
      onlineUsers.value = next;
    }
  }

  void connect(Session session) {
    if (_token == session.token && _socket != null) {
      if (!_socket!.connected) {
        _socket!.connect();
      }
      return;
    }

    disconnect();
    _token = session.token;

    final socket = io.io(
      ApiService.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': session.token})
          .build(),
    );

    socket.on('presence_state', (data) {
      if (data is! Map) return;
      final online = data['online'];
      if (online is! List) return;

      _hasPresence = true;
      onlineUsers.value = online.map((id) => id.toString()).toSet();
    });

    socket.on('presence', (data) {
      if (data is! Map) return;
      final userId = data['userId']?.toString();
      if (userId == null || userId.isEmpty) return;

      final next = Set<String>.from(onlineUsers.value);
      if (data['online'] == true) {
        next.add(userId);
      } else {
        next.remove(userId);
        _stopTypingFor(userId);
      }

      _hasPresence = true;
      onlineUsers.value = next;
    });

    socket.onConnect((_) {
      connected.value = true;
    });

    socket.on('typing', (data) {
      if (data is! Map) return;
      final userId = data['userId']?.toString();
      if (userId == null || userId.isEmpty) return;

      final typing = data['typing'] == true;
      _typingTimers.remove(userId)?.cancel();

      final next = Set<String>.from(typingUsers.value);
      if (typing) {
        next.add(userId);
        _typingTimers[userId] = Timer(const Duration(seconds: 4), () {
          _typingTimers.remove(userId);
          if (!typingUsers.value.contains(userId)) return;
          typingUsers.value = Set<String>.from(typingUsers.value)
            ..remove(userId);
        });
      } else {
        next.remove(userId);
      }
      typingUsers.value = next;
    });

    socket.on('call_incoming', (data) {
      _handleCallSocketEvent('call_incoming', data);
    });

    socket.on('call_accepted', (data) {
      _handleCallSocketEvent('call_accepted', data);
    });

    socket.on('call_ended', (data) {
      _handleCallSocketEvent('call_ended', data);
    });

    socket.on('webrtc_signal', (data) {
      _handleCallSocketEvent('webrtc_signal', data);
    });

    socket.on('new_message', (data) {
      if (data is! Map) return;
      final message = MessageModel.fromJson(Map<String, dynamic>.from(data));
      _stopTypingFor(message.senderId);
      _messages.add(message);
    });

    socket.onDisconnect((_) {
      connected.value = false;
      _hasPresence = true;
      onlineUsers.value = <String>{};
      _clearTyping();
    });

    socket.onConnectError((_) {
      connected.value = false;
    });
    socket.onError((_) {});

    _socket = socket;
    socket.connect();
  }

  void disconnect() {
    connected.value = false;
    _socket?.dispose();
    _socket = null;
    _token = null;
    _hasPresence = false;
    onlineUsers.value = <String>{};
    _clearTyping();
  }
}
