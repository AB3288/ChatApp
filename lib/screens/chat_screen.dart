import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'message_screen.dart';
import 'welcom_screen.dart';
class ChatScreen extends StatefulWidget {
  final String email;
  final int userId;
  const ChatScreen({super.key, required this.email, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await ApiService.getUsers(widget.userId);
      setState(() {
        users = data;
        filteredUsers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((u) =>
        u['email'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String nom = widget.email.split("@")[0];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Chat - $nom", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff4f4e4e),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await SessionService.clearSession();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: _filterUsers,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : filteredUsers.isEmpty
                    ? Center(child: Text("Aucun utilisateur", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final userName = user['email'].split("@")[0];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xff2e386b),
                              child: Text(
                                userName[0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(userName, style: TextStyle(color: Colors.white)),
                            subtitle: Text(user['email'], style: TextStyle(color: Colors.grey)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    currentUserId: widget.userId,
                                    otherUserId: int.parse(user['id'].toString()),
                                    otherUserEmail: user['email'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}