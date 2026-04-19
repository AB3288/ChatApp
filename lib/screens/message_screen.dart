import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class MessageScreen extends StatefulWidget {
  final int currentUserId;
  final int otherUserId;
  final String otherUserEmail;

  const MessageScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserEmail,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController messageController = TextEditingController();
  List<dynamic> messages = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Rafraîchit les messages toutes les 3 secondes
    _timer = Timer.periodic(Duration(seconds: 3), (_) => _loadMessages());
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final data = await ApiService.getMessages(
        widget.currentUserId,
        widget.otherUserId,
      );
      setState(() => messages = data);
      _scrollToBottom();
    } catch (e) {
      print("Erreur: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    await ApiService.sendMessage(
      widget.currentUserId,
      widget.otherUserId,
      text,
    );
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final String nom = widget.otherUserEmail.split("@")[0];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xff2e386b),
              child: Text(
                nom[0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(nom, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xff4f4e4e),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      "Aucun message",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'].toString() ==
                          widget.currentUserId.toString();

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Color(0xff2e386b)
                                : Color(0xff4f4e4e),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: isMe
                                  ? Radius.circular(16)
                                  : Radius.circular(0),
                              bottomRight: isMe
                                  ? Radius.circular(0)
                                  : Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['message'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                msg['created_at'].toString().substring(11, 16),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input message
          Container(
            padding: EdgeInsets.all(10),
            color: Color(0xff1a1a1a),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xff2a2a2a),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0xff2e386b),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}