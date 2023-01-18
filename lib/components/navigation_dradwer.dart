import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntu_food_map/main.dart'; // Fire base Auth

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

// implement logOut
  Future logOut(BuildContext context) async {
    Navigator.pop(context);
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildItems(context),
            ],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Container();

  Widget buildItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16,
          children: [
            // Map Button
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map'),
              onTap: () => {
                Navigator.pop(context),
                Navigator.pushNamed(context, '/map'),
              },
            ),
            const Divider(color: Colors.black12),
            // Timetable Button
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('My Timetable'),
              onTap: () => {
                Navigator.pop(context),
                Navigator.pushNamed(context, '/timetable'),
              },
            ),
            const Divider(color: Colors.black12),
            // Log out button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logging out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => logOut(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
}
