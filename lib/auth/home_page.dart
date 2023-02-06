import 'package:flutter/material.dart';
import '../contributor_and_owner_edit/contributor_and_owner_edit_page.dart';
import '../../map_view/map_page.dart';
import '../../timetable/timetable_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/map',
        routes: {
          '/map': (context) => const MapPage(),
          '/timetable': (context) => const TimetablePage(),
          // '/recommend': (context) => ,
          '/contribute': (context) => const ContributeAndEditPage(),
        },
      );
}
