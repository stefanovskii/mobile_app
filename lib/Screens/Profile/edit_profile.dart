import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/profiles_service.dart';
import 'package:project/Widgets/custom_app_bar.dart';
import 'package:project/Widgets/editable_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final UserModel userModel;

  const EditProfileScreen({Key? key, required this.user, required this.userModel}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfilesService _profilesService = ProfilesService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<UserModel?> _fetchUserData() {
    return _profilesService.fetchUserProfile(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF84A59D),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF163D37)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Color(0xFF163D37), fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('User not found'));
          } else {
            final userModel = snapshot.data!;
            _firstNameController.text = userModel.firstName!;
            _lastNameController.text = userModel.lastName!;
            _usernameController.text = userModel.username!;

            return Column(
              children: [
                CustomAppBar(userModel: widget.userModel),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change the parameters:',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
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
                              width: 300, // Full-width button
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
            );
          }
        },
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
