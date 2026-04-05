import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messanger/screens/chat_screen.dart';
import '../widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class WelcomScreen extends StatefulWidget {
  const WelcomScreen({super.key});

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _obscurePassword = true;
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

  var user = FirebaseAuth.instance;
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
            // Logo
            Container(
              height: 180,
              child: Image.asset(
                "assets/fonts/chat1.png",
                fit: BoxFit.contain,
              ),
            ),

            // Titre
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

            // Champ Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                focusColor: Colors.white,
                labelText: "Email",
                hintText: "exemple@email.com",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color.fromARGB(255, 205, 210, 235), width: 2),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Champ Mot de passe
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                focusColor: Colors.white,
                labelText: "Mot de passe",
                hintText: "••••••••",
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color.fromARGB(255, 171, 172, 178), width: 2),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Bouton Sign in
            MyButton(
              title: "Sign in || Sing up",
              color: const Color.fromARGB(255, 120, 119, 119),
              onpress:  () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Remplis tous les champs")),
                  );
                  return;
                }
                try {
                  await user.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder:(context)=> ChatScreen(email: email,)),
                  );
                } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
                      // Crée le compte
                      await user.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.currentUser!.uid)
                        .set({
                          'email': email,
                          'uid': user.currentUser!.uid,
                        });
                      if (!mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(email: email,)));
                    }
                  }
              },
            ),
          ],
        ),
      ),
    );
  }
}
