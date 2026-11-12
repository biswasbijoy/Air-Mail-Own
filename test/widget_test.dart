import 'package:airmail/Model/call_event.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/Screens/login_screen.dart';
import 'package:airmail/main.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the sign-in screen when no session is saved',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('switches between sign-in and registration',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create a new account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  test('session is persisted and cleared', () async {
    const session = Session(
      token: 'token-123',
      userId: 'user-1',
      name: 'Test User',
      email: 'test@example.com',
    );

    await SessionStore.save(session);
    final loaded = await SessionStore.load();

    expect(loaded, isNotNull);
    expect(loaded!.token, 'token-123');
    expect(loaded.userId, 'user-1');
    expect(loaded.name, 'Test User');
    expect(loaded.email, 'test@example.com');

    await SessionStore.clear();
    expect(await SessionStore.load(), isNull);
  });

  test('parses chat and message payloads from the API', () {
    final chat = ChatModel.fromChatJson({
      'user': {'id': 'user-2', 'name': 'Other', 'email': 'other@example.com'},
      'lastMessage': 'Hello',
      'lastMessageAt': '2026-01-01T10:00:00.000Z',
    });

    expect(chat.id, 'user-2');
    expect(chat.name, 'Other');
    expect(chat.currentMessage, 'Hello');
    expect(chat.lastMessageAt, isNotNull);
    expect(chat.status, 'offline');
    expect(chat.unreadCount, 0);

    final unreadChat = ChatModel.fromChatJson({
      'user': {'id': 'user-3', 'name': 'Unread', 'email': 'unread@example.com'},
      'lastMessage': 'Ping',
      'lastMessageAt': '2026-01-01T10:00:00.000Z',
      'unreadCount': 4,
    });

    expect(unreadChat.unreadCount, 4);

    final message = MessageModel.fromJson({
      '_id': 'message-1',
      'sender': 'user-1',
      'receiver': 'user-2',
      'message': 'Hi',
      'createdAt': '2026-01-01T10:00:00.000Z',
    });

    expect(message.id, 'message-1');
    expect(message.senderId, 'user-1');
    expect(message.receiverId, 'user-2');
    expect(message.message, 'Hi');
  });

  test('parses online status and tracks presence updates', () {
    final onlineUser = ChatModel.fromUserJson({
      'id': 'user-3',
      'name': 'Online User',
      'email': 'online@example.com',
      'online': true,
    });

    expect(onlineUser.status, 'online');

    final realtime = RealtimeService.instance;
    realtime.disconnect();
    addTearDown(realtime.disconnect);

    realtime.updateOnlineStatuses([
      onlineUser,
      ChatModel(id: 'user-4', status: 'offline'),
    ]);

    expect(realtime.isOnline('user-3'), isTrue);
    expect(realtime.isOnline('user-4'), isFalse);

    realtime.updateOnlineStatuses([
      ChatModel(id: 'user-3', status: 'offline'),
    ]);
    expect(realtime.isOnline('user-3'), isFalse);

    realtime.typingUsers.value = {'user-5'};
    expect(realtime.isTyping('user-5'), isTrue);
    realtime.disconnect();
    expect(realtime.isTyping('user-5'), isFalse);
  });

  test('parses incoming, accepted, ended, and WebRTC call events', () {
    final incoming = CallEvent.fromSocketEvent('call_incoming', {
      'callId': 'call-1',
      'callType': 'audio',
      'caller': {
        'id': 'user-2',
        'name': 'Caller',
        'email': 'caller@example.com',
      },
    });

    expect(incoming, isNotNull);
    expect(incoming!.type, CallEventType.incoming);
    expect(incoming.callId, 'call-1');
    expect(incoming.peer?.id, 'user-2');
    expect(incoming.peer?.name, 'Caller');

    final accepted = CallEvent.fromSocketEvent('call_accepted', {
      'callId': 'call-1',
      'callType': 'audio',
    });
    expect(accepted?.type, CallEventType.accepted);

    final ended = CallEvent.fromSocketEvent('call_ended', {
      'callId': 'call-1',
      'reason': 'Declined',
    });
    expect(ended?.type, CallEventType.ended);
    expect(ended?.reason, 'Declined');

    final signal = CallEvent.fromSocketEvent('webrtc_signal', {
      'callId': 'call-1',
      'from': 'user-2',
      'data': {'type': 'offer', 'sdp': 'test-offer'},
    });
    expect(signal?.type, CallEventType.signal);
    expect(signal?.from, 'user-2');
    expect(signal?.data?['type'], 'offer');
    expect(signal?.data?['sdp'], 'test-offer');

    expect(
      CallEvent.fromSocketEvent('call_incoming', {'callId': '', 'caller': {}}),
      isNull,
    );
  });
}
