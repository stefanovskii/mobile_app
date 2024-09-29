import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Services/profiles_service.dart';
import 'package:project/Models/user_model.dart';

class SearchProfilesScreen extends StatefulWidget {
  @override
  _SearchProfilesScreenState createState() => _SearchProfilesScreenState();
}

class _SearchProfilesScreenState extends State<SearchProfilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchResult = '';
  bool _isSearching = false;
  bool _userFound = false;
  bool _isRequested = false;
  bool _isConnected = false;

  final ProfilesService _profilesService = ProfilesService();

  void _searchUserByUsername(String username) async {
    setState(() {
      _isSearching = true;
      _userFound = false;
      _isRequested = false;
      _isConnected = false;
    });

    UserModel? user = await _profilesService.searchUserByUsername(username);

    if (user != null) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      DocumentSnapshot currentUserDoc = await _profilesService.fetchUserData(currentUser!.uid);
      String currentUsername = currentUserDoc['username'];

      if (currentUser != null) {
        bool isConnected = await _profilesService.areUsersConnected(currentUsername, user.username!);

        setState(() {
          if (isConnected) {
            _searchResult = 'You are already connected with ${user.username}';
            _isConnected = true;
          } else {
            _searchResult = 'Name: ${user.firstName}, Surname: ${user.lastName}';
            _userFound = true;
          }
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        _searchResult = 'User with username $username does not exist.';
        _userFound = false;
        _isSearching = false;
      });
    }
  }

  void _sendConnectionRequest(String username) async {
    try {
      await _profilesService.sendConnectionRequest(username);
      setState(() {
        _isRequested = true;
      });
    } catch (e) {
      setState(() {
        _searchResult = 'Error sending connection request: $e';
      });
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
          'Search Profiles',
          style: TextStyle(color: Color(0xFF163D37), fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF9C9C9C),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  border: InputBorder.none,
                  hintText: 'Search by username',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final username = _searchController.text.trim();
                      if (username.isNotEmpty) {
                        _searchUserByUsername(username);
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _userFound
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Result Card for User
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            radius: 25.0,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                          title: Text(
                            _searchResult,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          subtitle: const Text('Tap connect to send request'),
                        ),
                        const SizedBox(height: 10),
                        if (!_isConnected)
                          ElevatedButton(
                            onPressed: _isRequested
                                ? null
                                : () => _sendConnectionRequest(_searchController.text.trim()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              _isRequested ? 'Requested' : 'Connect',
                              style: const TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : Center(
              child: Text(
                _searchResult,
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

}