import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ntu_food_map/components/navigation_dradwer.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    final _mapController = MapController();
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
      body: Center(
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(25.017, 121.538),
            zoom: 16,
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ],
        ),
      ),
    );
  }
}
