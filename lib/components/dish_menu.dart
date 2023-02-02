import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'utils.dart';

// Dish menu
class DishMenu extends StatefulWidget {
  final List<Map> dishes;
  final bool showDishMenu;
  final ValueChanged<Map> addDish;
  final ValueChanged<int> removeDish;
  final ValueChanged<bool> setVisible;
  final ValueChanged<Map> updateDish;

  const DishMenu(
      {Key? key,
      BuildContext? context,
      required this.dishes,
      required this.showDishMenu,
      required this.addDish,
      required this.removeDish,
      required this.setVisible,
      required this.updateDish})
      : super(key: key);

  @override
  State createState() => _DishMenuState();
}

class _DishMenuState extends State<DishMenu> {
  @override
  Widget build(context) {
    return Column(
      children: [
        // Dish menu title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => widget.setVisible(!widget.showDishMenu)),
              child: Text(
                widget.showDishMenu ? 'Close' : 'Edit',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        // Dish menu
        Container(
          child: widget.showDishMenu
              ? Column(
                  children: [
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                            ElevatedButton(
                              onPressed: () => showDialog(
                                // Add new dish
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Add new dish'),
                                  content: const Text(
                                      'Do you want to add a new dish?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditWindow(
                                            index: -1,
                                            dish: const {
                                              'dish': '',
                                              'price': 0,
                                              'picture': null
                                            },
                                            updateDish: (newDish) => setState(
                                              () {
                                                widget.addDish(newDish);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      child: const Text('Add',
                                          style:
                                              TextStyle(color: Colors.green)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel',
                                          style:
                                              TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  alignment: Alignment.center,
                                  backgroundColor: Colors.transparent,
                                  fixedSize: const Size(150, 180),
                                  shadowColor: Colors.transparent),
                              child: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.grey,
                                size: 78,
                              ),
                            )
                          ] +
                          widget.dishes
                              .map(
                                (e) => ElevatedButton(
                                  onPressed: () => showDialog(
                                    // Delete dish
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete this dish'),
                                      content: const Text(
                                          'Do you confirm to delete this dish?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() => widget.removeDish(
                                                widget.dishes.indexOf(e)));
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Confirm',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    alignment: Alignment.center,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green,
                                    fixedSize: const Size(150, 200),
                                  ),
                                  child: Column(
                                    children: [
                                      // Dish picture
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: SizedBox(
                                          width: 120,
                                          height: 120,
                                          child: e['picture'] == null
                                              ? const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey,
                                                  size: 78)
                                              : Image.file(e['picture'],
                                                  filterQuality:
                                                      FilterQuality.medium,
                                                  fit: BoxFit
                                                      .contain), // load image later
                                        ),
                                      ),
                                      // Dish name
                                      Tooltip(
                                        message: '${e['dish']}',
                                        padding: const EdgeInsets.all(8),
                                        verticalOffset: 36,
                                        height: 24,
                                        textStyle: const TextStyle(
                                            fontSize: 15, color: Colors.black),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 6,
                                            )
                                          ],
                                        ),
                                        waitDuration:
                                            const Duration(seconds: 1),
                                        showDuration:
                                            const Duration(seconds: 2),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            '${e['dish']}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 150),
                                      // Price & edit button
                                      SizedBox(
                                        height: 36,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Price
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Text(
                                                '\$${e['price']}',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            // Edit button
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: TextButton(
                                                onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return EditWindow(
                                                      index: widget.dishes
                                                          .indexOf(e),
                                                      dish: e,
                                                      updateDish: (newDish) =>
                                                          setState(() {
                                                        widget.updateDish({
                                                          'newdata': newDish,
                                                          'index': widget.dishes
                                                              .indexOf(e)
                                                        });
                                                      }),
                                                    );
                                                  },
                                                ),
                                                style: TextButton.styleFrom(
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  minimumSize: Size.zero,
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 18),
                    // Close button
                    ElevatedButton(
                      onPressed: () => widget.setVisible(!widget.showDishMenu),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(36),
                        shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(width: 2, color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Hide menu',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : null,
        ),
      ],
    );
  }
}

// Pop-up edit window
class EditWindow extends StatefulWidget {
  final int index; // If index ==-1, add dish
  final Map dish; // {'dish': <String>, 'price': <int>, 'image': <File>}
  final ValueChanged<Map> updateDish;

  const EditWindow({
    Key? key,
    required this.index,
    required this.dish,
    required this.updateDish,
  }) : super(key: key);

  @override
  State createState() => _EditWindowState();
}

class _EditWindowState extends State<EditWindow> {
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File imgFile = File('');
  // Textfields
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    imgFile = widget.dish['picture'] ?? File(''); // imgFile is nullable
    nameController.text = widget.dish['dish'] ?? '';
    priceController.text = widget.dish['price'].toString();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // Check whether a string is numeric
  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  // Get an image from gallery
  Future<void> _getFromGallery() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => imgFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        children: [
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.close),
              ),
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Change picture file
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: TextButton(
                    onPressed: _getFromGallery,
                    style: TextButton.styleFrom(
                        minimumSize: Size.zero, padding: EdgeInsets.zero),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: imgFile.path.isEmpty
                          ? const Icon(Icons.image_not_supported_outlined,
                              color: Colors.grey, size: 78)
                          : Image.file(imgFile,
                              filterQuality: FilterQuality.medium,
                              fit: BoxFit.contain),
                    ),
                  ),
                ),
                // Change dish name
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameController,
                    validator: (val) {
                      if (val!.isEmpty || val.trim().isEmpty) {
                        return 'Dish name shouldn\'t be empty ';
                      } else {
                        return null;
                      }
                    },
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.green),
                        labelText: 'Dish',
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Enter dish name'),
                  ),
                ),
                // Change price
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: priceController,
                    validator: (val) {
                      if (val!.isEmpty ||
                          val.trim().isEmpty ||
                          !isNumeric(val)) {
                        return 'Price should be an integer. ';
                      } else {
                        return null;
                      }
                    },
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.green),
                        labelText: 'Price',
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Enter price of dish'),
                  ),
                ),
                // Send button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        widget.updateDish({
                          'dish': nameController.text,
                          'price': int.parse(priceController.text.trim()),
                          'picture': imgFile.path.isNotEmpty ? imgFile : null,
                        });
                        Utils.showSnackBar('Changes are saved!');
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
