// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAUU7CuXoV-1uSMDzhKwDvuy0ZqWqWGOag',
    appId: '1:655548070875:web:7980a3754bbc72c38e05fe',
    messagingSenderId: '655548070875',
    projectId: 'game-store-app-12f95',
    authDomain: 'game-store-app-12f95.firebaseapp.com',
    storageBucket: 'game-store-app-12f95.firebasestorage.app',
    measurementId: 'G-NEGHH2M0H7',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD6QpKQoexbjgo_ieCs0HM8uX2UP7DPpzc',
    appId: '1:655548070875:ios:838bdde9acad94848e05fe',
    messagingSenderId: '655548070875',
    projectId: 'game-store-app-12f95',
    storageBucket: 'game-store-app-12f95.firebasestorage.app',
    iosBundleId: 'com.example.auto_store',
  );
}
