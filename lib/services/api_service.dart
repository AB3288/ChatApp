import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.100.176/chatapp_api";

  static Future<Map<String, dynamic>> auth(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getUsers(int currentId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users.php?current_id=$currentId"),
    );
    final data = jsonDecode(response.body);
    return data['users'];
  }

  static Future<bool> sendMessage(int senderId, int receiverId, String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/messages.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message": message,
      }),
    );
    return jsonDecode(response.body)['success'];
  }

  static Future<List<dynamic>> getMessages(int senderId, int receiverId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/messages.php?sender_id=$senderId&receiver_id=$receiverId"),
    );
    return jsonDecode(response.body)['messages'];
  }
}