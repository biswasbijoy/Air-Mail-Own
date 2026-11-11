# AirMail

A Flutter messaging app with JWT authentication and real-time chat over
Socket.IO, backed by Express and MongoDB.

## Features
- Register / sign in with persisted sessions
- Contact list and conversation inbox
- Send messages over REST and receive them in real time
- Light/dark Midnight Cyan theme
- Offline-friendly error states and retry
- Local mini-games and a developer contact screen

## Quick start

```bash
# Backend
cd backend
npm install
# Configure MONGODB_URI and JWT_SECRET (see backend/.env.example)
npm start

# App
flutter pub get
flutter run -d chrome
```

To use a local backend:

```bash
flutter run --dart-define=AIRMAIL_API_URL=http://10.0.2.2:5000
```

See [PROJECT_KNOWLEDGE.md](PROJECT_KNOWLEDGE.md) for architecture, endpoints, and
environment variables.
