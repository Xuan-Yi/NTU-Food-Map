import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'utils.dart';
import 'tag_menu.dart';
import 'picture_picker.dart';
import 'dish_menu.dart';

class OwnerEditWidget extends StatefulWidget {
  const OwnerEditWidget({super.key});

  @override
  State<OwnerEditWidget> createState() => _OwnerEditWidgetState();
}

class _OwnerEditWidgetState extends State<OwnerEditWidget> {
  // Picture picker
  List<File> imgFiles = [];
  // Tags
  List<bool> tagChosen = List.filled(tags.length, false);
  bool showTags = false;
  // Dish menu
  List<Map> dishes = [
    {'dish': '鍋燒意麵', 'price': 75, 'picture': null},
    {'dish': '廣東粥', 'price': 65, 'picture': null},
    {'dish': '美味蟹堡', 'price': 175, 'picture': null},
    {'dish': 'QQㄋㄟㄋㄟ好喝到咩噗茶', 'price': 45, 'picture': null},
    {'dish': '飯', 'price': 15, 'picture': null},
    {'dish': 'Margherita Pizza', 'price': 75, 'picture': null},
    {'dish': 'ゆばそば', 'price': 50, 'picture': null},
  ];
  bool showDishMenu = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Picture picker
            PicturePicker(
              imgFiles: imgFiles,
              setImgFiles: (newFiles) => setState(() => imgFiles = newFiles),
              removeImgFile: (idx) =>
                  setState(() => imgFiles.remove(imgFiles[idx])),
            ),
            // Basic informations title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Basic informations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            // Restaurant name
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Theme(
                  data: ThemeData().copyWith(
                    colorScheme: ThemeData().colorScheme.copyWith(
                          primary: Colors.greenAccent,
                        ),
                  ),
                  child: const TextField(
                    cursorColor: Colors.greenAccent,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.restaurant),
                        border: InputBorder.none,
                        hintText: "Restaurant Name"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Restaurant address
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Theme(
                  data: ThemeData().copyWith(
                    colorScheme: ThemeData().colorScheme.copyWith(
                          primary: Colors.greenAccent,
                        ),
                  ),
                  child: const TextField(
                    cursorColor: Colors.greenAccent,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.home),
                        border: InputBorder.none,
                        hintText: "What's the address?"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Restaurant region
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Theme(
                  data: ThemeData().copyWith(
                    colorScheme: ThemeData().colorScheme.copyWith(
                          primary: Colors.greenAccent,
                        ),
                  ),
                  child: const TextField(
                    cursorColor: Colors.greenAccent,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.radar),
                        border: InputBorder.none,
                        hintText: "Region (118, 活大, 師大夜市...)"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Tags
            TagMenu(
              tagChosen: tagChosen,
              toggleTag: (idx) =>
                  setState(() => tagChosen[idx] = !tagChosen[idx]),
              showTags: showTags,
              setVisible: (visible) => setState(() => showTags = visible),
            ),
            // Divider
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 10), // Dish menu
            DishMenu(
              dishes: dishes,
              showDishMenu: showDishMenu,
              addDish: (d) => setState(() => dishes.add(d)),
              removeDish: (idx) => setState(() => dishes.remove(dishes[idx])),
              setVisible: (visible) => setState(() => showDishMenu = visible),
              updateDish: (d) =>
                  setState(() => dishes[d['index']] = d['newdata']),
            ),
            // Divider
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            // Save change
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // more response here
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                shadowColor: MaterialStateProperty.all<Color>(Colors.orange),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(44)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              icon: const Icon(Icons.send),
              label: const Text(
                'Save Change',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
