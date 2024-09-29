import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/Models/user_model.dart';
import 'package:project/Screens/AuthScreens/login_screen.dart';
import 'package:project/Screens/AuthScreens/register_screen.dart';
import 'package:project/Screens/Profile/profile.dart';
import 'package:project/Screens/Profile/search_profiles.dart';
import 'package:project/Services/auth_service.dart';
import 'package:project/Constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project/Services/profiles_service.dart';
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
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
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
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfilesService _profilesService = ProfilesService();
  File? _selectedImage;
  String _selectedLocation = '';
  List<String> favorites = [];

  Stream<List<UserModel>> _fetchConnectedUsersPostsAsStream() {
    if (!_authService.isLoggedIn()) {
      return Stream.value([]);
    }

    String userUid = _authService.getCurrentUser()!.uid;
    return _profilesService.fetchConnectedUsersPostsAsStream(userUid);
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
    if (!_authService.isLoggedIn()) {
      _navigateToSignInPage(context);
    }
  }

  bool _isFavorited(String location) {
    return favorites.contains(location);
  }

  Future<void> updateFavorite(String location, bool isFavorited) async {
    String userId = _authService.getCurrentUser()!.uid;
    final userRef = FirebaseFirestore.instance.collection('users_authenticated').doc(userId);

    if (isFavorited) {
      await userRef.update({
        'favourites': FieldValue.arrayUnion([location]),
      });
    } else {
      await userRef.update({
        'favourites': FieldValue.arrayRemove([location]),
      });
    }
  }


  Future<void> _uploadImageToFirebaseStorage() async {
    if (!_authService.isLoggedIn() || _selectedImage == null || _selectedLocation.isEmpty) {
      return;
    }

    String userId = _authService.getCurrentUser()!.uid;
    String imageName = DateTime.now().toString();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('user_images/$userId/$imageName.jpg');
    UploadTask uploadTask = storageReference.putFile(_selectedImage!);

    try {
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        await _profilesService.savePostDataToFirestore(imageUrl, _selectedLocation, DateTime.now(), userId);
      });
    } catch (error) {
      print("Error uploading image: $error");
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
                  icon: const Icon(Icons.settings),
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
                    if (_authService.isLoggedIn()) {
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
                        bottom: 10.0, top: 10.0, left: 15.0, right: 15.0
                    ),
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
                const SizedBox(height: 20),
                StreamBuilder<List<UserModel>>(
                  stream: _fetchConnectedUsersPostsAsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts found from connected users.'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Your friends have no posts.');
                    }

                    List<UserModel> posts = snapshot.data!;

                    var recentPosts = posts.where((post) {
                      if (post.uploadTime != null) {
                        Duration difference = DateTime.now().difference(post.uploadTime!);
                        return difference.inHours <= 24;
                      }
                      return false;
                    }).toList();

                    if (recentPosts.isEmpty) {
                      return const Center(child: Text('Your Friends have no recent posts.'));
                    }

                    return SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentPosts.length,
                        itemBuilder: (context, index) {
                          final post = recentPosts[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 9,),
                                    Text(
                                      post.username ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        post.photoUrl ?? 'No photo available',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 250,
                                      ),
                                      child: Text(
                                        post.location ?? 'No location available',
                                        style: const TextStyle(fontSize: 12.0),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isFavorited(post.location ?? 'No location available')
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_isFavorited(post.location ?? 'No location available')) {
                                        favorites.remove(post.location);
                                        updateFavorite(post.location ?? 'No location', false);
                                      } else {
                                        favorites.add(post.location ?? 'No location available');
                                        updateFavorite(post.location ?? 'No location', true);
                                      }
                                    });
                                  },
                                )

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
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}





