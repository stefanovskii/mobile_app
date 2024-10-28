import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class OSMHome extends StatefulWidget {
  final Function(String) onLocationPicked;
  final String userId;

  const OSMHome({Key? key, required this.onLocationPicked, required this.userId}) : super(key: key);

  @override
  State<OSMHome> createState() => _OSMHomeState();
}

class _OSMHomeState extends State<OSMHome> {
  List<LatLng> pinLocations = [];
  LatLng? clickedLocation;
  String locationAddress = "";
  LatLng currentCenter = LatLng(41.9973, 21.4270);
  double currentZoom = 13.0;
  final MapController mapController = MapController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadArchivedLocations();
  }

  Future<void> loadArchivedLocations() async {
    List<String> archives = await getArchivedLocations(widget.userId);

    List<LatLng> coordinates = [];
    for (String address in archives) {
      LatLng? latLng = await geocodeAddress(address);
      if (latLng != null) {
        coordinates.add(latLng);
      }
    }

    setState(() {
      pinLocations = coordinates;
      isLoading = false;
    });
  }

  Future<void> handleSetLocation() async {
    if (clickedLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          clickedLocation!.latitude,
          clickedLocation!.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          String address = "${placemark.street}, ${placemark.locality}, ${placemark.country}";

          widget.onLocationPicked(address);

          setState(() {
            locationAddress = address;
            pinLocations.add(clickedLocation!);
            clickedLocation = null;
          });

          Navigator.pop(context);
        }
      } catch (e) {
        print('Error during reverse geocoding: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose where you are"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: pinLocations.isNotEmpty ? pinLocations.first : currentCenter,
              zoom: currentZoom,
              interactiveFlags: InteractiveFlag.all,
              onTap: (tapPosition, point) {
                setState(() {
                  clickedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: pinLocations.map((location) {
                  return Marker(
                    point: location,
                    builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  );
                }).toList(),
              ),
              if (clickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: clickedLocation!,
                      builder: (ctx) => const Icon(Icons.location_pin, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    setState(() {
                      currentZoom += 1.0;
                      mapController.move(mapController.center, currentZoom);
                    });
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    setState(() {
                      currentZoom -= 1.0;
                      mapController.move(mapController.center, currentZoom);
                    });
                  },
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: clickedLocation != null
                  ? () async {
                await handleSetLocation();
              }
                  : null,
              child: const Text('Set Current Location'),
            ),
          ),
          if (locationAddress.isNotEmpty)
            Positioned(
              bottom: 60,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: Text(
                  'Picked Location: $locationAddress',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<List<String>> getArchivedLocations(String userId) async {
  List<String> locations = [];
  var userDoc = await FirebaseFirestore.instance
      .collection('users_authenticated')
      .doc(userId)
      .get();

  if (userDoc.exists) {
    locations = List<String>.from(userDoc['favourites']);
  }

  return locations;
}

Future<LatLng?> geocodeAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    print('Geocoding error: $e');
  }
  return null;
}
