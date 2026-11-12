# AirMail Project Knowledge Base

## Project Overview
AirMail is a Flutter messaging app backed by Node.js/Express/MongoDB. It
supports JWT authentication, persisted sessions, per-user contacts added by
email (with removal), online/offline presence, typing indicators, unread
badges, conversation history, HTTP message sending, real-time delivery through
Socket.IO, and free 1:1 audio calls over WebRTC. The UI uses the Midnight Cyan
theme with automatic light/dark mode.

## Tech Stack

### Frontend
- Flutter 3.47.9 / Dart 3.13.7
- Material 3 (`useMaterial3: true`)
- HTTP (`package:http`) for REST calls
- Socket.IO client (`socket_io_client`) for real-time messages and call signaling
- `flutter_webrtc` for peer-to-peer audio media and microphone capture
- `shared_preferences` for session persistence
- `image_picker` for the camera demo screen
- Theme: `ThemeMode.system`; colors in `lib/theme/app_colors.dart`

### Backend
- Node.js 18+, Express 4, Mongoose 7
- MongoDB Atlas
- Socket.IO 4
- bcryptjs password hashing, JWT authentication
- Deployed on Render.com

### Required environment variables
`backend/.env.example` documents all values:

| Variable | Purpose |
|----------|---------|
| `MONGODB_URI` | MongoDB Atlas connection string (required) |
| `JWT_SECRET` | JWT signing secret (required, long random value) |
| `PORT` | Listen port; defaults to 5000 and respects Render's value |
| `CORS_ORIGIN` | Allowed origin, defaults to `*` |
| `JWT_EXPIRES_IN` | Token lifetime, defaults to `7d` |
| `CALL_RING_TIMEOUT_MS` | Ring timeout for unanswered calls, defaults to `45000` |

The server exits at startup when `MONGODB_URI` or `JWT_SECRET` is missing.

Optional Flutter build-time TURN configuration:

| Define | Purpose |
|--------|---------|
| `AIRMAIL_TURN_URL` | Comma-separated TURN URL(s), e.g. `turn:host:3478` |
| `AIRMAIL_TURN_USERNAME` | TURN username |
| `AIRMAIL_TURN_CREDENTIAL` | TURN credential |

STUN-only is used when these are omitted. Credentials compiled into an app can
be extracted, so production should use short-lived TURN credentials.

## Project Structure

```
air_mail/
├── lib/
│   ├── main.dart                  # App + SessionGate (auto-login)
│   ├── Model/
│   │   ├── chat_model.dart        # Contact/conversation model + JSON parsing
│   │   └── message_model.dart     # Message model + JSON parsing
│   ├── services/
│   │   ├── api_service.dart       # REST client, contacts, read state, errors
│   │   ├── realtime_service.dart  # Socket.IO presence, typing, messages
│   │   └── session.dart           # SharedPreferences session store
│   ├── utils/time_format.dart     # Human-readable timestamps
│   ├── theme/                     # AppColors + light/dark ThemeData
│   ├── DesignUI/                  # Reusable widgets (avatar, cards, bubble...)
│   ├── Screens/
│   │   ├── login_screen.dart      # Login/register
│   │   ├── home_screen.dart       # 4-tab shell, drawer, logout
│   │   ├── select_contact_page.dart # Contact-only list + add button
│   │   ├── add_contact_page.dart  # Email lookup and add contact
│   │   ├── indivisual_page.dart   # Chat screen (REST + realtime events)
│   │   ├── calls_screen.dart      # Calls tab guidance
│   │   ├── game_screen.dart       # Games hub
│   │   └── Splash/                # Optional intro flow
│   ├── Page/chat_page.dart        # Inbox with live conversation list
│   └── Games/                     # Rock Paper Scissors, Tic Tac Toe, Color Guess
├── backend/
│   ├── server.js                  # Express + Socket.IO + MongoDB
│   ├── package.json
│   └── .env.example
└── test/widget_test.dart          # Login/session/model tests
```

Call-related files: `lib/Model/call_event.dart` (signaling event parsing),
`lib/services/call_service.dart` (WebRTC state and media), and
`lib/Screens/call_page.dart` (full-screen call UI).

## Authentication Flow

1. `LoginScreen` calls `POST /api/auth/register` or `POST /api/auth/login`.
2. The server returns `{ token, user: { id, name, email } }`.
3. `SessionStore` saves the token and user in `shared_preferences`.
4. `SessionGate` in `main.dart` restores the session on launch and shows
   `HomeScreen`; without a session it shows `LoginScreen`.
5. Every authenticated API request sends `Authorization: Bearer <token>`.
6. Logout clears `shared_preferences` and replaces the navigation stack with the
   login screen.
7. The login screen validates name, email, and password (minimum 6 characters)
   before calling the backend.

## API Endpoints

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | `/api/health` | No | Health check |
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Sign in |
| GET | `/api/auth/me` | Yes | Current user |
| GET | `/api/contacts` | Yes | Current user's contact list |
| GET | `/api/contacts/search?email=` | Yes | Look up a user by exact email |
| POST | `/api/contacts` | Yes | Add a user to contacts by email |
| DELETE | `/api/contacts/:userId` | Yes | Remove a contact |
| GET | `/api/users` | Yes | Deprecated alias for `/api/contacts` |
| GET | `/api/chats` | Yes | Conversations with last message and unread count |
| POST | `/api/messages` | Yes | Send message (sender comes from JWT) |
| GET | `/api/messages/:userId` | Yes | Conversation history |
| POST | `/api/messages/:userId/read` | Yes | Mark that conversation's messages as read |

Sending a message also adds the recipient to the sender's contact list. This
means replying to a message from someone outside your contacts adds them
automatically.

All protected routes use JWT middleware. Message senders are derived from the
verified token rather than trusting a client-supplied sender ID.

## Real-Time Messaging And Presence

- The server authenticates Socket.IO connections with the JWT (`auth.token`).
- Each socket joins `user:<id>`; `RealtimeService` owns the single app-wide
  connection and exposes new messages and the online user set.
- `POST /api/messages` and the socket `send_message` event save the message and
  emit `new_message` to both participants' rooms.
- `IndivisualPage` filters `new_message` events for the open conversation and
  de-duplicates by message ID. Sending itself uses the REST endpoint so failures
  surface directly in the UI.
- `ChatPage` refreshes its conversation list when a new message arrives, so a
  first message appears immediately without waiting for a reply. It shows the
  server-provided `unreadCount` badge for each conversation.
- New messages are created with `readAt: null`; opening a chat or receiving a
  message while it is open calls `POST /api/messages/:userId/read`. Older
  messages without a `readAt` field are treated as already read.
- While composing, `IndivisualPage` emits socket `typing` events (debounced with
  a two-second idle timeout and cleared on send/leave). The server relays them
  only to the recipient, who shows "Typing..." in the chat header.
- The server tracks connected sockets per user. On connect it emits
  `presence_state` with related online users; users' contacts and chat partners
  receive `presence` updates when someone goes online or offline.
- API user payloads include `online`, used as the initial status until a
  presence event arrives.

## Audio Calls

- Calls are 1:1 audio only. The existing Socket.IO connection carries call
  signaling; audio media flows directly between the two devices over WebRTC.
- `CallService` is a singleton `ChangeNotifier` with states `idle`, `outgoing`,
  `incoming`, `connecting`, and `active`. `HomeScreen` attaches it, routes both
  incoming and outgoing calls to `CallPage`, and detaches it on logout.
- The caller acquires the microphone, then sends `call_invite` with an
  acknowledgement that returns the server-generated `callId`. The recipient
  receives `call_incoming` with the caller's public profile.
- The server tracks active calls in memory (`activeCalls` and `userCalls`).
  It rejects self-calls, offline users, busy users, and users with no contact or
  message relationship. One call per user is allowed.
- Signaling events: client `call_invite`, `call_accept`, `call_reject`,
  `call_end`, `webrtc_signal`; server `call_incoming`, `call_accepted`,
  `call_ended`, `webrtc_signal`. WebRTC offers, answers, and ICE candidates are
  relayed only after the call is accepted.
- Caller creates the WebRTC offer after `call_accepted`; the recipient creates
  the answer. Pending ICE candidates are queued until the remote description is
  set.
- Calls time out after 45 seconds with reason `No answer`; declining uses
  `Declined`, hanging up uses `Call ended`/`Call cancelled`, and the last socket
  disconnect uses `Connection lost`.
- STUN is configured by default. Optional TURN can be supplied with the build
  defines listed above. TURN is needed for reliable connectivity on restrictive
  NATs and some mobile networks.
- The UI supports mute, speakerphone, incoming accept/decline, outgoing cancel,
  end call, and a live duration timer. Remote audio is attached through an
  `RTCVideoRenderer` on web.
- There is no call history or push-backed background ringing yet. Both users
  must have the app open for the call to ring.

## Database Schema

### User
- `name`, `email` (unique, lowercase), `password` (bcrypt hash), `createdAt`
- Passwords are never returned by the API.

### Contact
- `owner` (ObjectId ref User), `contact` (ObjectId ref User), `createdAt`
- Unique per owner/contact pair; contacts are one-way and per-user.
- Created by the add-contact API or automatically for the recipient of an
  outgoing message.

### Message
- `sender` (ObjectId ref User), `receiver` (ObjectId ref User)
- `message` (1–5000 characters), `createdAt`, `readAt` (null until read)
- Indexed for conversation lookups and unread counts; queried oldest-first.
- Legacy messages without `readAt` are treated as read.

## UI Overview

| Screen | Purpose |
|--------|---------|
| `login_screen.dart` | Sign in / register with validation and error handling |
| `home_screen.dart` | Inbox, Contacts, Calls, Games tabs; drawer; logout |
| `chat_page.dart` | Live conversation list with unread badges and pull-to-refresh |
| `select_contact_page.dart` | User-added contacts; add and remove; tap to chat |
| `add_contact_page.dart` | Look up a user by email and add them |
| `indivisual_page.dart` | Messages, send, real-time receive, presence, typing, start audio call |
| `call_page.dart` | Incoming/outgoing/active audio call controls |
| `calls_screen.dart` | Guidance for starting calls from a chat |
| `game_screen.dart` | Games hub |
| `Games/*` | Working local Rock Paper Scissors, Tic Tac Toe, Color Guess |

All screens use theme colors (`ColorScheme`) and work in light and dark mode.
Nested `Scaffold`s were removed so the tab shell owns the single AppBar/FAB.

## Android
- Package: `com.example.airmail`
- `INTERNET` permission is declared in the main manifest, so release builds can
  reach the API.
- Audio calling adds `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`,
  `ACCESS_NETWORK_STATE`, and `CHANGE_NETWORK_STATE`.
- iOS declares `NSMicrophoneUsageDescription`; camera permission will be needed
  when video calling is added.
- `image_picker` needs no extra manifest permission for the system camera intent.
- `android/gradle.properties` sets `kotlin.incremental=false`. This avoids a
  Windows-only "Could not close incremental caches" failure when the project
  path contains spaces; it can be re-enabled on other setups if desired.
- Verified with `flutter build apk --debug`.

## Running Locally

### Backend
```bash
cd backend
npm install
# set MONGODB_URI and JWT_SECRET in your shell or a local .env loaded by your tooling
npm start
```

### Flutter
```bash
flutter pub get
flutter run -d chrome
# Android
flutter run -d "Infinix X6880"
# Point the app at a local backend (Android emulator example)
flutter run --dart-define=AIRMAIL_API_URL=http://10.0.2.2:5000
```

Production base URL default:
`https://airmail-backend.onrender.com`

## Quality Checks
```bash
flutter analyze   # no issues
flutter test      # login, session, and model tests
node --check backend/server.js
```

## Known Limitations
- Calls are 1:1 audio only; video calling is not implemented yet.
- Calls ring only while both apps are open. Background/lock-screen calling
  requires push notifications and native call UI.
- Call signaling is in-memory on a single backend instance; no call history is
  stored.
- STUN-only builds can fail on restrictive NATs until TURN is configured.
- Games are local two-player/computer games; no online multiplayer.
- No push notifications; unread badges are per-conversation in the app.
- Presence and typing state are in-memory; a server restart or disconnect clears
  them until clients reconnect.
- No offline message queue; send failures are shown and can be retried.
- Session expiration requires signing in again (no refresh token).
- Contacts are one-way and must be added by each user.
- Contact avatars use initials for real users; demo screens use bundled images.

## Future Enhancements
- [ ] Message deletion, editing, and search
- [ ] Push notifications
- [ ] Contact requests and blocking
- [ ] Profile editing and avatar uploads
- [ ] Video calls and call history
- [ ] Background incoming calls with push notifications
- [ ] Refresh tokens / silent re-authentication
