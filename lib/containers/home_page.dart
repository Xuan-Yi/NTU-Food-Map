import 'package:flutter/material.dart';
import 'search_page.dart';
import 'map_page.dart';
import 'timetable_page.dart';

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
          '/searchpage': (context) => const SearchPage(),
          // '/recommend': (context) => ,
          // '/favorite':(context) => ,
        },
      );
}
