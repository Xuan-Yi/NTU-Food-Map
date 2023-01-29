import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'utils.dart';

class ContributeEditWidget extends StatefulWidget {
  const ContributeEditWidget({super.key});

  @override
  State<ContributeEditWidget> createState() => _ContributeEditWidgetState();
}

class _ContributeEditWidgetState extends State<ContributeEditWidget> {
  late MapController _mapController;
  late LocationData currentLocation;
  bool _centerIsCurrentLocation = true;
  final ImagePicker _picker = ImagePicker();
  List<File>? imgFiles = [];
  static const List<Map<String, String>> tags = [
    // Service options
    {'category': 'Service options', 'feature': 'Dine-in'},
    {'category': 'Service options', 'feature': 'Takeaway'},
    {'category': 'Service options', 'feature': 'Delivery'},
    {'category': 'Service options', 'feature': 'foodpanda'},
    {'category': 'Service options', 'feature': 'Uber Eats'},
    {'category': 'Service options', 'feature': 'LaLaMove'},
    // Highlights
    {'category': 'Highlights', 'feature': 'Fast service'},
    {'category': 'Highlights', 'feature': 'Fireplace'},
    {'category': 'Highlights', 'feature': 'Great for studing'},
    {'category': 'Highlights', 'feature': 'Great for dine together'},
    {'category': 'Highlights', 'feature': 'Nice service'},
    {'category': 'Highlights', 'feature': 'Muslim Friendly Restaurant'},
    {'category': 'Highlights', 'feature': 'Free drinks'},
    {'category': 'Highlights', 'feature': 'Free soups'},
    {'category': 'Highlights', 'feature': 'Bar on site'},
    {'category': 'Highlights', 'feature': 'Toilets'},
    {'category': 'Highlights', 'feature': 'Special offers(優惠)'},
    // Accessibility
    {'category': 'Accessibility', 'feature': 'Wheelchair-accessible car park'},
    {'category': 'Accessibility', 'feature': 'Wheelchair-accessible entrance'},
    {'category': 'Accessibility', 'feature': 'Wheelchair-accessible lift'},
    {'category': 'Accessibility', 'feature': 'Wheelchair-accessible seating'},
    {'category': 'Accessibility', 'feature': 'Wheelchair-accessible toilet'},
    // Offerings
    {'category': 'Offerings', 'feature': 'Vegetarian options'},
    {'category': 'Offerings', 'feature': 'Ramen'},
    {'category': 'Offerings', 'feature': 'Japanese meals'},
    {'category': 'Offerings', 'feature': 'Ti-styled Japanese food'},
    {'category': 'Offerings', 'feature': 'Italian meals'},
    {'category': 'Offerings', 'feature': 'Ti-styled Italian food'},
    {'category': 'Offerings', 'feature': 'Rice dishes'},
    {'category': 'Offerings', 'feature': 'Noodle dishes'},
    {'category': 'Offerings', 'feature': 'Cafeteria dishes(自助餐)'},
    {'category': 'Offerings', 'feature': 'Chinese breakfast foods(中式早餐)'},
    {'category': 'Offerings', 'feature': 'Fast foods'},
    {'category': 'Offerings', 'feature': 'Beer'},
    {'category': 'Offerings', 'feature': 'Alchohol'},
    {'category': 'Offerings', 'feature': 'Wine'},
    {'category': 'Offerings', 'feature': 'Cocktail'},
    {'category': 'Offerings', 'feature': 'Coffee'},
    {'category': 'Offerings', 'feature': 'Drinks'},
    {'category': 'Offerings', 'feature': 'Water'},
    // Dining options
    {'category': 'Dining options', 'feature': 'Breakfast'},
    {'category': 'Dining options', 'feature': 'Brunch'},
    {'category': 'Dining options', 'feature': 'Lunch'},
    {'category': 'Dining options', 'feature': 'Dinner'},
    {'category': 'Dining options', 'feature': 'Afternoon tea'},
    {'category': 'Dining options', 'feature': 'Late-night supper(宵夜)'},
    {'category': 'Dining options', 'feature': 'Dessert'},
    // Crowd
    {'category': 'Crowd', 'feature': 'University students'},
    {'category': 'Crowd', 'feature': 'University employees & teachers'},
    {'category': 'Crowd', 'feature': 'Groups'},
    {'category': 'Crowd', 'feature': 'Elders'},
    {'category': 'Crowd', 'feature': 'Family'},
    // Payments
    {'category': 'Payments', 'feature': 'Cash only'},
    {'category': 'Payments', 'feature': 'Credit card'},
    {'category': 'Payments', 'feature': 'EasyCard(悠遊卡)'},
    {'category': 'Payments', 'feature': 'iPASS Card(一卡通)'},
    {'category': 'Payments', 'feature': 'LINE Pay'},
    {'category': 'Payments', 'feature': 'Apple Pay'},
    {'category': 'Payments', 'feature': 'SAMSUNG Pay'},
    {'category': 'Payments', 'feature': 'Google Pay'},
    {'category': 'Payments', 'feature': '街口支付'},
    {'category': 'Payments', 'feature': '悠游付'},
  ];
  List<bool> tagChosen = List.filled(tags.length, true);

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

  // Get image from gallery
  Future<void> _getFromGallery() async {
    List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        imgFiles = pickedFiles.map((pf) => File(pf.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData?>(
      future: _currentLocation(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          currentLocation = snapshot.data;
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Pick pictures
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      // Picture picker button
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: Tooltip(
                          message: "Pick pictures",
                          padding: const EdgeInsets.all(8),
                          verticalOffset: 36,
                          height: 24,
                          textStyle: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          waitDuration: const Duration(seconds: 1),
                          showDuration: const Duration(seconds: 2),
                          child: ElevatedButton(
                            onPressed: () => _getFromGallery(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Icon(Icons.add_a_photo,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Picture previews
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: imgFiles!.length,
                            itemBuilder: (context, int index) {
                              return TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: const Color.fromARGB(
                                            0, 255, 255, 255),
                                        content: Stack(
                                          children: [
                                            // preview image
                                            Center(
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: SizedBox.fromSize(
                                                  size: Size.infinite,
                                                  child: Image.file(
                                                      imgFiles![index],
                                                      filterQuality:
                                                          FilterQuality.high,
                                                      fit: BoxFit.contain),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () =>
                                                    Navigator.pop(context)),
                                            // delete image button
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: MaterialButton(
                                                onPressed: () {
                                                  setState(() => imgFiles!
                                                      .remove(
                                                          imgFiles![index]));
                                                  Navigator.pop(context);
                                                },
                                                color: Colors.white,
                                                splashColor: Colors.greenAccent,
                                                shape: const CircleBorder(),
                                                padding:
                                                    const EdgeInsets.all(18),
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 24,
                                                  color: Colors.pinkAccent,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 16,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        insetPadding: EdgeInsets.zero,
                                        contentPadding: EdgeInsets.zero,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox.fromSize(
                                    size: const Size(60, 60),
                                    child: Image.file(imgFiles![index],
                                        filterQuality: FilterQuality.low,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Restaurant name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
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
                ),
                const SizedBox(height: 10),
                // Restaurant address
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
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
                ),
                const SizedBox(height: 10),
                // Restaurant region
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
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
                ),
                const SizedBox(height: 10),
                // Tags
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 0,
                    children: tags
                        .where((t) => tagChosen[tags.indexOf(t)])
                        .map(
                          (e) => ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.zero,
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.grey)),
                            ),
                            child: Text(
                              "#${e['feature']}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 10),
                // Record Coordinate
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
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
                ),
                const SizedBox(height: 10),
                // Coordinate preview on map
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Center(
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
                ),
                // Send application
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton.icon(
                    onPressed: () {},
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
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
