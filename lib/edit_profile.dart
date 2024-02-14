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
      height: MediaQuery.of(context).size.height * 0.35,
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
                  radius: 80.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.account_circle, size: 160.0),foregroundColor: Colors.black,
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
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 60.0),
                child: Text(
                  'Profile',
                  style: TextStyle(color: Colors.white, fontSize: 32.0),
                ),
              ),
            ],
          ),
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
                  const Text('Edit Profile', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  _buildEditableTextField(
                    controller: _firstNameController,
                    label: "First Name",
                  ),
                  _buildEditableTextField(
                    controller: _lastNameController,
                    label: "Last Name",
                  ),
                  _buildEditableTextField(
                    controller: _emailController,
                    label: "Email",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    final FocusNode focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          if (enabled) {
            // Enable editing and focus on the TextField
            setState(() {
              enabled = true;
            });
            focusNode.requestFocus();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            enabled: enabled,
            suffixIcon: enabled
                ? IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  enabled = true;
                });
                focusNode.requestFocus();
              },
            )
                : null,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
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


