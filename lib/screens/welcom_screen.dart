import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/my_button.dart';
import 'chat_screen.dart';

class WelcomScreen extends StatefulWidget {
  const WelcomScreen({super.key});

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Remplis tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.auth(email, password);
      if (data['success'] == true) {
        // ← Parse en int pour éviter l'erreur String/int
        final int userId = int.parse(data['user']['id'].toString());
        final String userEmail = data['user']['email'].toString();

        await SessionService.saveSession(userId, userEmail);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              email: userEmail,
              userId: userId,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error']?.toString() ?? "Erreur")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur connexion: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              child: Image.asset("assets/fonts/chat1.png", fit: BoxFit.contain),
            ),
            Text(
              "ChatApp",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xff2e386b),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Mot de passe",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
            SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : MyButton(
                    title: "Sign in || Sign up",
                    color: const Color.fromARGB(255, 120, 119, 119),
                    onpress: _handleAuth,
                  ),
          ],
        ),
      ),
    );
  }
}