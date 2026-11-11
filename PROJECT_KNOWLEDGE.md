# AirMail Project Knowledge Base

## Project Overview
AirMail is a Flutter messaging app backed by Node.js/Express/MongoDB. It
supports JWT authentication, persisted sessions, a contact list, conversation
history, HTTP message sending, and real-time delivery through Socket.IO. The UI
uses the Midnight Cyan theme with automatic light/dark mode.

## Tech Stack

### Frontend
- Flutter 3.47.9 / Dart 3.13.7
- Material 3 (`useMaterial3: true`)
- HTTP (`package:http`) for REST calls
- Socket.IO client (`socket_io_client`) for real-time messages
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

The server exits at startup when `MONGODB_URI` or `JWT_SECRET` is missing.

## Project Structure

```
air_mail/
├── lib/
│   ├── main.dart                  # App + SessionGate (auto-login)
│   ├── Model/
│   │   ├── chat_model.dart        # Contact/conversation model + JSON parsing
│   │   └── message_model.dart     # Message model + JSON parsing
│   ├── services/
│   │   ├── api_service.dart       # REST client, auth headers, API errors
│   │   └── session.dart           # SharedPreferences session store
│   ├── utils/time_format.dart     # Human-readable timestamps
│   ├── theme/                     # AppColors + light/dark ThemeData
│   ├── DesignUI/                  # Reusable widgets (avatar, cards, bubble...)
│   ├── Screens/
│   │   ├── login_screen.dart      # Login/register
│   │   ├── home_screen.dart       # 4-tab shell, drawer, logout
│   │   ├── select_contact_page.dart
│   │   ├── indivisual_page.dart   # Chat screen (REST + Socket.IO)
│   │   ├── calls_screen.dart      # Demo call list
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
| GET | `/api/users` | Yes | Contacts (excludes current user) |
| GET | `/api/chats` | Yes | Conversations with last message |
| POST | `/api/messages` | Yes | Send message (sender comes from JWT) |
| GET | `/api/messages/:userId` | Yes | Conversation history |

All protected routes use JWT middleware. Message senders are derived from the
verified token rather than trusting a client-supplied sender ID.

## Real-Time Messaging

- The server authenticates Socket.IO connections with the JWT (`auth.token`).
- Each socket joins `user:<id>`.
- `POST /api/messages` and the socket `send_message` event save the message and
  emit `new_message` to both participants' rooms.
- `IndivisualPage` listens for `new_message`, filters events for the open
  conversation, and de-duplicates by message ID. Sending itself uses the REST
  endpoint so failures surface directly in the UI.
- Clients also support sending through the socket with an ack callback.

## Database Schema

### User
- `name`, `email` (unique, lowercase), `password` (bcrypt hash), `createdAt`
- Passwords are never returned by the API.

### Message
- `sender` (ObjectId ref User), `receiver` (ObjectId ref User)
- `message` (1–5000 characters), `createdAt`
- Indexed for conversation lookups; queried oldest-first.

## UI Overview

| Screen | Purpose |
|--------|---------|
| `login_screen.dart` | Sign in / register with validation and error handling |
| `home_screen.dart` | Inbox, Contacts, Calls, Games tabs; drawer; logout |
| `chat_page.dart` | Live conversation list with pull-to-refresh |
| `select_contact_page.dart` | Searchable contacts; tap to chat |
| `indivisual_page.dart` | Message history, send, real-time receive |
| `calls_screen.dart` | Demo call history (calls not implemented) |
| `game_screen.dart` | Games hub |
| `Games/*` | Working local Rock Paper Scissors, Tic Tac Toe, Color Guess |

All screens use theme colors (`ColorScheme`) and work in light and dark mode.
Nested `Scaffold`s were removed so the tab shell owns the single AppBar/FAB.

## Android
- Package: `com.example.airmail`
- `INTERNET` permission is declared in the main manifest, so release builds can
  reach the API.
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
- Calls are a demo list; no voice/video backend.
- Games are local two-player/computer games; no online multiplayer.
- No push notifications, unread badges, typing indicators, or presence tracking.
- No offline message queue; send failures are shown and can be retried.
- Session expiration requires signing in again (no refresh token).
- Contact avatars use initials for real users; demo screens use bundled images.

## Future Enhancements
- [ ] Message deletion, editing, and search
- [ ] Push notifications and unread counts
- [ ] Online presence and typing indicators
- [ ] Profile editing and avatar uploads
- [ ] Voice/video calls
- [ ] Refresh tokens / silent re-authentication
