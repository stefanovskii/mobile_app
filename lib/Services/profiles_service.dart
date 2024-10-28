import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Models/user_model.dart';

class ProfilesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //MainScreen - fetching the posts from logged in user
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

  //MainScreen - saving the data in firebase
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

  //FavouritesScreen - adding the archives in firebase
  Future<void> addToArchives(String userId, String favourite) async {
    DocumentReference userDoc = _firestore.collection('users_authenticated').doc(userId);

    await userDoc.update({
      'archives': FieldValue.arrayUnion([favourite]),
      'favourites': FieldValue.arrayRemove([favourite])
    });
  }

  //ArchivesScreen - fetcing the archives from firebase
  Future<List<String>> fetchArchivedLocations(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users_authenticated').doc(userId).get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return List<String>.from(userData['archives'] ?? []);
    }

    return [];
  }

  //ArchivesScreen - removing elements from archives
  Future<void> removeFromArchives(String userId, String archive) async {
    DocumentReference userDoc = _firestore.collection('users_authenticated').doc(userId);

    await userDoc.update({
      'archives': FieldValue.arrayRemove([archive]),
    });
  }


  //ProfileScreen - fetching the connected users
  Future<Map<String, dynamic>> fetchConnectedUsers(User user) async {
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
      List<dynamic> connectedEmails = (data != null && data['connected_users'] != null)
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
  //EditProfileScreen - for fetching the data of the user(firstName, lastName, username)
  //FavouritesScreen - for fetching the data of the user(favourites)
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

  //EditProfileScreen - updating the user parameters in Firebase
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

  //SearchScreen - checking whether the users are already connected
  Future<bool> areUsersConnected(String currentUserUsername, String targetUserUsername) async {
    if(currentUserUsername == targetUserUsername){
      print('You are already connected with that username');
      return true;
    }
    else {
      final currentUserSnapshot = await getUserByUsername(currentUserUsername);
      Map<String, dynamic>? data = currentUserSnapshot.data() as Map<
          String,
          dynamic>?;
      List<dynamic> connectedEmails = (data != null && data['connected_users'] != null)
          ? data['connected_users'] as List<dynamic>
          : [];
      return connectedEmails.contains(targetUserUsername);
    }
  }


  //SearchScreen - searching the username of the user that will be send the request
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

  //SearchScreen - sending connection request to another user
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

    await _firestore.collection('notifications').add({
      'to': userDoc.username,
      'from': currentUsername,
      'type': 'connection_request',
      'message': '$currentUsername sent you a connection request.',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  //SearchScreen - getting the username of the user needed for checking user if users are connected
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

  //Method used by other methods
  Future<DocumentSnapshot> fetchUserData(String uid) async {
    try {
      return await _firestore.collection('users_authenticated').doc(uid).get();
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }
}