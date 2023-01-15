import 'package:NTUFoodMap/main.dart';
import 'package:NTUFoodMap/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            const Icon(
              Icons.fastfood,
              size: 80,
            ),
            const SizedBox(
              height: 20,
            ),
            // Greeting Messages
            Text("NTU Food Map",
                style: GoogleFonts.sofia(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                )),
            const SizedBox(height: 5), // separating two lines
            const Text(
              "Please login to your account",
              style: TextStyle(fontSize: 18),
            ),
            // Email Field
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Email Address"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Password Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: passwordController,
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Password"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Sign in button
            TextButton(
              onPressed: signIn,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Register button
            RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  text: 'Not a member of NTU Food Map? ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Sign up',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
