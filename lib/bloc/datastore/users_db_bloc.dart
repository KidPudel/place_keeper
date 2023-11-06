import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:place_keeper/bloc/datastore/users_db_event.dart';
import 'package:place_keeper/bloc/datastore/users_db_state.dart';
import 'package:place_keeper/data/models/app_user.dart';

class UsersDbBloc extends Bloc<UsersDbEvent, UsersDbState> {
  UsersDbBloc() : super(UsersDbState(status: UsersDbStatus.none, places: [], decodedPlaces: [])) {
    on<GetUserFromDb>(_getUserFromDb);
    on<AddUserToDb>(_addUserToDb);
    on<AddPlaceToUser>(_addPlaceToUser);
    on<DeletePlaceFromUser>(_deletePlaceFromUser);
    on<SignOutFromDb>((event, emit) =>
        emit(UsersDbState(status: UsersDbStatus.none, places: [], decodedPlaces: [])));
  }

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  FutureOr<void> _getUserFromDb(
      GetUserFromDb event, Emitter<UsersDbState> emit) async {
    emit(UsersDbState(status: UsersDbStatus.loading, places: [], decodedPlaces: []));
    try {
      await _usersRef.doc(event.uid).get().then((value) {
        if (!value.exists) {
          throw Exception("user doesnt exists");
        }
        final documentData = value.data() as Map<String, dynamic>;
        final List<GeoPoint> places = List.from(documentData['places'] ?? []);
        final List<String> decodedPlaces = List.from(documentData['decoded_places'] ?? []);
        emit(UsersDbState(status: UsersDbStatus.loaded, places: places, decodedPlaces: decodedPlaces));
      });
    } catch (e) {
      emit(UsersDbState(status: UsersDbStatus.error, places: state.places, decodedPlaces: state.decodedPlaces));
      print("EEEERRRORRR $e");
    }
  }

  FutureOr<void> _addUserToDb(
      AddUserToDb event, Emitter<UsersDbState> emit) async {
    emit(UsersDbState(status: UsersDbStatus.loading, places: [], decodedPlaces: []));
    try {
      // type safe
      final typeSafeUsersRef = _usersRef.withConverter(
          fromFirestore: (snapshot, options) {
            if (!snapshot.exists) {
              throw Exception("user doesnt exits");
            }
            return AppUser.fromJson(snapshot.data()!);
          },
          toFirestore: (users, options) => users.toJson());

      final newUser = AppUser(email: event.email, places: []);

      await typeSafeUsersRef.doc(event.uid).set(newUser).then((value) =>
          emit(UsersDbState(status: UsersDbStatus.loaded, places: [], decodedPlaces: [])));
    } catch (e) {
      emit(UsersDbState(status: UsersDbStatus.error, places: state.places, decodedPlaces: []));
    }
  }

  FutureOr<void> _addPlaceToUser(
      AddPlaceToUser event, Emitter<UsersDbState> emit) async {
    emit(UsersDbState(status: UsersDbStatus.loading, places: state.places, decodedPlaces: state.decodedPlaces));
    try {
      // transactions are the way to ensure that writes operations only occurs on a latest data on the server
      final updatedState =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        final documentReference = _usersRef.doc(event.uid);
        // get uid because called in logged in user
        final userSnapshot = await transaction.get(documentReference);
        if (! userSnapshot.exists) {
          throw Exception("user does not exists");
        }
        final userSnapshotMap =
             userSnapshot.data() as Map<String, dynamic>;
        final List<GeoPoint> updatedPlaces = [
          ...userSnapshotMap['places'],
          GeoPoint(event.lat, event.long)
        ];
        print('before converting');
        final List<String> decodedPlaces = List.from(userSnapshotMap['decoded_places'] ?? []);
        print("AAAAA");
        final List<String> updatedDecodedPlaces = [...decodedPlaces, await _decodePlace(GeoPoint(event.lat, event.long))];

        transaction.update(documentReference, {'places': updatedPlaces, 'decoded_places' : updatedDecodedPlaces});
        return UsersDbState(status: UsersDbStatus.loaded, places: updatedPlaces, decodedPlaces: updatedDecodedPlaces);
      });
      emit(updatedState);
    } catch (e) {
      emit(UsersDbState(status: UsersDbStatus.error, places: state.places, decodedPlaces: state.decodedPlaces));
      print("error while updating user's places $e");
    }
  }

  FutureOr<void> _deletePlaceFromUser(
      DeletePlaceFromUser event, Emitter<UsersDbState> emit) async {
    emit(UsersDbState(status: UsersDbStatus.loading, places: state.places, decodedPlaces: state.decodedPlaces));
    try {
      // ensure the most recent updated places
      final updatedState =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        // get specific user reference
        final userRef = _usersRef.doc(event.uid);

        // ensure the latest
        final ensuredUserRef = await transaction.get(userRef);

        if (!ensuredUserRef.exists) {
          throw Exception("User does not exists");
        }
        final userData = ensuredUserRef.data() as Map<String, dynamic>;
        final List<GeoPoint> updatedPlaces = List.from(userData['places'] ?? [])
          ..removeWhere((element) =>
              element.latitude == event.lat && element.longitude == event.long);

        final List<String> decodedPlaces = List.from(userData['decoded_places']);
        final List<String> updatedDecodedPlaces = List.from(decodedPlaces)..removeWhere((element) => element == event.decodedPlace);

        // update
        transaction.update(userRef, {'places': updatedPlaces, 'decoded_places' : updatedDecodedPlaces});

        return UsersDbState(status: UsersDbStatus.loaded, places: updatedPlaces, decodedPlaces: updatedDecodedPlaces);
      });

      emit(updatedState);
    } catch (e) {
      emit(UsersDbState(status: UsersDbStatus.error, places: state.places, decodedPlaces: state.decodedPlaces));
      print("while deleting place $e");
    }
  }

  Future<String> _decodePlace(GeoPoint place) async {
    print("converting");
    return await placemarkFromCoordinates(place.latitude, place.longitude).then(
            (value) => "Country: ${value[0].country}\nStreet: ${value[0].street}");
  }
}
