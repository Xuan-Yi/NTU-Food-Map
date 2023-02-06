import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ntu_food_map/components/utils.dart';
import 'package:uuid/uuid.dart';
import 'tag_menu.dart';
import 'picture_picker.dart';
import 'dish_menu.dart';

class MyRestaurantList extends StatefulWidget {
  const MyRestaurantList({Key? key}) : super(key: key);
  @override
  State<MyRestaurantList> createState() => _MyRestaurantListState();
}

class _MyRestaurantListState extends State<MyRestaurantList> {
  List<DocumentSnapshot<Map<String, dynamic>>> snapshotList = [];
  late DocumentSnapshot<Map<String, dynamic>> currentRestaurantSnapshot;
  bool showEdit = false;
  final user = FirebaseAuth.instance.currentUser!;

// Grab restaurant from Firestore
  Future<void> _getRestaurants() async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await docUser.get();
    final List<String> myrestaurantList =
        List<String>.from(snapshot.data()!['my restaurants']);

    for (int i = 0; i < myrestaurantList.length; i++) {
      final docRestaurant = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(myrestaurantList[i]);
      final snapshot = await docRestaurant.get();
      setState(() => snapshotList.add(snapshot));
    }
  }

  @override
  void initState() {
    _getRestaurants();
    super.initState();
  }

  void _toggle() => setState(() => showEdit = !showEdit);

  // Quit edit
  Future<bool> _quitEdit() {
    showDialog(
      // Quit editing dialogue
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit editing'),
        content:
            const Text('Your data won\'t be saved. Are you sure to leave?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _toggle();
            },
            child: const Text('Leave', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    return Future.value(false);
  }

  @override
  Widget build(context) {
    return showEdit
        ? WillPopScope(
            onWillPop: _quitEdit,
            child: OwnerEditWidget(
              toggle: (void v) => _toggle(),
              currentRestaurantSnapshot: currentRestaurantSnapshot,
            ),
          )
        : Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshotList.length,
              itemBuilder: (context, index) => TextButton(
                onPressed: () {
                  setState(
                      () => currentRestaurantSnapshot = snapshotList[index]);
                  _toggle();
                },
                child: Card(
                  key: ValueKey(snapshotList[index].data()!['name']),
                  color: Colors.green,
                  elevation: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: Container(
                      constraints: const BoxConstraints(maxWidth: 96),
                      child: Text(
                        snapshotList[index].data()!['region'],
                        maxLines: 1,
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 24,
                            color: Colors.white),
                      ),
                    ),
                    title: Text(
                      snapshotList[index].data()!['name'],
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      snapshotList[index].data()!['address'],
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

// Edit widget of chosen restaurant
class OwnerEditWidget extends StatefulWidget {
  const OwnerEditWidget({
    super.key,
    required this.currentRestaurantSnapshot,
    required this.toggle,
  });

  final DocumentSnapshot<Map<String, dynamic>> currentRestaurantSnapshot;
  final ValueChanged<void> toggle;

  @override
  State<OwnerEditWidget> createState() => _OwnerEditWidgetState();
}

class _OwnerEditWidgetState extends State<OwnerEditWidget> {
  // Picture picker
  List<File> imgFiles = [];
  // Basic informations
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addrController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  // Tags
  late List<bool> tagChosen;
  bool showTags = false;
  // Dish menu
  List<Map<String, dynamic>> dishes = List<Map<String, dynamic>>.from([]);
  bool showDishMenu = false;

  // Grab dishes
  Future<void> _grabDishes() async {
    List<Map<String, dynamic>> tempDishList =
        List<Map<String, dynamic>>.from([]);
    final List<String> dishIDs =
        List<String>.from(widget.currentRestaurantSnapshot.data()!['dishes']);

    for (int i = 0; i < dishIDs.length; i++) {
      // Get dish information
      final docDish =
          FirebaseFirestore.instance.collection('dishes').doc(dishIDs[i]);
      final snapshot = await docDish.get();
      Map<String, dynamic> dish = snapshot.data()!;

      // dish = {
      //  'name': <String>,
      //  'price': <int>,
      //  'category': <String>,
      //  'image path': <String> or null,
      //  'image url': <String> or null,
      //  'id': <String> or null,
      //  'action': <String> or null,
      //  'picture changed': <bool>,
      //  'picture': <File> or null,
      // }
      dish.addAll({
        'id': dishIDs[i],
        'action': null,
        'image url': null,
        'picture changed': false,
        'picture': null,
      });
      // Get image url
      if (dish['image path'] != null) {
        final ref = FirebaseStorage.instance.ref().child(dish['image path']);
        dish['image url'] = await ref.getDownloadURL();
      }
      tempDishList.add(dish);
    }
    setState(() => dishes = List<Map<String, dynamic>>.from(tempDishList));
  }

  @override
  void initState() {
    _grabDishes();
    tagChosen =
        getTagChosen(myTag: widget.currentRestaurantSnapshot.data()!['tags']);
    nameController.text = widget.currentRestaurantSnapshot.data()?['name'];
    addrController.text = widget.currentRestaurantSnapshot.data()?['address'];
    regionController.text = widget.currentRestaurantSnapshot.data()?['region'];
    super.initState();
  }

  // Create dish
  Future<void> _createDish({required Map<String, dynamic> newDish}) async {
    //  <-- newDish format -->
    //  newDish = {
    //    'name': <String>,
    //    'category': <String>,
    //    'price': <int>,
    //    'picture': <File> or null,
    //  };

    String? path; // nullable
    final docDish = FirebaseFirestore.instance
        .collection('dishes')
        .doc(); // automatically generate an ID
    final DocumentReference<Map<String, dynamic>> docRestaurant =
        widget.currentRestaurantSnapshot.reference;
    // upload image if it is assigned
    if (newDish['picture changed']) {
      final file = newDish['picture'];
      final ref = FirebaseStorage.instance.ref();
      path = 'dish_images/${const Uuid().v4()}';
      await ref.child(path).putFile(file);
    }
    // create document (dishs)
    final json = {
      'name': newDish['name'],
      'category': newDish['category'],
      'price': newDish['price'],
      'image path': path, // path of dish picture at Firestorage or null
    };
    await docDish.set(json);
    // update document (restaurants)
    List<String> oldDishList =
        List<String>.from(widget.currentRestaurantSnapshot.data()!['dishes']);
    final List<String> newDishList = oldDishList + [docDish.id];

    await docRestaurant.update({'dishes': newDishList});
  }

  // Delete dish
  Future<void> _deleteDish({required String docID}) async {
    //  docID: id of dish document

    late String? imgPath;
    final docDish = FirebaseFirestore.instance.collection('dishes').doc(docID);
    final DocumentReference<Map<String, dynamic>> docRestaurant =
        widget.currentRestaurantSnapshot.reference;
    // delete document (dishes)
    final snapshot = await docDish.get();
    imgPath = snapshot.data()!['image path'];
    docDish.delete();
    // delete image
    final ref = FirebaseStorage.instance.ref();
    if (imgPath != null) {
      await ref.child(imgPath).delete();
    }
    // update document (restaurants)
    List<String> oldDishList =
        List<String>.from(widget.currentRestaurantSnapshot.data()!['dishes']);
    List<String> newDishList = oldDishList;
    newDishList.removeWhere((e) => e == docID);

    await docRestaurant.update({'dishes': newDishList});
  }

  // Update dish
  Future<void> _updateDish(
      {required String docID, required Map<String, dynamic> newDish}) async {
    //  <-- newDish format -->
    //  newDish = {
    //    'name': <String>,
    //    'category': <String>,
    //    'price': <int>,
    //    'picture': <File> or null,  // If null, maintain the original one
    //  };
    //  docID: id of dish document

    final docDish = FirebaseFirestore.instance.collection('dishes').doc(docID);
    // Update document (dishes)
    docDish.update({
      'name': newDish['name'],
      'category': newDish['category'],
      'price': newDish['price'],
    });
    // Delete and upload new picture
    final snapshot = await docDish.get();
    String? imgPath = snapshot.data()!['image path'];
    if (newDish['picture changed']) {
      final ref = FirebaseStorage.instance.ref();
      if (imgPath != null) {
        // delete image from Firestorage
        await ref.child(imgPath).delete();
      }
      // upload new image
      imgPath = 'dish_images/${const Uuid().v4()}';
      await ref.child(imgPath).putFile(newDish['picture']);
      // update image path
      docDish.update({
        'image path': imgPath,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sore dishes by category
    setState(() => dishes.sort((a, b) =>
        a['category'].toLowerCase().compareTo(b['category'].toLowerCase())));
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
                  child: TextField(
                    controller: nameController,
                    cursorColor: Colors.greenAccent,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
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
                  child: TextField(
                    controller: addrController,
                    cursorColor: Colors.greenAccent,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
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
                  child: TextField(
                    controller: regionController,
                    cursorColor: Colors.greenAccent,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
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
            const SizedBox(height: 10),
            // Dish menu
            DishMenu(
              dishes: dishes,
              showDishMenu: showDishMenu,
              setVisible: (visible) => setState(() => showDishMenu = visible),
              updateDish: (newData) {
                if (dishes.where((e) => e['id'] == newData['id']).isEmpty) {
                  // create a new dish
                  setState(() => dishes.add(newData));
                } else {
                  // update or delete a dish
                  final int idx = dishes.indexOf(
                      dishes.firstWhere((e) => e['id'] == newData['id']));
                  setState(() => dishes[idx] = newData);
                }
              },
            ),
            // Divider
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            // Save change
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                // json = {
                //   'name': name,
                //   'address': addr,
                //   'region': region,
                //   'coordinate': coordinate,
                //   'dishes': [],
                //   'like': 0,
                //   'comments': [],
                //   'tags':
                //       tags.where((e) => tagChosen[tags.indexOf(e)]).toList(),
                //   'images': imgs,
                // };
                // update basic informations
                final List<Map<String, dynamic>> newTags =
                    List<Map<String, dynamic>>.from(
                        tags.where((e) => tagChosen[tags.indexOf(e)]).toList());
                List<String> newImages = List<String>.from(
                    widget.currentRestaurantSnapshot.data()!['images']);
                final docRestaurant =
                    widget.currentRestaurantSnapshot.reference;
                // upload images
                final ref = FirebaseStorage.instance.ref();
                for (int i = 0; i < imgFiles.length; i++) {
                  final path = 'restaurant_images/${const Uuid().v4()}';
                  final file = imgFiles[i];
                  newImages.add(path);
                  await ref.child(path).putFile(file);
                }
                // Update document (dishes)
                docRestaurant.update({
                  'name': nameController.text,
                  'address': addrController.text,
                  'region': regionController.text,
                  'tags': newTags,
                  'images': newImages,
                });
                // update dishes
                for (int i = 0; i < dishes.length; i++) {
                  switch (dishes[i]['action']) {
                    case 'create':
                      _createDish(newDish: dishes[i]);
                      break;
                    case 'update':
                      _updateDish(docID: dishes[i]['id'], newDish: dishes[i]);
                      break;
                    case 'delete':
                      _deleteDish(docID: dishes[i]['id']);
                      break;
                    default:
                      null;
                  }
                }
                Utils.showSnackBar('Changes saved');
                void v; // a pseudo variable
                widget.toggle(v);
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
