import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore getFirestoreInstance() {
    return _firestore;
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  Future<UserCredential> register(String email, String password, String firstName, String lastName, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );

      await _firestore.collection('users_authenticated').doc(userCredential.user!.uid).set(userModel.toMap()..['created_at'] = FieldValue.serverTimestamp());

      return userCredential;
    } catch (e) {
      print("Registration Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }


  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users_authenticated').doc(user.uid).delete();
      await user.delete();
      await signOut();
    }
  }

  Future<bool> isAlreadySignedIn() async {
    return _auth.currentUser != null;
  }
}
