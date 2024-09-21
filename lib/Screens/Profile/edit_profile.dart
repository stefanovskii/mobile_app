import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/profiles_service.dart';
import 'package:project/Widgets/custom_app_bar.dart';
import 'package:project/Widgets/editable_text_field.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  final UserModel userModel;

  const EditProfilePage({Key? key, required this.user, required this.userModel}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfilesService _profilesService = ProfilesService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await _profilesService.fetchUserData(widget.user.uid);
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          _firstNameController.text = data['firstName'];
          _lastNameController.text = data['lastName'];
          _usernameController.text = data['username'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF84A59D),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          CustomAppBar(userModel: widget.userModel),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change the parameters:',
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24.0),
                    EditableTextField(
                      controller: _firstNameController,
                      label: "First Name",
                    ),
                    const SizedBox(height: 16.0),
                    EditableTextField(
                      controller: _lastNameController,
                      label: "Last Name",
                    ),
                    const SizedBox(height: 16.0),
                    EditableTextField(
                      controller: _usernameController,
                      label: "Username",
                    ),
                    const SizedBox(height: 32.0),
                    Center(
                      child: SizedBox(
                        width: 300,  // Full-width button
                        child: ElevatedButton(
                          onPressed: () {
                            _saveChanges(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }

  void _saveChanges(BuildContext context) async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String username = _usernameController.text;

    try {
      widget.userModel.firstName = firstName;
      widget.userModel.lastName = lastName;
      widget.userModel.username = username;
      await _profilesService.updateUserProfile(widget.userModel);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

}
