import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:place_keeper/firebase_options.dart';
import 'package:place_keeper/internal/application.dart';

void main() async {
  // configured in cli https://www.youtube.com/watch?v=FkFvQ0SaT1I&t=32s
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    Firebase.app();
  }


  runApp(Application());
}
