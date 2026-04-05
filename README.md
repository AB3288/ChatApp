# ChatApp 💬

A real-time chat application built with Flutter and Firebase.

## Features

- 🔐 Authentication (Sign in / Sign up) with Firebase Auth
- 👥 List of all registered users
- 💬 Real-time messaging with Firestore
- 🎨 Pixel art style UI with PressStart2P font
- 🔒 Persistent session (auto login)
- 🚪 Logout functionality

## Tech Stack

- **Flutter** — Cross-platform mobile framework
- **Firebase Auth** — User authentication
- **Cloud Firestore** — Real-time database
- **Dart** — Programming language

## Screenshots

| Login Screen |
|---|---|
| ![Login](assets/fonts/chat1.png) |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.2.0
- Android Studio or VS Code
- Firebase project

### Installation
```bash
git clone https://github.com/AB3288/ChatApp.git
cd ChatApp
flutter pub get
flutter run
```

### Firebase Setup

1. Create a project on [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Create a **Firestore** database in test mode
4. Download `google-services.json` and place it in `android/app/`

## Project Structure
lib/
├── main.dart
├── screens/
│   ├── welcom_screen.dart
│   └── chat_screen.dart
└── widgets/
├── my_button.dart
└── firebase_options.dart

## Author

**AB3288** — [GitHub](https://github.com/AB3288)

## License

MIT License
