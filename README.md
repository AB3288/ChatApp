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

Copy chatapp_api/ to /var/www/html/ then update your IP in lib/services/api_service.dart:

static const String baseUrl = "http://YOUR_IP/chatapp_api";

### API Files

config.php — Database connection and CORS headers

```php
<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$host = "localhost";
$dbname = "chatapp";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
    exit;
}
?>

```
auth.php — Login and Register

```php
<?php
require 'config.php';

$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (!$email || !$password) {
    echo json_encode(["success" => false, "error" => "Champs manquants"]);
    exit;
}

$stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "success" => true,
            "action" => "login",
            "user" => ["id" => $user['id'], "email" => $user['email']]
        ]);
    } else {
        echo json_encode(["success" => false, "error" => "Mot de passe incorrect"]);
    }
} else {
    $hashed = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO users (email, password) VALUES (?, ?)");
    $stmt->execute([$email, $hashed]);
    $id = $pdo->lastInsertId();

    echo json_encode([
        "success" => true,
        "action" => "register",
        "user" => ["id" => $id, "email" => $email]
    ]);
}
?>

```
users.php — Get all users except current user
```php
<?php
require 'config.php';

$currentId = $_GET['current_id'] ?? 0;

$stmt = $pdo->prepare("SELECT id, email FROM users WHERE id != ?");
$stmt->execute([$currentId]);
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(["success" => true, "users" => $users]);
?>

```
messages.php — Send and receive messages
```php

<?php
require 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $pdo->prepare(
        "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)"
    );
    $stmt->execute([$data['sender_id'], $data['receiver_id'], $data['message']]);

    echo json_encode(["success" => true]);

} else {
    $sender_id = $_GET['sender_id'];
    $receiver_id = $_GET['receiver_id'];

    $stmt = $pdo->prepare("
        SELECT m.*, u.email as sender_email
        FROM messages m
        JOIN users u ON m.sender_id = u.id
        WHERE (m.sender_id = ? AND m.receiver_id = ?)
           OR (m.sender_id = ? AND m.receiver_id = ?)
        ORDER BY m.created_at ASC
    ");

    $stmt->execute([$sender_id, $receiver_id, $receiver_id, $sender_id]);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "messages" => $messages]);
}
?>

```
### Run
```bash
flutter run
```
## API Endpoints

| Method | URL | Description |
|---|---|---|
| POST | /auth.php | Login or Register |
| GET | /users.php?current_id=1 | Get all users |
| GET | /messages.php?sender_id=1&receiver_id=2 | Get messages |
| POST | /messages.php | Send message |

## Author

AB3288 - https://github.com/AB3288