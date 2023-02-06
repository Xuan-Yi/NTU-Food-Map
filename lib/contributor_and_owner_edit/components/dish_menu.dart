import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../utility_components/utils.dart';

// Dish menu
class DishMenu extends StatefulWidget {
  final List<Map<String, dynamic>> dishes;
  final bool showDishMenu;
  final ValueChanged<bool> setVisible;
  final ValueChanged<Map<String, dynamic>> updateDish;

  const DishMenu({
    Key? key,
    BuildContext? context,
    required this.dishes,
    required this.showDishMenu,
    required this.setVisible,
    required this.updateDish,
  }) : super(key: key);

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
                                            dish: {
                                              'name': '',
                                              'price': 0,
                                              'category': '',
                                              'image path': null,
                                              'image url': null,
                                              'id': 'temp_${const Uuid().v4()}',
                                              'action': 'create',
                                              'picture changed': false,
                                              'picture': null,
                                            },
                                            updateDish: (d) {
                                              widget.updateDish(d);
                                              Navigator.pop(context);
                                            },
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
                              .where((e) => e['action'] != 'delete')
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
                                            Map<String, dynamic> newData =
                                                Map<String, dynamic>.from(e);
                                            newData['action'] = 'delete';
                                            widget.updateDish(newData);
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
                                    fixedSize: const Size(150, 220),
                                  ),
                                  child: Column(
                                    children: [
                                      // Category
                                      Container(
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(8)),
                                            color: Colors.green),
                                        padding: const EdgeInsets.all(4),
                                        child: SizedBox.fromSize(
                                          size: const Size.fromHeight(18),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${e['category']}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Dish picture
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: SizedBox(
                                          width: 120,
                                          height: 120,
                                          child: e['picture changed']
                                              ? Image.file(e['picture'])
                                              : e['image path'] == null
                                                  ? const Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      color: Colors.grey,
                                                      size: 78)
                                                  : Image.network(
                                                      e['image url'],
                                                      filterQuality:
                                                          FilterQuality.medium,
                                                      fit: BoxFit.contain),
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
                                            '${e['name']}',
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
                                                      dish: e,
                                                      updateDish: (d) =>
                                                          widget.updateDish(d),
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
  final Map<String, dynamic> dish;
  final ValueChanged<Map<String, dynamic>> updateDish; // send new dish back

  const EditWindow({
    Key? key,
    required this.dish,
    required this.updateDish,
  }) : super(key: key);

  @override
  State createState() => _EditWindowState();
}

class _EditWindowState extends State<EditWindow> {
  late Map<String, dynamic> newDish;
  // Image picker
  final ImagePicker _picker = ImagePicker();
  // Textfields
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    newDish = Map<String, dynamic>.from(widget.dish);
    nameController.text = widget.dish['name'] ?? '';
    priceController.text = widget.dish['price'].toString();
    categoryController.text = widget.dish['category'] ?? '';
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    categoryController.dispose();
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
      setState(() {
        newDish.update('picture', (value) => File(pickedFile.path));
        newDish.update('picture changed', (value) => true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
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
                      child: newDish['picture changed']
                          ? Image.file(newDish['picture'])
                          : newDish['image path'] != null
                              ? Image.network(newDish['image url'],
                                  filterQuality: FilterQuality.medium,
                                  fit: BoxFit.contain)
                              : const Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey, size: 78),
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
                // Change dish category
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: categoryController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.green),
                        labelText: 'Category',
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Enter dish category'),
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
                        // Record updates
                        setState(() {
                          newDish['name'] = nameController.text;
                          newDish['price'] =
                              int.parse(priceController.text.trim());
                          newDish['category'] = categoryController.text;
                          newDish['action'] = newDish['id'].contains('temp_')
                              ? 'create'
                              : 'update';
                        });

                        widget.updateDish(newDish);
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
