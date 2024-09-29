import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Services/profiles_service.dart';

class FavouritesScreen extends StatefulWidget {
  final User user;
  const FavouritesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final ProfilesService _profilesService = ProfilesService();

  Future<List<String>> _fetchUserData() async {
    UserModel? userModel = await _profilesService.fetchUserProfile(widget.user.uid);
    return userModel?.favourites ?? [];
  }

  Future<void> _addToArchives(String favourite) async {
    try {
      await _profilesService.addToArchives(widget.user.uid, favourite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$favourite added to archives')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF163D37)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Favourites',
          style: TextStyle(color: Color(0xFF163D37), fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 50, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No favourites found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final favourites = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Added places worth to be visited',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: favourites.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () => _addToArchives(favourites[index]),
                        child: const Icon(Icons.star, color: Colors.amber),
                      ),
                      title: Text(favourites[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
