import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? username;
  String? photoUrl;
  String? location;
  DateTime? uploadTime;
  List<String>? connectedUsers;
  List<String>? favourites;

  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.photoUrl,
    this.location,
    this.uploadTime,
    this.connectedUsers,
    this.favourites
  });

  factory UserModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel();
    }

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      photoUrl: data['photo'] ?? '',
      location: data['location'] ?? '',
      uploadTime: data['uploadTime'] != null
          ? (data['uploadTime'] as Timestamp).toDate()
          : null,
      username: data['username'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      connectedUsers: data['connected_users'] != null
          ? List<String>.from(data['connected_users'])
          : [],
      favourites: data['favourites'] != null
          ? List<String>.from(data['favourites'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'photo': photoUrl,
      'location': location,
      'uploadTime': uploadTime != null ? Timestamp.fromDate(uploadTime!) : null,
      'connected_users': connectedUsers,
      'favourites': favourites,
    };
  }
}
