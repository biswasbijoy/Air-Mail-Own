# AirMail Project Knowledge Base

## Project Overview
AirMail is a Flutter-based messaging application with real-time chat functionality, authentication system, and multiple mini-games. The app features a Midnight Cyan UI theme and connects to a Node.js/Express/MongoDB backend.

## Tech Stack

### Frontend
- **Framework**: Flutter 3.47.9 / Dart 3.13.7
- **UI Theme**: Midnight Cyan color palette
  - Primary: `#00d4aa`
  - Dark Background: `#08080c`
  - Darker Background: `#1a1a25`
  - Light Background: `#fafafa`
- **Theme Mode**: `ThemeMode.system` (automatic light/dark switching)
- **Rendering**: Impeller backend (OpenGLES fallback)

### Backend
- **Runtime**: Node.js
- **Framework**: Express
- **Database**: MongoDB Atlas (cloud)
- **Hosting**: Render.com (free tier)
- **API Endpoints**:
  - `POST /api/auth/register` - User registration
  - `POST /api/auth/login` - User login (JWT token)
  - `GET /api/users` - Fetch user contacts
  - `POST /api/messages` - Send message (HTTP + Socket.IO)
  - `GET /api/messages/:id` - Message history

### Real-Time Communication
- **Socket.IO**: Coexists with REST API for real-time messaging
- **Client**: `socket_io_client: ^2.0.0`

### Platforms
- **Android**: Infinix X6880 (API 35, Android 15)
- **Web/Chrome**: Full functional support
- **iOS**: Not currently configured (files exist but unused)

## Project Structure

```
air_mail/
├── lib/                  # Main Dart code
│   ├── main.dart         # App entry point with ThemeData
│   ├── Model/            # Data models
│   │   └── chat_model.dart   # Chat model with nullable fields
│   ├── Model/            # Message model
│   │   └── message_model.dart
│   ├── DesignUI/         # Reusable UI widgets
│   │   ├── custom_card.dart    # Contact card in chat list
│   │   ├── contact_card.dart   # Contact display card
│   │   └── reply_side_card.dart
│   ├── Screens/          # Application screens
│   │   ├── login_screen.dart   # Register/Login flow
│   │   ├── homeScreen.dart     # Main dashboard with tabs
│   │   ├── chat_page.dart      # Chat list view
│   │   ├── indivisual_page.dart # Individual chat window
│   │   ├── select_contact_page.dart # Contact selector
│   │   ├── calls_screen.dart   # Calls/contacts list
│   │   ├── game_screen.dart    # Mini-games
│   │   └── ...
│   └── Pages/            # Page-level widgets
│       ├── splash.dart
│       └── ...
├── backend/              # Node.js/Express/MongoDB
│   └── server.js         # Main backend file
├── android/              # Android-specific configuration
└── pubspec.yaml          # Dependencies
```

## Authentication System

### JWT-Based Flow
1. **Register**: `POST /api/auth/register` with name, email, password
2. **Login**: `POST /api/auth/login` with email, password
3. **Token Storage**: Stored in session/shared preferences
4. **API Calls**: All authenticated requests include `Authorization: Bearer <token>` header

### Login Screen Features
- Toggle between Register/Login tabs
- Form validation
- Backend API connectivity to Render.com
- Token storage and automatic header injection

## UI Components

### ThemeData Configuration
```dart
// Light theme primary colors
primaryColor: Color(0x00d4aa)       // Midnight Cyan
scaffoldBackgroundColor: Color(0xF7F9FC)  // Light cyan
onPrimary: Color(0x000000)          // White text on cyan
onSurface: Color(0x1A1A1A)          // Dark text on light background

// Dark theme primary colors  
primaryColor: Color(0x00d4aa)
scaffoldBackgroundColor: Color(0x08080c)  // True dark cyan
onSurface: Color(0xFafafa)          // White text on dark background
```

### Key Widgets

#### CustomCard
- Displays contact avatar, name, last message, time
- Handles null values with `?? ''` operators
- OnTap navigates to IndivisualPage

#### ContactCard
- Simplified version for calls screen
- Shows name and status online/offline

#### IndivisualPage
- Full chat interface with message history
- Send messages via HTTP API or Socket.IO
- Emoji picker support (disabled on Android)
- Camera attachment support

## Screens Overview

| Screen | Purpose |
|--------|---------|
| `login_screen.dart` | Register/Login with JWT auth |
| `homeScreen.dart` | Main dashboard with 4 tabs |
| `chat_page.dart` | Contact list for chatting |
| `indivisual_page.dart` | Individual chat window |
| `select_contact_page.dart` | Select recipient from contacts |
| `calls_screen.dart` | Contacts list (calls tab) |
| `game_screen.dart` | Mini-games (RPS, Tic Tac Toe, Color Guess) |

### Tab Navigation (HomeScreen)
1. **Inbox** - Chat list with CustomCards
2. **Contacts** - User contact list
3. **Calls** - Calls list with avatars
4. **Games** - Mini-games section

## Backend Integration

### API Connection
- **Production**: `https://airmail-backend.onrender.com`
- **Development**: Local Node.js server
- **Base URL**: Configured in multiple screens

### Key Endpoints Usage

#### Fetch Users
```dart
final response = await http.get(
  Uri.parse('https://airmail-backend.onrender.com/api/users'),
  headers: {'Authorization': 'Bearer $_token'}
);
```

#### Send Message
```dart
// HTTP API
await http.post(
  Uri.parse('https://airmail-backend.onrender.com/api/messages'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  },
  body: json.encode({
    'senderId': _currentUserId,
    'receiverId': widget.chatModel.id,
    'message': _controller.text,
  }),
);

// Socket.IO
socket.emit('send_message', {
  senderId: _currentUserId,
  receiverId: widget.chatModel.id,
  message: _controller.text,
});
```

#### Message Model
```javascript
// Server-side schema
{
  senderId: String,
  receiverId: String, 
  message: String,
  createdAt: Date
}
```

## Database Schema (MongoDB Atlas)

### Chat Model Fields
- `name`: User display name
- `icon`: Avatar image path
- `time`: Last message timestamp
- `status`: Online/offline status
- `currentMessage`: Preview of last message
- `id`: Unique identifier (first 8 chars of MongoDB _id)
- `email`: User email address

### Users Collection
- Standard MongoDB user document with auth fields
- Used for contacts list population

## Known Issues & Fixes

### Resolved Issues

1. **Blank Screen on Startup** (`lib/main.dart:86`)
   - **Problem**: `home` widget set to `Center(child: Text('AirMail'))` instead of `LoginScreen()`
   - **Fix**: Changed to `home: LoginScreen()`

2. **TypeError: null is not a subtype of String**
   - **Problem**: `ChatModel` used `var` fields defaulting to `null`, causing TypeErrors in Text widgets
   - **Fix**: Changed fields to `String?` with null-aware `??` operators throughout UI

3. **Android Build Failure**
   - **Problem**: `emoji_picker_flutter:1.6.4` conflicted with Kotlin Gradle Plugin JVM target
   - **Fix**: Removed dependency; app builds successfully on Android 15

4. **Gradle Compatibility**
   - **Problem**: Gradle 6.7 incompatible with Java 17
   - **Fix**: Upgraded to Gradle 8.4 with declarative plugins block

5. **Chrome/Web Compilation**
   - **Problem**: `errorColor` named parameter removed in Flutter 3.x
   - **Fix**: Removed deprecated `errorColor` from ThemeData

6. **Inherited Widget Error**
   - **Problem**: `dependOnInheritedWidgetOfExactType<_ModalScopeStatus>` in `initState()`
   - **Fix**: Moved `ModalRoute.of(context)!.settings.arguments` to `didChangeDependencies()`

### Current Known Limitations
- **Emoji Picker**: Removed on Android; not re-added due to Kotlin compatibility
- **iOS Support**: Files exist but not tested/configured
- **Backend Dependency**: Requires `MONGODB_URI` env var in Render dashboard for full MongoDB persistence
- **Socket.IO**: Coexists with REST API; full real-time setup requires backend configuration

## Development Commands

### Running the App

#### Chrome/Web
```bash
flutter run -d chrome
```

#### Android
```bash
flutter run -d "Infinix X6880"
# OR
flutter install  # installs debug APK
```

#### Build APK
```bash
flutter build apk
```

### Code Quality
```bash
flutter clean    # Clean build directory
flutter pub get  # Get dependencies
flutter run      # Run on default device
```

## Recent Git History

```
67d8c46 fix: resolve TypeError null issue and fix blank screen on startup
99f7172 fix: UI theme fixes for light/dark mode readability
7efd578 feat: add dark theme support and fix UI for both light/dark modes
7921af5 feat: remove emoji_picker_flutter - resolves Kotlin JVM target issue
aac8776 fix: migrate to AGP 8.4 and declarative plugins block
74a0e53 fix: upgrade Gradle from 6.7 to 8.4 for Java 17 compatibility
de38841 migrate airmail to flutter 3.x with midnight cyan theme, auth system, and mongodb backend integration
```

## Setup Requirements

### For Full Functionality
1. **Render.com Dashboard**: Set `MONGODB_URI` environment variable with MongoDB Atlas connection string
2. **Backend Server**: Run `node backend/server.js` locally or on Render
3. **Flutter SDK**: Version 3.47.9 or compatible
4. **Android SDK**: API 35 (Android 15) for Infinix X6880

### Environment Configuration
- `.env` or Render dashboard: `MONGODB_URI=mongodb+srv://username:password@cluster0.mongodb.net/airmail`
- Backend URL: `BASE_URL=https://airmail-backend.onrender.com` (or local ngrok URL)

## Future Enhancements

- [ ] Re-add emoji picker with KGP-compatible version
- [ ] iOS platform configuration and testing
- [ ] Offline message queue
- [ ] Push notifications
- [ ] User profile editing
- [ ] Message search functionality
- [ ] Multi-device login support
- [ ] Dark mode force-toggle option
- [ ] Theme customization options