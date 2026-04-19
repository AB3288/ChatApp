# ChatApp

A real-time chat application built with Flutter, PHP and MySQL.

## Architecture
Flutter (Frontend)
down HTTP
PHP REST API (Backend)
down
MySQL (phpMyAdmin)
## Features

- Sign in / Sign up automatic
- List of registered users
- Real-time messaging (refresh every 3s)
- Pixel art style UI with PressStart2P font
- Persistent session with SharedPreferences
- Logout

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter / Dart |
| Backend | PHP 8.3 |
| Database | MySQL |
| DB Manager | phpMyAdmin |
| Session | SharedPreferences |
| HTTP | package:http |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.2.0
- PHP >= 8.0
- MySQL
- Apache

### Installation

```bash
git clone https://github.com/AB3288/ChatApp.git
cd ChatApp
flutter pub get
```

### Database Setup

Run this SQL in phpMyAdmin:

```sql
CREATE DATABASE chatapp;

USE chatapp;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id)
);
```

### API Setup

Copy `chatapp_api/` to `/var/www/html/` then update your IP in `lib/services/api_service.dart`:

```dart
static const String baseUrl = "http://YOUR_IP/chatapp_api";
```

### Run

```bash
flutter run
```

## Project Structure
lib/
├── main.dart
├── screens/
│   ├── welcom_screen.dart
│   ├── chat_screen.dart
│   └── message_screen.dart
├── services/
│   ├── api_service.dart
│   └── session_service.dart
└── widgets/
└── my_button.dart
chatapp_api/
├── config.php
├── auth.php
├── users.php
└── messages.php
## API Endpoints

| Method | URL | Description |
|---|---|---|
| POST | /auth.php | Login or Register |
| GET | /users.php?current_id=1 | Get all users |
| GET | /messages.php?sender_id=1&receiver_id=2 | Get messages |
| POST | /messages.php | Send message |

## Author

AB3288 - https://github.com/AB3288

## License

MIT License
