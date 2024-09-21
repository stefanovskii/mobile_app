import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class OSMHome extends StatefulWidget {
  final Function(String) onLocationPicked;

  const OSMHome({Key? key, required this.onLocationPicked}) : super(key: key);

  @override
  State<OSMHome> createState() => _OSMHomeState();
}


class _OSMHomeState extends State<OSMHome> {
  String locationaddress = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose where you at"),
      ),
      body: Container(
        height: 1000,
        color: Colors.red,
        child: Center(
            child: OpenStreetMapSearchAndPick(
                center: const LatLong(41.9973, 21.4270),
                buttonColor: Colors.blue,
                buttonText: 'Set Current Location',
                onPicked: (pickedData) {
                  Navigator.pop(context);
                  widget.onLocationPicked(pickedData.addressName);
                  setState(() {
                    locationaddress = pickedData.addressName;
                  });
                })
        ),
      ),
    );
  }
}