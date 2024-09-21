import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Models/notification.dart';
import 'package:project/Services/notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService notificationsService = NotificationsService();
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String? fetchedUsername = await notificationsService.getUsernameForCurrentUser(currentUser.uid);
      setState(() {
        username = fetchedUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: notificationsService.fetchNotificationsForUser(username ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final String message = notification.message ?? '';
              final String type = notification.type ?? '';
              final String fromEmail = notification.from ?? '';
              final String toEmail = notification.to ?? '';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: type == 'connection_request'
                      ? ElevatedButton(
                    onPressed: () {
                      notificationsService.acceptConnectionRequest(
                        fromEmail,
                        toEmail,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

}
