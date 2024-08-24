import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/Screens/Profile/auth_screen.dart';
import 'package:project/Themes/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project/Widgets/custom_drawer.dart';
import 'package:project/Widgets/map_widget.dart';
import 'firebase_options.dart';
import 'package:project/Screens/Notifications/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> _darkModeNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
          initialRoute: '/',
          routes: {
            '/': (context) => MyHomePage(darkModeNotifier: _darkModeNotifier),
            '/login': (context) => const AuthScreen(isLogin: true),
            '/register': (context) => const AuthScreen(isLogin: false),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueNotifier<bool> darkModeNotifier;

  MyHomePage({required this.darkModeNotifier});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _selectedImage;
  String _selectedLocation = '';

  Future<List<QueryDocumentSnapshot>> _fetchConnectedUsersPosts() async {
    if (_auth.currentUser == null) {
      return [];
    }

    // Fetch the current user's connected users (emails)
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    List<dynamic> connectedEmails = userDoc['connected_users'] ?? [];

    if (connectedEmails.isEmpty) {
      return []; // Return an empty list if there are no connected users
    }

    // Fetch UIDs for connected emails
    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('email', whereIn: connectedEmails)
        .get();

    List<String> connectedUids = usersSnapshot.docs.map((doc) => doc.id).toList();

    if (connectedUids.isEmpty) {
      return []; // Return an empty list if there are no connected UIDs
    }

    // Fetch posts from the connected users (by UID)
    QuerySnapshot postsSnapshot = await _firestore
        .collection('info')
        .where(FieldPath.documentId, whereIn: connectedUids)
        .get();

    return postsSnapshot.docs;
  }

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 300,
    );

    if (pickedImage == null) {
      return;
    }
    _selectedImage = File(pickedImage.path);
    if (_auth.currentUser == null) {
      _navigateToSignInPage(context);
    }
  }

  Future<void> _uploadImageToFirebaseStorage() async {
    if (_auth.currentUser == null || _selectedImage == null || _selectedLocation.isEmpty) {
      return;
    }

    String userId = _auth.currentUser!.uid;
    String imageName = DateTime.now().toString();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('user_images/$userId/$imageName.jpg');
    UploadTask uploadTask = storageReference.putFile(_selectedImage!);

    try {
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        await _saveDataToFirestore(imageUrl, DateTime.now());
      });
    } catch (error) {
      print("Error uploading image: $error");
    }
  }

  Future<void> _saveDataToFirestore(String imageUrl, DateTime uploadTime) async {
    if (_auth.currentUser != null) {
      await _firestore
          .collection('info')
          .doc(_auth.currentUser!.uid)
          .set({
        'photo': imageUrl,
        'location': _selectedLocation,
        'uploadTime': uploadTime ?? DateTime.now(),
      }, SetOptions(merge: true));

    }
  }

  void _postPicture() {
    if (_selectedImage != null) {
      _uploadImageToFirebaseStorage();
    } else {
      print("No picture selected.");
    }
  }

  void _openProfileDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Main Screen'),
        actions: [
          StreamBuilder(
            stream: _auth.authStateChanges(),
            builder: (context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                User? user = snapshot.data;
                return user != null
                    ? IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    _openProfileDrawer(context);
                  },
                )
                    : IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    _navigateToSignInPage(context);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen()));
            },
          ),
        ],
      ),
      drawer: CustomDrawer(darkModeNotifier: widget.darkModeNotifier),
      body: Column(
        children: [
          // First Section
          Container(
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Share your favorite sit-down spots.',
                  style: TextStyle(fontSize: 24.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5.0),
                const Text(
                  'Connect with your friends easily here and outside',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () {
                    if (_auth.currentUser != null) {
                      _takePicture();
                    } else {
                      _navigateToSignInPage(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Share where are you...',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined),
                              onPressed: _takePicture,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OSMHome(
                                        onLocationPicked: (location) {
                                          setState(() {
                                            _selectedLocation = location;
                                          });
                                        },
                                      )),
                                );
                              },
                              icon: const Icon(Icons.location_on_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                GestureDetector(
                  onTap: _postPicture,
                  child: Container(
                    padding: const EdgeInsets.only(
                        bottom: 10.0, top: 10.0, left: 15.0, right: 15.0),
                    margin: const EdgeInsets.only(left: 293.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Post',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Second Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Friends spots',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchConnectedUsersPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return const Text('Your Friends have no posts.');
                    }

                    // Get the list of documents fetched by _fetchConnectedUsersPosts
                    var docs = snapshot.data!;

                    // Filter documents to show only those uploaded in the last 24 hours
                    var recentDocs = docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      var uploadTime = data['uploadTime']?.toDate();
                      if (uploadTime == null) return false;

                      Duration difference = DateTime.now().difference(uploadTime);
                      return difference.inHours <= 24;
                    }).toList();

                    if (recentDocs.isEmpty) {
                      return const Text('Your Friends have no posts.');
                    }

                    return SizedBox(
                      height: 300, // Set the height of the container to match the height of your images
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Set the scroll direction to horizontal
                        itemCount: recentDocs.length,
                        itemBuilder: (context, index) {
                          var doc = recentDocs[index];
                          var data = doc.data() as Map<String, dynamic>;
                          var photoUrl = data['photo'];
                          var location = data['location'];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0), // Add some horizontal spacing between cards
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Ensures the column takes up only as much vertical space as its children
                              crossAxisAlignment: CrossAxisAlignment.center, // Centers children horizontally
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0), // Optional: for rounded corners
                                  child: Image.network(
                                    photoUrl,
                                    width: 200, // Set desired width
                                    height: 200, // Set desired height
                                    fit: BoxFit.cover, // Use BoxFit.cover to maintain aspect ratio and fill the area
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox.shrink(); // Handle image load errors gracefully
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10), // Add space between image and text
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 250, // Matches the width of the image
                                  ),
                                  child: Text(
                                      location ?? 'No location available',
                                      style: const TextStyle(fontSize: 12.0),
                                      textAlign: TextAlign.center, // Center text alignment
                                      softWrap: true
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSignInPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen(isLogin: true)));
  }
}





