enum AuthStatus { signedOut, signedIn, loading, error }

extension CompareAuthStatus on AuthStatus {
  bool get isSignedOut {
    return this == AuthStatus.signedOut;
  }

  bool get isSignedIn {
    return this == AuthStatus.signedIn;
  }

  bool get isLoading {
    return this == AuthStatus.loading;
  }

  bool get isError {
    return this == AuthStatus.error;
  }
}

class AuthState {
  final AuthStatus status;
  final String uid;
  final String email;
  final String? errorMessage;
  const AuthState({required this.status, required this.uid, required this.email, this.errorMessage});
}
