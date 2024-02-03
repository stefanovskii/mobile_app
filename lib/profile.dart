import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.4),
        child: AppBar(
          backgroundColor: const Color(0xFF84A59D),
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
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${user.displayName}'),
              Text('Email: ${user.email}'),
              // Add additional user information as needed
            ],
          ),
        ),
      ),
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
        builder: (context) => EditProfilePage(user: user),
      ),
    );
  }
}