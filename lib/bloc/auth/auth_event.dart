sealed class AuthEvent {}

class AuthStateChanges extends AuthEvent {}

class SignUp extends AuthEvent {
  final String email;
  final String password;
  SignUp({required this.email, required this.password});
}

class SignIn extends AuthEvent {
  final String email;
  final String password;
  SignIn({required this.email, required this.password});
}

class SignOut extends AuthEvent {}