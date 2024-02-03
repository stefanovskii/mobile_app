import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user information
    _firstNameController.text = widget.user.displayName?.split(" ").first ?? "";
    _lastNameController.text = widget.user.displayName?.split(" ").last ?? "";
    _emailController.text = widget.user.email ?? "";
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      color: const Color(0xFF84A59D),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
              children: [
                CircleAvatar(
                  radius: 60.0,
                  child: Icon(Icons.account_circle, size: 120.0),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              '${_firstNameController.text} ${_lastNameController.text}',
              style: const TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF84A59D),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                _saveChanges(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Edit Profile', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _saveChanges(BuildContext context) {
    // Implement logic to save changes
    String fullName = "${_firstNameController.text} ${_lastNameController.text}";

    // Update user information in Firestore or any other backend
    // For simplicity, updating only the display name here
    widget.user.updateProfile(displayName: fullName);

    // Navigate back to the ProfilePage
    Navigator.pop(context);
  }
}


