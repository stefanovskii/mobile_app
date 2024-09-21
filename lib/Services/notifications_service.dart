import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Models/notification.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<List<NotificationModel>> fetchNotificationsForUser(String userEmail) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('to', isEqualTo: userEmail)
          .get();

      return snapshot.docs.map((doc) => NotificationModel.fromJson(doc)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<String?> getUsernameForCurrentUser(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users_authenticated').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get('username') as String?;
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return null;
  }

  // Accepting the connection request and updating and deleting the request
  Future<void> acceptConnectionRequest(String fromUsername, String toUsername) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('connection_requests')
          .where('from', isEqualTo: fromUsername)
          .where('to', isEqualTo: toUsername)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _updateConnectedUsers(fromUsername, toUsername);

        await _firestore.collection('connections').add({
          'from': fromUsername,
          'to': toUsername,
          'status': 'accepted',
          'timestamp': FieldValue.serverTimestamp(),
        });
        await _deleteNotification(fromUsername, toUsername);
        // To show text of the accepted request
        await _firestore.collection('notifications').add({
          'from': fromUsername,
          'to': toUsername,
          'message': 'You just accepted the connection request from $fromUsername.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('No connection request found');
      }
    } catch (e) {
      print('Error accepting connection request: $e');
      throw e;
    }
  }

  // Updating the connected_users array when users are connected
  Future<void> _updateConnectedUsers(String fromEmail, String toEmail) async {
    try {

      final toUserSnapshot = await _firestore
          .collection('users_authenticated')
          .where('username', isEqualTo: toEmail)
          .limit(1)
          .get();

      final fromUserSnapshot = await _firestore
          .collection('users_authenticated')
          .where('username', isEqualTo: fromEmail)
          .limit(1)
          .get();

      if (toUserSnapshot.docs.isNotEmpty && fromUserSnapshot.docs.isNotEmpty) {
        final fromUserDoc = fromUserSnapshot.docs.first;
        final toUserDoc = toUserSnapshot.docs.first;
        await toUserDoc.reference.update({
          'connected_users': FieldValue.arrayUnion([fromEmail]),
        });
        await fromUserDoc.reference.update({
          'connected_users': FieldValue.arrayUnion([toEmail]),
        });
      }

    } catch (e) {
      print('Error updating connected_users: $e');
      throw e;
    }
  }
  // Deleting notification after received
  Future<void> _deleteNotification(String fromEmail, String toEmail) async {
    try {
      final notificationSnapshot = await _firestore
          .collection('notifications')
          .where('from', isEqualTo: fromEmail)
          .where('to', isEqualTo: toEmail)
          .limit(1)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        final notificationDoc = notificationSnapshot.docs.first;
        await notificationDoc.reference.delete();
      }
    } catch (e) {
      print('Error deleting notification: $e');
      throw e;
    }
  }


}