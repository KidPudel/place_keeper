import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String email;
  final List<GeoPoint> places;

  const AppUser({
    required this.email,
    required this.places,
  });


  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'places': places,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> map) {
    return AppUser(
      email: map['email'] as String,
      places: map['places'] as List<GeoPoint>,
    );
  }
}
