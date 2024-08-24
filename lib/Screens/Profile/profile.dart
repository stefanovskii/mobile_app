import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Widgets/custom_app_bar.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF84A59D),
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Back',
            style: TextStyle(color: Colors.white),
          ),
        ),
        flexibleSpace: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 32.0),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomAppBar(user: widget.user),
          const SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('info').doc(widget.user.uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text('No photo taken in the last 24h.');
              }

              var infoData = snapshot.data!.data() as Map<String, dynamic>?;
              var photoUrl = infoData?['photo'];
              var uploadTime = infoData?['uploadTime'];

              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    photoUrl != null && photoUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        photoUrl,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    )
                        : const Text('No photo taken in the last 24h.'),
                    const SizedBox(height: 10),
                    uploadTime != null
                        ? Text(
                      'Last Upload Time: ${uploadTime.toDate().toString()}',
                      style: const TextStyle(fontSize: 16.0),
                    )
                        : const Text('No upload time available'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }



}
