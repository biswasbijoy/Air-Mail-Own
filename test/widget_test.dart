import 'dart:convert';
import 'package:airmail/Games/Ludo/ludo_board.dart';
import 'package:airmail/Games/Ludo/ludo_dice.dart';
import 'package:airmail/Games/Ludo/ludo_game.dart';
import 'package:airmail/Games/Ludo/ludo_models.dart';
import 'package:airmail/Model/call_event.dart';
import 'package:airmail/Model/call_record_model.dart';
import 'package:airmail/Model/chat_model.dart';
import 'package:airmail/Model/message_model.dart';
import 'package:airmail/Screens/game_screen.dart';
import 'package:airmail/Screens/login_screen.dart';
import 'package:airmail/Screens/select_contact_page.dart';
import 'package:airmail/Screens/settings_screen.dart';
import 'package:airmail/main.dart';
import 'package:airmail/services/api_service.dart';
import 'package:airmail/services/call_history_store.dart';
import 'package:airmail/services/realtime_service.dart';
import 'package:airmail/services/session.dart';
import 'package:airmail/services/settings_service.dart';
import 'package:airmail/services/share_service.dart';
import 'package:airmail/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeController.instance.resetForTesting();
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

  test('persists and restores theme mode', () async {
    expect(ThemeController.instance.themeMode, ThemeMode.system);

    await ThemeController.instance.setThemeMode(ThemeMode.dark);
    expect(ThemeController.instance.themeMode, ThemeMode.dark);

    // Reset in-memory instance and reload from SharedPreferences
    ThemeController.instance.resetForTesting();
    expect(ThemeController.instance.themeMode, ThemeMode.system);

    await ThemeController.instance.loadThemeMode();
    expect(ThemeController.instance.themeMode, ThemeMode.dark);

    await ThemeController.instance.setThemeMode(ThemeMode.light);
    ThemeController.instance.resetForTesting();
    await ThemeController.instance.loadThemeMode();
    expect(ThemeController.instance.themeMode, ThemeMode.light);
  });

  testWidgets('toggling theme updates MaterialApp themeMode',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);

    await ThemeController.instance.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await ThemeController.instance.setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();

    app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
  });

  testWidgets('drawer theme button toggles application theme',
      (WidgetTester tester) async {
    const session = Session(
      token: 'token-123',
      userId: 'user-1',
      name: 'Test User',
      email: 'test@example.com',
    );
    await SessionStore.save(session);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Open drawer
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Verify theme button is present in light/system mode
    final themeButton = find.byTooltip('Switch to dark theme');
    expect(themeButton, findsOneWidget);

    // Tap theme button to switch to dark theme
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    expect(ThemeController.instance.themeMode, ThemeMode.dark);
    MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    // Now button tooltip should update to 'Switch to light theme'
    final lightThemeButton = find.byTooltip('Switch to light theme');
    expect(lightThemeButton, findsOneWidget);

    // Tap theme button to switch back to light theme
    await tester.tap(lightThemeButton);
    await tester.pumpAndSettle();

    expect(ThemeController.instance.themeMode, ThemeMode.light);
    app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
  });

  test('ApiService.fetchIceServers parses ice servers from response', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/ice-servers') {
        return http.Response(
          jsonEncode({
            'iceServers': [
              {
                'urls': ['stun:test.stun.org:19302'],
              },
              {
                'urls': ['turn:test.turn.org:3478'],
                'username': 'user',
                'credential': 'pwd',
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });

    final servers = await ApiService.fetchIceServers(client: mockClient);
    expect(servers, isNotNull);
    expect(servers!.length, 2);
    expect(servers[0]['urls'], ['stun:test.stun.org:19302']);
    expect(servers[1]['username'], 'user');
  });

  test('ApiService.fetchIceServers returns null on error', () async {
    final mockClient = MockClient((request) async {
      return http.Response('Server Error', 500);
    });

    final servers = await ApiService.fetchIceServers(client: mockClient);
    expect(servers, isNull);
  });

  test('CallRecordModel parses json and serializes correctly', () {
    final json = {
      'id': 'call-rec-1',
      'peer': {
        'id': 'peer-1',
        'name': 'Alice',
        'email': 'alice@example.com',
        'online': true,
      },
      'direction': 'incoming',
      'status': 'completed',
      'duration': 42,
      'createdAt': '2026-03-30T10:00:00.000Z',
    };

    final record = CallRecordModel.fromJson(json);
    expect(record.id, 'call-rec-1');
    expect(record.peer.id, 'peer-1');
    expect(record.peer.name, 'Alice');
    expect(record.direction, CallDirection.incoming);
    expect(record.status, CallStatus.completed);
    expect(record.duration, 42);

    final serialized = record.toJson();
    expect(serialized['id'], 'call-rec-1');
    expect(serialized['direction'], 'incoming');
    expect(serialized['status'], 'completed');
    expect(serialized['duration'], 42);
  });

  test('CallHistoryStore saves, loads, and manages records per user', () async {
    const userId = 'user-call-store-test';
    final record1 = CallRecordModel(
      id: 'call-1',
      peer: ChatModel(
        id: 'peer-1',
        name: 'Bob',
        email: 'bob@example.com',
        status: 'online',
      ),
      direction: CallDirection.outgoing,
      status: CallStatus.missed,
      duration: 0,
      createdAt: DateTime.now(),
    );

    final record2 = CallRecordModel(
      id: 'call-2',
      peer: ChatModel(
        id: 'peer-2',
        name: 'Charlie',
        email: 'charlie@example.com',
        status: 'offline',
      ),
      direction: CallDirection.incoming,
      status: CallStatus.completed,
      duration: 120,
      createdAt: DateTime.now(),
    );

    await CallHistoryStore.addRecord(userId, record1);
    await CallHistoryStore.addRecord(userId, record2);

    final loaded = await CallHistoryStore.load(userId);
    expect(loaded.length, 2);
    // Most recent saved should be first
    expect(loaded.first.id, 'call-2');
    expect(loaded.last.id, 'call-1');

    await CallHistoryStore.clear(userId);
    final cleared = await CallHistoryStore.load(userId);
    expect(cleared, isEmpty);
  });

  test('SettingsService loads and persists preferences', () async {
    final settings = SettingsService.instance;
    await settings.loadSettings();

    expect(settings.notifications, isTrue);
    expect(settings.sound, isTrue);
    expect(settings.vibrate, isTrue);
    expect(settings.enterIsSend, isFalse);

    await settings.setNotifications(false);
    await settings.setSound(false);
    await settings.setEnterIsSend(true);

    expect(settings.notifications, isFalse);
    expect(settings.sound, isFalse);
    expect(settings.enterIsSend, isTrue);

    // Re-instantiate / reload
    await settings.loadSettings();
    expect(settings.notifications, isFalse);
    expect(settings.sound, isFalse);
    expect(settings.enterIsSend, isTrue);
  });

  testWidgets('SettingsScreen displays session info and controls',
      (WidgetTester tester) async {
    const session = Session(
      token: 'test-token',
      userId: 'user-settings-test',
      name: 'Settings Tester',
      email: 'settings@example.com',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(session: session),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings Tester'), findsOneWidget);
    expect(find.text('settings@example.com'), findsOneWidget);
    expect(find.text('Message notifications'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Send with Enter key'), 100);
    expect(find.text('Send with Enter key'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Clear call history'), 100);
    expect(find.text('Clear call history'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Log out of AirMail'), 100);
    expect(find.text('Log out of AirMail'), findsOneWidget);
  });

  test('ShareService formats invitation message correctly', () {
    const session = Session(
      token: 'tok',
      userId: 'u1',
      name: 'Alice',
      email: 'alice@example.com',
    );

    final msg = ShareService.inviteMessage(session);
    expect(msg, contains('Alice invited you to join AirMail'));
    expect(msg, contains('alice@example.com'));
    expect(msg, contains('https://github.com/biswasbijoy/Air-Mail-Own'));
  });

  testWidgets('ShareService.showInviteModal displays invitation preview',
      (WidgetTester tester) async {
    const session = Session(
      token: 'tok',
      userId: 'u1',
      name: 'Bob',
      email: 'bob@example.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ShareService.showInviteModal(context, session),
              child: const Text('Open Invite'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Invite'));
    await tester.pumpAndSettle();

    expect(find.text('Invite Friends'), findsOneWidget);
    expect(find.text('Share via Apps...'), findsOneWidget);
    expect(find.text('Copy invitation message'), findsOneWidget);
    expect(find.textContaining('Bob invited you to join AirMail'), findsOneWidget);
  });

  testWidgets('SelectContact renders New call title when forCall is true',
      (WidgetTester tester) async {
    const session = Session(
      token: 'tok',
      userId: 'u1',
      name: 'Bob',
      email: 'bob@example.com',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: SelectContact(
          session: session,
          embedded: false,
          forCall: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New call'), findsOneWidget);
  });

  test('LudoToken movement rules and board mapping', () {
    final token = LudoToken(id: 0, color: LudoPlayerColor.red);
    expect(token.isInYard, isTrue);
    expect(token.canMove(5), isFalse);
    expect(token.canMove(6), isTrue);

    // Unlock token
    token.step = 0;
    expect(token.isOnBoard, isTrue);
    expect(token.canMove(4), isTrue);

    // Near home
    token.step = 54;
    expect(token.canMove(3), isFalse); // 54 + 3 = 57 > 56
    expect(token.canMove(2), isTrue);  // 54 + 2 = 56 (Home)

    token.step = 56;
    expect(token.isHome, isTrue);
    expect(token.canMove(1), isFalse);

    expect(LudoConstants.circuit.length, 52);
    expect(LudoConstants.safePositions.length, 8);

    // Verify yard positions and exit tiles match each quadrant:
    // Red: Top-Left Yard -> exits to Red Start (6, 1)
    expect(LudoPlayerColor.red.yardSlots.first, const GridPos(1, 1));
    expect(LudoConstants.getTokenPosition(LudoToken(id: 0, color: LudoPlayerColor.red, step: 0)), const GridPos(6, 1));

    // Green: Top-Right Yard -> exits to Green Start (1, 8)
    expect(LudoPlayerColor.green.yardSlots.first, const GridPos(1, 10));
    expect(LudoConstants.getTokenPosition(LudoToken(id: 0, color: LudoPlayerColor.green, step: 0)), const GridPos(1, 8));

    // Yellow: Bottom-Right Yard -> exits to Yellow Start (8, 13)
    expect(LudoPlayerColor.yellow.yardSlots.first, const GridPos(10, 10));
    expect(LudoConstants.getTokenPosition(LudoToken(id: 0, color: LudoPlayerColor.yellow, step: 0)), const GridPos(8, 13));

    // Blue: Bottom-Left Yard -> exits to Blue Start (13, 6)
    expect(LudoPlayerColor.blue.yardSlots.first, const GridPos(10, 1));
    expect(LudoConstants.getTokenPosition(LudoToken(id: 0, color: LudoPlayerColor.blue, step: 0)), const GridPos(13, 6));
  });

  testWidgets('LudoGame renders board, dice, and turn card',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LudoGame(),
      ),
    );
    await tester.pump();

    expect(find.text('Ludo Multiplayer'), findsOneWidget);
    expect(find.text("Red's Turn"), findsOneWidget);
    expect(find.byType(LudoDice), findsOneWidget);
    expect(find.text('4 / 4 Home'), findsNothing); // 0/4 home initially
    expect(find.text('0 / 4 Home'), findsNWidgets(4));

    // Check player mode menu button is enabled before game starts
    final popupBeforeRoll = tester.widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>));
    expect(popupBeforeRoll.enabled, isTrue);

    // Tap dice to test rolling interaction
    await tester.tap(find.byType(LudoDice));
    await tester.pump();
    expect(find.text("Red is rolling..."), findsOneWidget);

    // Player mode menu button is disabled while game is running
    final popupDuringRoll = tester.widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>));
    expect(popupDuringRoll.enabled, isFalse);

    // Complete roll animation
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(seconds: 2));

    // Test Reset confirmation modal
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('Reset Game?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // Tap Cancel -> modal closes
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Reset Game?'), findsNothing);

    // Tap Reset icon again and confirm
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // After reset, player mode menu button is re-enabled
    final popupAfterReset = tester.widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>));
    expect(popupAfterReset.enabled, isTrue);
  });

  testWidgets('LudoBoard supports movingToken jump rendering with AnimatedPositioned and faded glowing',
      (WidgetTester tester) async {
    final token = LudoToken(id: 0, color: LudoPlayerColor.red, step: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LudoBoard(
            tokens: [token],
            movableTokens: {token},
            movingToken: token,
            onTokenTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AnimatedPositioned), findsWidgets);
    expect(find.byType(AnimatedBuilder), findsWidgets);

    // Pump a frame to test smooth glowing oscillation
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('GameScreen only shows Ludo Multiplayer and Tic Tac Toe',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GameScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Ludo Multiplayer'), findsOneWidget);
    expect(find.text('Tic Tac Toe'), findsOneWidget);
    expect(find.text('Rock Paper Scissors'), findsNothing);
    expect(find.text('Color Guess'), findsNothing);
  });
}
