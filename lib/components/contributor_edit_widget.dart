import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ntu_food_map/components/navigation_drawer.dart';
import 'package:location/location.dart';

class ContributeEditWidget extends StatefulWidget {
  const ContributeEditWidget({super.key});

  @override
  State<ContributeEditWidget> createState() => _ContributeEditWidgetState();
}

class _ContributeEditWidgetState extends State<ContributeEditWidget> {
  String dropdownValue = "公館";
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

  @override
  Widget build(context) {
    return FutureBuilder<LocationData?>(
      future: _currentLocation(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          currentLocation = snapshot.data;
          return Center(
            child: Column(
              children: [
                // Restaurant name
                const SizedBox(height: 50),
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
                const SizedBox(height: 30),
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
                      TextButton(
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
                        onPressed: () {},
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
                const SizedBox(
                  height: 10,
                ),
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
