import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String email;
  const ChatScreen({super.key, required this.email});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String nom = widget.email.split("@")[0];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Chat - $nom",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff4f4e4e),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: "Search email",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Divider(color: Colors.white),

          // 📋 LIST USERS
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs;

                // 🔎 FILTER
                var filteredUsers = users.where((user) {
                  String email =
                      user['email'].toString().toLowerCase();
                  String search =
                      searchController.text.toLowerCase();

                  return email.contains(search);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    String email = user['email'];

                    return ListTile(
                      title: Text(
                        email,
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Icon(Icons.person, color: Colors.white),

                      // 🔥 عند الضغط (مستقبلاً chat)
                      onTap: () {
                        print("Selected: $email");
                      },
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