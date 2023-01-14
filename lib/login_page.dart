import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(Icons.fastfood, size: 80,),
            SizedBox(height: 20,),
            // Greeting Messages
            Text(
              "NTU Food Map",
              style: GoogleFonts.sofia(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              )
            ),
            SizedBox(height: 5), // separating two lines
            Text(
              "Please login to your account",
              style: TextStyle(
                fontSize: 18
              ),
            ),
            // Email Field
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email Address"
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Password Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password"
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            // Sign in button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                  ),
                )
              ),
            ),
            SizedBox(height: 20,),
            // Register button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member of NTU Food Map? ",
                ),
                Text(
                  "Register Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                )
              ],
            )
          ],

        ),
      )
    );
  }
}
