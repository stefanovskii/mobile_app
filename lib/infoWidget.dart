// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:location/location.dart';
// import 'info.dart';
//
// class InfoWidget extends StatefulWidget {
//   final Future<void> Function(Info) addInfo;
//
//   const InfoWidget({Key? key, required this.addInfo}) : super(key: key);
//
//   @override
//   _InfoWidgetState createState() => _InfoWidgetState();
// }
//
// class _InfoWidgetState extends State<InfoWidget> {
//   final TextEditingController _locationController = TextEditingController();
//   File? _selectedImage;
//   LocationData? _currentLocation;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             GestureDetector(
//               onTap: _takePicture,
//               child: Container(
//                 padding: EdgeInsets.all(40.0),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF5F5F5),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: _selectedImage == null
//                     ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.camera_alt),
//                     SizedBox(width: 10),
//                     Text(
//                       'Add Photo',
//                       style: TextStyle(fontSize: 18.0),
//                     ),
//                   ],
//                 )
//                     : Image.file(
//                   _selectedImage!,
//                   width: 100,
//                   height: 100,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _locationController,
//               decoration: InputDecoration(
//                 labelText: 'Location',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _getCurrentLocation();
//               },
//               child: Text('Use Current Location'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _saveInfo();
//               },
//               child: Text('Save Info'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _takePicture() async {
//     final imagePicker = ImagePicker();
//     final pickedImage = await imagePicker.pickImage(
//       source: ImageSource.camera,
//       maxWidth: 300,
//     );
//
//     if (pickedImage != null) {
//       setState(() {
//         _selectedImage = File(pickedImage.path);
//       });
//     }
//   }
//
//   void _getCurrentLocation() async {
//     Location locationInstance = Location();
//
//     try {
//       LocationData currentLocation = await locationInstance.getLocation();
//       setState(() {
//         _locationController.text =
//         '${currentLocation.latitude}, ${currentLocation.longitude}';
//       });
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }
//
//
//   void _saveInfo() {
//     if (_selectedImage == null || _locationController.text.isEmpty) {
//       // Handle validation or show an error message
//       return;
//     }
//
//     // Assuming your Location class has a constructor that takes latitude and longitude
//     final List<String> locationParts = _locationController.text.split(', ');
//     final double latitude = double.parse(locationParts[0]);
//     final double longitude = double.parse(locationParts[1]);
//     final CustomLocation location = CustomLocation(latitude: latitude, longitude: longitude);
//
//     widget.addInfo(Info(
//       photo: _selectedImage,
//       location: location,
//     ));
//
//     Navigator.pop(context); // Close the modal bottom sheet
//   }
//
// }
