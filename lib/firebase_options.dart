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
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD2yxwXdEQlo4P2D74D9e6bznQicAPnxGM',
    appId: '1:572804404960:web:8d6ba4e0c4273186be6285',
    messagingSenderId: '572804404960',
    projectId: 'academypro-12',
    authDomain: 'academypro-12.firebaseapp.com',
    storageBucket: 'academypro-12.firebasestorage.app',
    measurementId: 'G-0TLZQKE3W4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAD0Rw581fP45P9UGAEg2YnFQeeQkd1FM0',
    appId: '1:572804404960:android:16cf75f466222d78be6285',
    messagingSenderId: '572804404960',
    projectId: 'academypro-12',
    storageBucket: 'academypro-12.firebasestorage.app',
  );
}