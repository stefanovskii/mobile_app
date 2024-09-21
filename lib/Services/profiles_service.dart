import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Models/user_model.dart';

class ProfilesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> fetchConnectedUsersPostsAsStream(String userUid) {
    return _firestore
        .collection('users_authenticated')
        .doc(userUid)
        .snapshots()
        .asyncMap((userDoc) async {
      List<dynamic> connectedEmails = userDoc.data()?['connected_users'] ?? [];

      if (connectedEmails.isEmpty) {
        return [];
      }

      QuerySnapshot usersSnapshot = await _firestore
          .collection('users_authenticated')
          .where('username', whereIn: connectedEmails)
          .get();

      List<String> connectedUids = usersSnapshot.docs.map((doc) => doc.id).toList();

      QuerySnapshot postsSnapshot = await _firestore
          .collection('users_authenticated')
          .where(FieldPath.documentId, whereIn: connectedUids)
          .get();

      return postsSnapshot.docs.map((doc) => UserModel.fromJson(doc)).toList();
    });
  }

  Future<void> savePostDataToFirestore(
      String imageUrl, String location, DateTime uploadTime, String userUid) async {
    try {
      await _firestore.collection('users_authenticated').doc(userUid).set({
        'photo': imageUrl,
        'location': location,
        'uploadTime': uploadTime,
      }, SetOptions(merge: true));
    } catch (error) {
      print('Error saving post data: $error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUserProfileAndConnectedUsers(User user) async {
    try {
      UserModel userModel = await fetchUserProfile(user.uid);
      DocumentSnapshot userDataDoc = await fetchUserData(user.uid);

      if (!userDataDoc.exists) {
        print('Document does not exist');
        return {
          'userProfile': null,
          'connectedUsernames': [],
          'connectedUsersCount': 0,
        };
      }
      Map<String, dynamic>? data = userDataDoc.data() as Map<String, dynamic>?;
      List<dynamic> connectedEmails = data != null && data.containsKey('connected_users')
          ? data['connected_users'] as List<dynamic>
          : [];

      return {
        'userProfile': userModel,
        'connectedUsernames': connectedEmails,
        'connectedUsersCount': connectedEmails.length,
      };
    } catch (e) {
      print('Error fetching data: $e');
      return {
        'userProfile': null,
        'connectedUsernames': [],
        'connectedUsersCount': 0,
      };
    }
  }

  Future<DocumentSnapshot> fetchUserData(String uid) async {
    try {
      return await _firestore.collection('users_authenticated').doc(uid).get();
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }

  Future<UserModel> fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users_authenticated')
          .doc(uid)
          .get();
      return UserModel.fromJson(doc);
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel userProfile) async {
    try {
      await FirebaseFirestore.instance
          .collection('users_authenticated')
          .doc(userProfile.id)
          .set(userProfile.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

// New method to search for a user by username
  Future<UserModel?> searchUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users_authenticated')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      print('Error searching user by username: $e');
      return null;
    }
  }

  // Method to send a connection request
  Future<void> sendConnectionRequest(String targetUsername) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await searchUserByUsername(targetUsername);
    if (userDoc == null) throw Exception("User not found");
    DocumentSnapshot currentUserDoc = await fetchUserData(currentUser.uid);
    String currentUsername = currentUserDoc['username'];

    await FirebaseFirestore.instance.collection('connection_requests').add({
      'from': currentUsername,
      'to': userDoc.username,
      'status': 'pending',
    });


    // Notify the target user
    await _firestore.collection('notifications').add({
      'to': userDoc.username,
      'from': currentUsername,
      'type': 'connection_request',
      'message': '$currentUsername sent you a connection request.',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Method to check if users are already connected
  Future<bool> areUsersConnected(String currentUserUsername, String targetUserUsername) async {
    final currentUserSnapshot = await getUserByUsername(currentUserUsername);
    Map<String, dynamic>? data = currentUserSnapshot.data() as Map<String, dynamic>?;
    List<dynamic> connectedEmails = data != null && data.containsKey('connected_users')
        ? data['connected_users'] as List<dynamic>
        : [];
    return connectedEmails.contains(targetUserUsername);
  }

  // Fetch user data by email
  Future<DocumentSnapshot> getUserByUsername(String username) async {
    final userSnapshot = await _firestore
        .collection('users_authenticated')
        .where('username', isEqualTo: username)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      return userSnapshot.docs.first;
    } else {
      throw Exception('User not found');
    }
  }
}