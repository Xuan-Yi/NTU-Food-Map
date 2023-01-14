import 'login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // calls stateless obj that open's login page
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // defined in login_page
    );
  }
}

