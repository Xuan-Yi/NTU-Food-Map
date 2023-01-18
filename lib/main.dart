import 'package:firebase_auth/firebase_auth.dart'; // Fire base Auth
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'containers/auth_page.dart';
import 'components/utils.dart';
import 'containers/verify_email_page.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      navigatorKey: navigatorKey,
      home: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            } else if (snapshot.hasData) {
              return const VerifyEmailPage();
            } else {
              return const AuthPage();
            }
          },
        ),
      );
}
