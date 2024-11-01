import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Constants/app_colors.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/profiles_service.dart';
import 'package:project/Widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfilesService _profilesService = ProfilesService();

  Future<Map<String, dynamic>> _fetchConnectedUsers() {
    return _profilesService.fetchConnectedUsers(widget.user);
  }

  Widget _buildConnectedUserCard(String username) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey,
            child: Text(
              username[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            username,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLatestPost(UserModel userProfile) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty
                ? Image.network(
              userProfile.photoUrl!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.photo, size: 100, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${userProfile.location ?? "Unknown"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Upload: ${userProfile.uploadTime?.toString() ?? "No upload time available"}',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.titles),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.titles, fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchConnectedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading profile data.'));
          }

          UserModel? userProfile = snapshot.data?['userProfile'];
          if (userProfile == null) {
            return const Center(child: Text('User profile not found.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(userModel: userProfile),
                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Connected Users',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                (userProfile.connectedUsers?.isNotEmpty ?? false)
                    ? SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: userProfile.connectedUsers?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _buildConnectedUserCard(userProfile.connectedUsers![index]);
                    },
                  ),
                )
                    : const Center(child: Text('No connected users yet.')),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Latest Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _buildLatestPost(userProfile),
              ],
            ),
          );
        },
      ),
    );
  }
}
