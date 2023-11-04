sealed class UsersDbEvent {}

class AddUserToDb extends UsersDbEvent {
  final String uid;
  final String email;
  AddUserToDb({required this.uid, required this.email});
}

class GetUserFromDb extends UsersDbEvent {
  final String uid;
  GetUserFromDb({required this.uid});
}


class AddPlaceToUser extends UsersDbEvent {
  final String uid;
  final double lat;
  final double long;
  AddPlaceToUser({required this.uid, required this.lat, required this.long});
}

class DeletePlaceFromUser extends UsersDbEvent {
  final String uid;
  final double lat;
  final double long;
  final String decodedPlace;
  DeletePlaceFromUser({required this.uid, required this.lat, required this.long, required this.decodedPlace});
}

class SignOutFromDb extends UsersDbEvent {}