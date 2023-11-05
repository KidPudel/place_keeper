import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:place_keeper/firebase_options.dart';
import 'package:place_keeper/internal/application.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'internal/di/locator.dart';

void main() async {
  // configured in cli https://www.youtube.com/watch?v=FkFvQ0SaT1I&t=32s
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    Firebase.app();
  }

  // inject dependencies
  inject();

  locator.isReady<SharedPreferences>().then((value) {
    runApp(Application());
    FlutterNativeSplash.remove();
  });
}
