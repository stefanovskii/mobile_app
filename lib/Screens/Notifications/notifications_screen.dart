import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('to', isEqualTo: currentUser?.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final String message = notification['message'];
              final String type = notification['type'];
              final String fromEmail = notification['from'];

              return ListTile(
                title: Text(message),
                trailing: type == 'connection_request'
                    ? ElevatedButton(
                  onPressed: () => _acceptConnectionRequest(fromEmail),
                  child: Text('Accept'),
                )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  void _acceptConnectionRequest(String fromEmail) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    // Update the connection request status
    final requestSnapshot = await FirebaseFirestore.instance
        .collection('connection_requests')
        .where('from', isEqualTo: fromEmail)
        .where('to', isEqualTo: currentUser.email)
        .get();

    if (requestSnapshot.docs.isNotEmpty) {
      final requestDoc = requestSnapshot.docs.first;
      await requestDoc.reference.update({'status': 'accepted'});
    }

    // Fetch the 'to' user's document
    final toUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (toUserSnapshot.docs.isNotEmpty) {
      final toUserDoc = toUserSnapshot.docs.first;
      // Add 'fromEmail' to the 'to' user's 'connected_users'
      await toUserDoc.reference.update({
        'connected_users': FieldValue.arrayUnion([fromEmail]),
      });
    }

    // Fetch the 'from' user's document
    final fromUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: fromEmail)
        .get();

    if (fromUserSnapshot.docs.isNotEmpty) {
      final fromUserDoc = fromUserSnapshot.docs.first;
      // Add current user's email to the 'from' user's 'connected_users'
      await fromUserDoc.reference.update({
        'connected_users': FieldValue.arrayUnion([currentUser.email]),
      });
    }

    // Delete the notification
    final notificationSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('to', isEqualTo: currentUser.email)
        .where('from', isEqualTo: fromEmail)
        .get();

    if (notificationSnapshot.docs.isNotEmpty) {
      final notificationDoc = notificationSnapshot.docs.first;
      await notificationDoc.reference.delete();
    }

    // Optionally: Send a notification that the request was accepted
    await FirebaseFirestore.instance.collection('notifications').add({
      'to': fromEmail,
      'message': '${currentUser.displayName} accepted your connection request.',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
