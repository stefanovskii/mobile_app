import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Models/notification.dart';
import 'package:project/Services/notifications_service.dart';

class NotificationsScreen extends StatelessWidget {
  final NotificationsService notificationsService = NotificationsService();

  Future<String?> _fetchUsername() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await notificationsService.getUsernameForCurrentUser(currentUser.uid);
    }
    return null;
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
          'Notifications',
          style: TextStyle(color: Color(0xFF163D37), fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: _fetchUsername(),
        builder: (context, usernameSnapshot) {
          if (!usernameSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          String username = usernameSnapshot.data ?? '';

          return FutureBuilder<List<NotificationModel>>(
            future: notificationsService.fetchNotificationsForUser(username),
            builder: (context, notificationsSnapshot) {
              if (!notificationsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = notificationsSnapshot.data ?? [];

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
          );
        },
      ),
    );
  }
}
