import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Screens/Profile/edit_profile.dart';
import 'package:project/Screens/Profile/profile.dart';
import 'package:project/Screens/Profile/search_profiles.dart';

class CustomDrawer extends StatelessWidget {
  final ValueNotifier<bool> darkModeNotifier;

  CustomDrawer({required this.darkModeNotifier});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menu'),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: FirebaseAuth.instance.currentUser!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: FirebaseAuth.instance.currentUser!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchProfilesScreen(),
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: darkModeNotifier,
            builder: (context, isDarkMode, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (bool value) {
                  darkModeNotifier.value = value;
                },
              );
            },
          ),
          const Spacer(), // Pushes the logout button to the bottom
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _signOut(context); // Call the sign-out method when tapped
            },
          ),
        ],
      ),
    );
  }
}
Future<void> _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(context, '/login');
}
