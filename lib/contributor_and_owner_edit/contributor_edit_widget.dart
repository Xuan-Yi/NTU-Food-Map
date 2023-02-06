import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../utility_components/utils.dart';
import 'components/tag_menu.dart';
import 'components/picture_picker.dart';

class ContributeButton extends StatefulWidget {
  const ContributeButton({super.key});

  @override
  State<ContributeButton> createState() => _ContributeButtonState();
}

class _ContributeButtonState extends State<ContributeButton> {
  bool showEdit = false;

  void _toggle() => setState(() => showEdit = !showEdit);

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
            child: ContributorEditWidget(
              toggle: (void v) => _toggle(),
            ),
          )
        : SizedBox.fromSize(
            size: const Size.fromHeight(36),
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.transparent),
              onPressed: _toggle,
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.grey,
                size: 32,
              ),
            ),
          );
  }
}

// Contributor edit widget
class ContributorEditWidget extends StatefulWidget {
  const ContributorEditWidget({super.key, required this.toggle});
  final ValueChanged toggle;

  @override
  State<ContributorEditWidget> createState() => _ContributorEditWidgetState();
}

class _ContributorEditWidgetState extends State<ContributorEditWidget> {
  // Picture picker
  List<File> imgFiles = [];
  // Basic informations
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addrController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  // Tags
  List<bool> tagChosen = List.filled(tags.length, false);
  bool showTags = false;
  // Map
  late MapController _mapController;
  late LocationData currentLocation;
  bool _centerIsCurrentLocation = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // Get current location
  Future<LocationData?> _currentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    return await location.getLocation();
  }

  // Add restaurant to database
  Future createRestaurant(
      {required String name,
      required String addr,
      required String region,
      required GeoPoint coordinate}) async {
    List<String> imgs = [];
    // upload images
    final ref = FirebaseStorage.instance.ref();

    for (int i = 0; i < imgFiles.length; i++) {
      final path = 'restaurant_images/${const Uuid().v4()}';
      final file = imgFiles[i];
      imgs.add(path);
      await ref.child(path).putFile(file);
    }
    // create document
    final docRestaurant = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(); // automatically generate an ID
    final json = {
      'name': name,
      'address': addr,
      'region': region,
      'coordinate': coordinate,
      'dishes': [],
      'like': 0,
      'comments': [],
      'tags': tags.where((e) => tagChosen[tags.indexOf(e)]).toList(),
      'images': imgs,
    };

    await docRestaurant.set(json);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData?>(
      future: _currentLocation(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          currentLocation = snapshot.data;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Picture picker
                  PicturePicker(
                    imgFiles: imgFiles,
                    setImgFiles: (newFiles) =>
                        setState(() => imgFiles = newFiles),
                    removeImgFile: (idx) =>
                        setState(() => imgFiles.remove(imgFiles[idx])),
                  ),
                  // Basic informations title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Basic informations',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                  // Position recorder title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Position',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  // Record Coordinate
                  Row(
                    children: [
                      // Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _centerIsCurrentLocation = true);
                          _mapController.moveAndRotate(
                              LatLng(currentLocation.latitude!,
                                  currentLocation.longitude!),
                              16,
                              0);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        child: const Text(
                          'Record Position',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Coordinate
                      TextButton(
                        onPressed: () => Clipboard.setData(ClipboardData(
                                text:
                                    "(${currentLocation.latitude!}, ${currentLocation.longitude!})"))
                            .then((_) => Utils.showSnackBar(
                                'Coordinate copied to clipboard')),
                        child: Text(
                          '(${currentLocation.latitude!.toStringAsFixed(4)}, ${currentLocation.longitude!.toStringAsFixed(4)})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Coordinate preview on map
                  Center(
                    child: SizedBox(
                      height: 250,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          onPositionChanged: (position, hasGesture) => setState(
                            () => _centerIsCurrentLocation = (position.center ==
                                LatLng(currentLocation.latitude!,
                                    currentLocation.longitude!)),
                          ),
                          maxZoom: 18,
                          keepAlive: true,
                          center: LatLng(currentLocation.latitude!,
                              currentLocation.longitude!),
                          zoom: 16,
                        ),
                        nonRotatedChildren: [
                          // Navigate to current location/NTU
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 34, horizontal: 2),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(
                                    () => _centerIsCurrentLocation
                                        ? {}
                                        : _mapController.move(
                                            LatLng(currentLocation.latitude!,
                                                currentLocation.longitude!),
                                            16),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(10),
                                ),
                                child: Icon(
                                  _centerIsCurrentLocation
                                      ? Icons.my_location
                                      : Icons.location_searching,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          AttributionWidget.defaultWidget(
                            source: 'OpenStreetMap contributors',
                            onSourceTapped: null,
                          ),
                        ],
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              // Current location
                              Marker(
                                point: LatLng(currentLocation.latitude!,
                                    currentLocation.longitude!),
                                width: 80,
                                height: 80,
                                rotate: true,
                                anchorPos: AnchorPos.align(AnchorAlign.center),
                                builder: (context) => IconButton(
                                  onPressed: () {
                                    Fluttertoast.showToast(
                                        msg: "Your current location",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    setState(
                                        () => _centerIsCurrentLocation = true);
                                    _mapController.moveAndRotate(
                                        LatLng(currentLocation.latitude!,
                                            currentLocation.longitude!),
                                        16,
                                        0);
                                  },
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    shadows: <Shadow>[
                                      Shadow(
                                          color: Colors.white, blurRadius: 15.0)
                                    ],
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  // Send application
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = nameController.text;
                      final addr = addrController.text;
                      final region = regionController.text;

                      createRestaurant(
                        name: name,
                        addr: addr,
                        region: region,
                        coordinate: GeoPoint(currentLocation.latitude!,
                            currentLocation.longitude!),
                      );

                      widget.toggle(null);
                      Utils.showSnackBar('Application is send.');
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.orange),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size.fromHeight(44)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text(
                      'Send Application',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
