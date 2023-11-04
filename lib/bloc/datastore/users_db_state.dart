import 'package:cloud_firestore/cloud_firestore.dart';

enum UsersDbStatus { loading, loaded, error, none }

extension CompareUsersDbStatus on UsersDbStatus {
  bool get isLoaded {
    return this == UsersDbStatus.loaded;
  }

  bool get isLoading {
    return this == UsersDbStatus.loading;
  }

  bool get isError {
    return this == UsersDbStatus.error;
  }
  bool get isNone {
    return this == UsersDbStatus.none;
  }
}


class UsersDbState {
  final UsersDbStatus status;
  final List<GeoPoint> places;
  final List<String> decodedPlaces;
  UsersDbState({required this.status, required this.places, required this.decodedPlaces});
}