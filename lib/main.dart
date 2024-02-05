import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'profile.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/login': (context) => const AuthScreen(isLogin: true),
        '/register': (context) => const AuthScreen(isLogin: false),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithFirebase() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      print("User logged in: ${userCredential.user?.uid}");
    } catch (e) {
      print("Error during login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Add your notification icon onPressed logic here
            },
          ),
          // Login Button
          Spacer(),
          StreamBuilder(
            stream: _auth.authStateChanges(),
            builder: (context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                User? user = snapshot.data;

                // Display different icon based on login status
                return user != null
                    ? IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: () {
                          _navigateToProfile(context, user);
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () {
                          _navigateToSignInPage(context);
                        },
                      );
              } else {
                // Return a loading indicator while waiting for auth state
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // First Section
          Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFFA4C2BA),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Share your favorite sit-down spots.',
                  style: TextStyle(fontSize: 24.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Connect with your friends easily here and outside',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    // Add your logic for the clickable box here
                  },
                  child: Container(
                    width: 350.0,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Share where are you...',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 24.0,
                            ),
                            SizedBox(width: 10.0), // Adjust the spacing between icons
                            Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 24.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // Align to the right
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF84A59D),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Second Section
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Second Section',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  _navigateToSignInPage(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _navigateToProfile(BuildContext context, User user) {
    // Navigate to a new page with the user's profile information
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(user: user),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({super.key, required this.isLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _authAction() async {
    try {
      if (widget.isLogin) {
        // Login logic
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _showSuccessDialog(
            "Login Successful", "You have successfully logged in!");
        _navigateToHome();
      } else {
        // Registration logic
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Additional registration logic
        User? user = _auth.currentUser;
        if (user != null) {
          await user.updateProfile(
              displayName:
                  "${_firstNameController.text} ${_lastNameController.text}");
        }

        _showSuccessDialog(
            "Registration Successful", "You have successfully registered!");
        _navigateToLogin();
      }
    } catch (e) {
      _showErrorDialog(
          "Authentication Error", "Error during authentication: $e");
    }
  }

  void _showSuccessDialog(String title, String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHome() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void _navigateToLogin() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _navigateToRegister() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/register');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLogin)
              const Padding(
                padding: EdgeInsets.only(bottom: 100.0),
                child: Text(
                  "On The Spot",
                  style: TextStyle(
                    color: Color(0xFF84A59D),
                    fontSize: 55.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (!widget.isLogin)
              Column(
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 70.0),
            ),
            ElevatedButton(
              onPressed: _authAction,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF84A59D),
                onPrimary: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(widget.isLogin ? "Log In" : "Register"),
            ),
            if (!widget.isLogin)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF84A59D),
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: const Text('Already have an account? Login'),
                ),
              ),
            if (widget.isLogin)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
              ),
            if (widget.isLogin)
              ElevatedButton(
                onPressed: _navigateToRegister,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF84A59D),
                  onPrimary: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: const Text('Create an account'),
              ),
            TextButton(
              onPressed: _navigateToHome,
              child: const Text('Back to Main Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
