import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: RandomCat(),
        appBar: AppBar(
          title: Center(
            child: Text(
              "Random Cat",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    ),
  );
}

class RandomCat extends StatefulWidget {
  const RandomCat({super.key});

  @override
  State<RandomCat> createState() => _RandomCatState();
}

class _RandomCatState extends State<RandomCat> {
  String imgPath = "assets/a cat.jpg";
  var imgList = [
    'assets/a cat.jpg',
    'assets/cool cat.jpg',
    'assets/kitty.jpg',
    'assets/shocked cat.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            imgPath,
            height: 200,
            width: 200,
          ),
          ElevatedButton(
              onPressed: () => setState(() {
                    imgList.shuffle();
                    imgPath = imgList[0];
                  }),
              child: Text("換一隻貓貓")),
        ],
      ),
    );
  }
}
