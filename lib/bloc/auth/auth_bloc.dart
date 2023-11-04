import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:place_keeper/bloc/auth/auth_event.dart';
import 'package:place_keeper/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(
      const AuthState(status: AuthStatus.signedOut, uid: '', email: '')) {
    on<AuthStateChanges>(_onAuthStateChanges);
    on<SignUp>(_onSignUp);
    on<SignIn>(_onSignIn);
    on<SignOut>(_onSignOut);
  }

  final _auth = FirebaseAuth.instance;

  FutureOr<void> _onAuthStateChanges(AuthStateChanges event,
      Emitter<AuthState> emit) async {
    await emit.forEach(_auth.authStateChanges(), onData: (user) {
      // is logged in
      if (user != null) {
        print("LOGGED IN !!!!! user id = ${user.uid} email ${user.email}");
        return AuthState(
            status: AuthStatus.signedIn, uid: user.uid, email: user.email!);
      } else {
        return const AuthState(status: AuthStatus.signedOut, uid: '', email: '');
      }
    }, onError: (error, stackTrace) {
      return AuthState(status: AuthStatus.error, uid: state.uid, email: state.email);
    },);
  }

  FutureOr<void> _onSignUp(SignUp event,
      Emitter<AuthState> emit) async {
    emit(AuthState(status: AuthStatus.loading, uid: state.uid, email: state.email));
    try {
      // on complete handled by stream of AuthStateChanges
      await _auth.createUserWithEmailAndPassword(email: event.email, password: event.password).then((value) => print("singed up"));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthState(status: AuthStatus.error, uid: state.uid, email: state.email, errorMessage: 'Пароль слишком простой'));
      } else if (e.code == 'email-already-in-use') {
        print("ALREADY IN USE");
        emit(AuthState(status: AuthStatus.error, uid: state.uid, email: state.email, errorMessage: 'Упс, этот email уже занят другим пользователем.'));
      } else {
        print("EEERRRROOORR");
        emit(AuthState(status: AuthStatus.error, uid: state.uid, email: state.email, errorMessage: 'Неправильный email или пароль'));
      }
    }
  }

  FutureOr<void> _onSignIn(SignIn event,
      Emitter<AuthState> emit) async {
    emit(AuthState(status: AuthStatus.loading, uid: state.uid, email: state.email));
    try {
      await _auth.signInWithEmailAndPassword(email: event.email, password: event.password).then((value) => print("singed in"));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthState(status: AuthStatus.error, uid: state.uid, email: state.email, errorMessage: 'Пользователя с таким email не существует'));
      } else if (e.code == 'wrong-password') {
        emit(AuthState(status: AuthStatus.error, uid: state.uid, email: state.email, errorMessage: 'Неправильный пароль'));
      } else {
        emit(AuthState(status: AuthStatus.error, uid: state.uid, email: state.email, errorMessage: 'Неправильный email или пароль'));
      }
    }
  }

  FutureOr<void> _onSignOut(SignOut event,
      Emitter<AuthState> emit) async {
    try {
      await _auth.signOut().then((value) => print("singed out")).onError((error, stackTrace) => print(error.toString()));
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}