import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _searchUserByUsername(String username) async {
    setState(() {
      _isSearching = true;
      _userFound = false;
      _isRequested = false;
      _isConnected = false;
    });

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDoc = querySnapshot.docs.first;
      var userData = userDoc.data();

      // Fetch the current user's document
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        var currentUserData = currentUserDoc.data() as Map<String, dynamic>;
        List<dynamic> connectedUsers = currentUserData['connected_users'] ?? [];

        // Check if the user is already connected
        if (connectedUsers.contains(userData['username'])) {
          setState(() {
            _searchResult = 'You are already connected with ${userData['username']}';
            _userFound = true;
            _isSearching = false;
            _isConnected = true;
          });
        } else {
          setState(() {
            _searchResult = 'Name: ${userData['firstName']}, Surname: ${userData['lastName']}';
            _userFound = true;
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _searchResult = 'Current user not found.';
          _userFound = false;
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
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    // Fetch the user's email from Firestore using the provided username
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDoc = querySnapshot.docs.first;
      var userData = userDoc.data();
      var email = userData['email'];

      // Add connection request to Firestore
      await FirebaseFirestore.instance.collection('connection_requests').add({
        'from': currentUser.email,
        'to': email,
        'status': 'pending',
      });

      // Notify user
      await FirebaseFirestore.instance.collection('notifications').add({
        'to': email,
        'from': currentUser.email,
        'type': 'connection_request',
        'message': '${currentUser.displayName} sent you a connection request.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isRequested = true;
      });
    } else {
      // Handle case where the username does not exist
      setState(() {
        _searchResult = 'User with username $username does not exist.';
        _isRequested = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Profiles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    final username = _searchController.text.trim();
                    if (username.isNotEmpty) {
                      _searchUserByUsername(username);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isSearching
                ? CircularProgressIndicator()
                : _userFound
                ? Column(
              children: [
                Text(_searchResult),
                SizedBox(height: 20),
                if (!_isConnected) // Only show the button if not connected
                  ElevatedButton(
                    onPressed: _isRequested
                        ? null
                        : () => _sendConnectionRequest(_searchController.text.trim()),
                    child: Text(_isRequested ? 'Requested' : 'Connect'),
                  ),
              ],
            )
                : Text(_searchResult),
          ],
        ),
      ),
    );
  }
}
