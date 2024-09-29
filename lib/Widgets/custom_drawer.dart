import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Screens/Profile/edit_profile.dart';
import 'package:project/Screens/Profile/profile.dart';
import 'package:project/Screens/Profile/search_profiles.dart';
import 'package:project/Services/auth_service.dart';
import 'package:project/Services/profiles_service.dart';
import 'package:project/Constants/app_colors.dart';
import 'package:project/Screens/Profile/favourites.dart';
import 'package:project/Screens/settings.dart';

class CustomDrawer extends StatelessWidget {
  final ValueNotifier<bool> darkModeNotifier;

  final AuthService _authService = AuthService();

  CustomDrawer({required this.darkModeNotifier});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 116.0,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(0, -4),
                      child: const Text(
                        'On The Spot',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white
                        ),
                      ),
                      ),
                    ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(0, -12),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: FirebaseAuth.instance.currentUser!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: () async {
              User currentUser = FirebaseAuth.instance.currentUser!;
              ProfilesService profileService = ProfilesService();
              DocumentSnapshot snapshot = await profileService.fetchUserData(currentUser.uid);
              UserModel userModel = UserModel.fromJson(snapshot);

              Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: currentUser, userModel: userModel),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Users',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchProfilesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favourites',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: (){
              User currentUser = FirebaseAuth.instance.currentUser!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavouritesScreen(user: currentUser),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(darkModeNotifier: darkModeNotifier),
                ),
              );
            },
          ),

          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red
              ),
            ),
            onTap: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}


