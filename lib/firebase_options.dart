import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
  // ======================================================
  // THÔNG TIN CẤU HÌNH WEB
  // ======================================================
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNqWS2HeyHXnnToCv33DP8DtuS09gHSgc',
    appId: '1:554337408717:web:2828b382fa11b3aaf5fb84',
    messagingSenderId: '554337408717',
    projectId: 'myflutter1-94298',
    authDomain: 'myflutter1-94298.firebaseapp.com',
    storageBucket: 'myflutter1-94298.firebasestorage.app',
    measurementId: 'G-C58F0DRY49',
  );

  // ======================================================
  // CẤU HÌNH ANDROID
  // ======================================================
  static const FirebaseOptions android = FirebaseOptions(
    // Đã cập nhật từ "current_key"
    apiKey: 'AIzaSyAQhn8oSx9cnCtbnJ6YmRStpRRm1RuAhNo',
    // Đã cập nhật từ "mobilesdk_app_id"
    appId: '1:554337408717:android:c9a06f26c94f7c20f5fb84',
    messagingSenderId: '554337408717',
    projectId: 'myflutter1-94298',
    storageBucket: 'myflutter1-94298.firebasestorage.app',
  );
}

