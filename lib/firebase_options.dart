// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAfKiN3G3u9bzHK1sW25xmNB4qhEq2Jncg',
    appId: '1:726739577179:web:c267c83ff43f813309527e',
    messagingSenderId: '726739577179',
    projectId: 'place-keeper-c8738',
    authDomain: 'place-keeper-c8738.firebaseapp.com',
    storageBucket: 'place-keeper-c8738.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC81fr1tJLl40nLa5icLeNHQ6OSs3BUjMM',
    appId: '1:726739577179:android:8d7b53b4480bde0209527e',
    messagingSenderId: '726739577179',
    projectId: 'place-keeper-c8738',
    storageBucket: 'place-keeper-c8738.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxTU5OUsiLSm1EAh99atoCrdLaGLuZSNk',
    appId: '1:726739577179:ios:a4a81efcc57d7c3309527e',
    messagingSenderId: '726739577179',
    projectId: 'place-keeper-c8738',
    storageBucket: 'place-keeper-c8738.appspot.com',
    iosBundleId: 'com.iggydev.placeKeeper',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCxTU5OUsiLSm1EAh99atoCrdLaGLuZSNk',
    appId: '1:726739577179:ios:b51a471babfcf8e609527e',
    messagingSenderId: '726739577179',
    projectId: 'place-keeper-c8738',
    storageBucket: 'place-keeper-c8738.appspot.com',
    iosBundleId: 'com.iggydev.placeKeeper.RunnerTests',
  );
}
