import 'package:flutter/material.dart';
import 'services/session_service.dart';
import 'screens/welcom_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatApp',
      home: FutureBuilder<Map<String, dynamic>?>(
        future: SessionService.getSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return ChatScreen(
              email: snapshot.data!['email'] as String,
              userId: snapshot.data!['id'] as int,
            );
          }
          return const WelcomScreen();
        },
      ),
    );
  }
}