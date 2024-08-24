import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBM8kSAznZ9bpSf6BJg3g21U0IsV49tsTA',
    appId: '1:1055845868589:web:3c63945225436155be44a4',
    messagingSenderId: '1055845868589',
    projectId: 'onthespot-37bf8',
    authDomain: 'onthespot-37bf8.firebaseapp.com',
    storageBucket: 'onthespot-37bf8.appspot.com',
    measurementId: 'G-YR6L5W3HNR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQecNuwJDRvpCs5s25gIFMVVGbiSmgUNk',
    appId: '1:1055845868589:android:9aef4d91fca92a3ebe44a4',
    messagingSenderId: '1055845868589',
    projectId: 'onthespot-37bf8',
    storageBucket: 'onthespot-37bf8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7Q2b7dv4q_96rnDnYn0T17L4QhaQIXs0',
    appId: '1:1055845868589:ios:3a8c7fd09d82d9a8be44a4',
    messagingSenderId: '1055845868589',
    projectId: 'onthespot-37bf8',
    storageBucket: 'onthespot-37bf8.appspot.com',
    iosBundleId: 'com.example.project',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7Q2b7dv4q_96rnDnYn0T17L4QhaQIXs0',
    appId: '1:1055845868589:ios:332d73a84f15c2b0be44a4',
    messagingSenderId: '1055845868589',
    projectId: 'onthespot-37bf8',
    storageBucket: 'onthespot-37bf8.appspot.com',
    iosBundleId: 'com.example.project.RunnerTests',
  );
}
