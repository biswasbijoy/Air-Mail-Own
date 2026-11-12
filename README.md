# AirMail

A Flutter messaging app with JWT authentication and real-time chat over
Socket.IO, backed by Express and MongoDB.

## Features
- Register / sign in with persisted sessions
- Per-user contacts added by email lookup, with removal
- Live online/offline presence and typing indicators in chats
- Conversation inbox that updates in real time, including the first message
- Unread message badges per conversation, cleared when a chat is opened
- Replying to a message automatically adds the sender to your contacts
- Free 1:1 audio calls over WebRTC with Socket.IO signaling
- Send messages over REST and receive them in real time
- Light/dark Midnight Cyan theme
- Offline-friendly error states and retry
- Local mini-games and a developer contact screen

## Quick start

```bash
# Backend
cd backend
npm install
export MONGODB_URI="mongodb://127.0.0.1:27017/airmail"
export JWT_SECRET="replace-with-a-long-random-string"
npm start

# App (use 10.0.2.2 instead of 127.0.0.1 on an Android emulator)
flutter pub get
flutter run -d chrome --dart-define=AIRMAIL_API_URL=http://127.0.0.1:5000
```

The app defaults to the deployed backend. If `/api/health` on that host returns
404, the deployment is stale and does not include the `/api/chats` or Socket.IO
routes. Deploy the current `backend/` code, and set `MONGODB_URI` and
`JWT_SECRET` in the hosting dashboard before redeploying. Changing
`JWT_SECRET` invalidates existing sessions, so sign in again after deploying.

Audio calls require microphone permission and work while both users have the
app open. Media is peer-to-peer over WebRTC and signaling uses the existing
Socket.IO server. STUN is enabled by default; for restrictive networks, pass a
TURN server at build time:

```bash
flutter run \
  --dart-define=AIRMAIL_TURN_URL=turn:your-host:3478 \
  --dart-define=AIRMAIL_TURN_USERNAME=user \
  --dart-define=AIRMAIL_TURN_CREDENTIAL=password
```

TURN credentials embedded in an app build can be extracted. Use short-lived
credentials for production.

See [PROJECT_KNOWLEDGE.md](PROJECT_KNOWLEDGE.md) for architecture, endpoints, and
environment variables.
