import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ntu_food_map/components/navigation_dradwer.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  List<Widget> generateTimeTable() {
    var timetable = <Widget>[];
    var blocks = <Widget>[];
    final List<String> classCode = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "A",
      "B",
      "C",
      "D"
    ];
    final List<String> classTime = [
      "7:10-8:00",
      "8:10-9:00",
      "9:10-10:00",
      "10:20-11:10",
      "11:20-12:10",
      "12:20-13:10",
      "13:20-14:10",
      "14:20-15:10",
      "15:30-16:20",
      "16:30-17:20",
      "17:30-18:20",
      "18:25-19:15",
      "19:20-20:10",
      "20:15-21:05",
      "21:10-22:00"
    ];
    blocks.add(const Text(''));
    for (int i = 0; i < 6; i++) {
      blocks.add(const TableBlock());
    }

    Row r;
    for (int i = 0; i < 15; i++) {
      r = Row(
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            width: 100,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Center(
              child: Text(
                '${classCode[i]} ${classTime[i]}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...blocks
        ],
      );
      timetable.add(r);
    }
    return timetable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fastfood),
            const SizedBox(
              width: 10,
            ),
            Text("NTU Food Map",
                style: GoogleFonts.sofia(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                )),
          ],
        ),
      ),
      drawer: const NavigationDrawer(),
      backgroundColor: Colors.grey[700],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: generateTimeTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableBlock extends StatefulWidget {
  const TableBlock({Key? key}) : super(key: key);

  @override
  State<TableBlock> createState() => _TableBlockState();
}

class _TableBlockState extends State<TableBlock> {
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () => setState(() {
          isToggled = !isToggled;
        }),
        child: Container(
          padding: const EdgeInsets.all(0),
          width: 100,
          height: 30,
          decoration: BoxDecoration(
              color: isToggled ? Colors.greenAccent : Colors.white70,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: isToggled
              ? const Icon(Icons.fastfood)
              : const Icon(Icons.no_food),
        ),
      ),
    );
  }
}
