import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import '../utility_components/navigation_drawer.dart';
import '../map_view/search_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng mapCenter =
      LatLng(25.017858117719683, 121.54108662852052); // init center is NTU
  late MapController _mapController;
  late LocationData currentLocation;
  bool _centerIsCurrentLocation = false;
  bool _centerIsNTU = true;

  List<Map<String, dynamic>> restaurants = List<Map<String, dynamic>>.from([]);

  // Grab restaurant from Firestore
  Future<void> _getRestaurants() async {
    final ref = FirebaseFirestore.instance.collection('restaurants');
    final snapshot = await ref.get();
    List<Map<String, dynamic>> restaurantList =
        snapshot.docs.map((e) => Map<String, dynamic>.from(e.data())).toList();

    for (int i = 0; i < restaurantList.length; i++) {
      restaurantList[i]['coordinate'] = LatLng(
          restaurantList[i]['coordinate'].latitude,
          restaurantList[i]['coordinate'].longitude);
    }
    setState(() => restaurants = restaurantList);
  }

  @override
  void initState() {
    _getRestaurants();
    _mapController = MapController();
    super.initState();
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

  @override
  Widget build(context) {
    return FutureBuilder<LocationData?>(
      future: _currentLocation(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          currentLocation = snapshot.data;
          // Get location chosen from SearchPage
          final args = (ModalRoute.of(context)?.settings.arguments ??
              <String, dynamic>{}) as Map<String, dynamic>;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fastfood),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "NTU Food Map",
                        style: GoogleFonts.sofia(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            drawer: const MyNavigationDrawer(),
            body: Center(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onPositionChanged: (position, hasGesture) => setState(
                    () {
                      _centerIsCurrentLocation = (position.center ==
                          LatLng(currentLocation.latitude!,
                              currentLocation.longitude!));
                      _centerIsNTU = (position.center ==
                          LatLng(25.017858117719683, 121.54108662852052));
                    },
                  ),
                  maxZoom: 18,
                  keepAlive: true,
                  center: args['coordinate'] ?? mapCenter,
                  zoom: 16,
                ),
                nonRotatedChildren: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 12),
                      child: Column(
                        verticalDirection: VerticalDirection.down,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Navigate to current location/NTU
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _centerIsCurrentLocation
                                    ? _centerIsNTU
                                        ? {}
                                        : _mapController.move(
                                            LatLng(25.017858117719683,
                                                121.54108662852052),
                                            16)
                                    : _mapController.move(
                                        LatLng(currentLocation.latitude!,
                                            currentLocation.longitude!),
                                        16));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: Icon(
                                _centerIsCurrentLocation
                                    ? Icons.my_location
                                    : _centerIsNTU
                                        ? Icons.school
                                        : Icons.location_searching,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          // Search button
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SearchPage()),
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(18)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                              child:
                                  const Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ],
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
                            anchorPos: AnchorPos.align(AnchorAlign.bottom),
                            builder: (context) => IconButton(
                              onPressed: () {
                                Fluttertoast.showToast(
                                    msg: "Your current location",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                setState(() => _centerIsCurrentLocation = true);
                                _mapController.moveAndRotate(
                                    LatLng(currentLocation.latitude!,
                                        currentLocation.longitude!),
                                    16,
                                    0);
                              },
                              icon: const Icon(
                                Icons.emoji_people,
                                color: Colors.black,
                                shadows: <Shadow>[
                                  Shadow(color: Colors.white, blurRadius: 15.0)
                                ],
                                size: 40,
                              ),
                            ),
                          ),
                          // NTU
                          Marker(
                            point:
                                LatLng(25.017858117719683, 121.54108662852052),
                            width: 80,
                            height: 80,
                            rotate: true,
                            anchorPos: AnchorPos.align(AnchorAlign.center),
                            builder: (context) => IconButton(
                              onPressed: () {
                                Fluttertoast.showToast(
                                    msg: "National Taiwan University",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                _mapController.moveAndRotate(
                                    LatLng(
                                        25.017858117719683, 121.54108662852052),
                                    16,
                                    0);
                              },
                              icon: const Icon(
                                Icons.school,
                                color: Colors.black,
                                shadows: <Shadow>[
                                  Shadow(color: Colors.white, blurRadius: 15.0)
                                ],
                                size: 40,
                              ),
                            ),
                          ),
                        ] +
                        // Restaurants
                        restaurants
                            .map(
                              (res) => Marker(
                                point: res['coordinate'],
                                width: 80,
                                height: 80,
                                rotate: true,
                                anchorPos: AnchorPos.align(AnchorAlign.center),
                                builder: (context) => IconButton(
                                  onPressed: () {
                                    // more response here
                                    Fluttertoast.showToast(
                                        msg: res['name'].toString(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    _mapController.moveAndRotate(
                                        res['coordinate'], 16, 0);
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
                            )
                            .toList(),
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
