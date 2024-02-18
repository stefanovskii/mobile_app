import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                padding: EdgeInsets.only(left: 8.0),
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
                _signOut(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          leading: TextButton(
            onPressed: () {
              _navigateToEditProfile(context);
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),


        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCustomAppBar(),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('info').doc(widget.user.uid).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const CircularProgressIndicator();
                }

                var infoData = snapshot.data!.data() as Map<String, dynamic>;
                var photoUrl = infoData['photo'];
                var uploadTime = infoData['uploadTime'];

                if (photoUrl != null && photoUrl.isNotEmpty && uploadTime != null) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            photoUrl,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Last Upload Time: ${uploadTime.toDate().toString()}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  );
              } else {
                return const Text('No photos available');
              }
            },
          ),
        ],
        )
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // After signing out, navigate back to the login page
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: widget.user),
      ),
    );
  }
}