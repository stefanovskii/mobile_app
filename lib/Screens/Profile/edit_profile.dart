import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Widgets/custom_app_bar.dart';
import 'package:project/Widgets/editable_text_field.dart';

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
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('info').doc(widget.user.uid).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        String displayName = data['displayName'] ?? '';
        List<String> nameParts = displayName.split(" ");
        String firstName = nameParts.isNotEmpty ? nameParts.first : '';
        String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : '';

        // Update controllers
        setState(() {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
          _emailController.text = data['email'] ?? widget.user.email ?? '';
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 60.0),
              child: Text(
                'Edit Profile',
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
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomAppBar(user: widget.user),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Edit Profile', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  EditableTextField(
                    controller: _firstNameController,
                    label: "First Name",
                  ),
                  EditableTextField(
                    controller: _lastNameController,
                    label: "Last Name",
                  ),
                  EditableTextField(
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

  void _saveChanges(BuildContext context) async {
    String fullName = "${_firstNameController.text} ${_lastNameController.text}";

    // Update display name in Firebase Authentication
    await widget.user.updateProfile(displayName: fullName);

    // Update email if it's changed
    if (_emailController.text != widget.user.email) {
      try {
        await widget.user.updateEmail(_emailController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update email: $e")),
        );
        return;
      }
    }

    // Save updated information to Firestore
    await FirebaseFirestore.instance.collection('info').doc(widget.user.uid).update({
      'displayName': fullName,
      'email': _emailController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
    Navigator.pop(context);
  }
}
