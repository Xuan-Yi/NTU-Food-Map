import 'package:NTUFoodMap/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'utils.dart';

class SignUpWidget extends StatefulWidget {
  final VoidCallback onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
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
        child: Form(
          key: formKey,
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
                "Create a new account!",
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
                    child: TextFormField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Email Address"),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'Enter a valid email'
                              : null,
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
                    child: TextFormField(
                      controller: passwordController,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Password"),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 6
                          ? 'Password should have at least 6 characters.'
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Sign up button
              TextButton(
                onPressed: signUp,
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
                        'Sign Up',
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
                    text: 'Already have an acount? ',
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignIn,
                        text: 'Log in',
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
      ),
    );
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
