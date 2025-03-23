enum AuthenticationStatus {
  initial,
  authenticating,
  authenticated,
  error
}

// class AuthState {
//   const AuthState({
//     this.status = AuthenticationStatus.initial,
//     this.errorMessage,
//     this.userData,
//   });
//
//   final AuthenticationStatus status;
//   final String? errorMessage;
//   final Map<String, dynamic>? userData;
//
//   AuthState copyWith({
//     AuthenticationStatus? status,
//     String? errorMessage,
//     Map<String, dynamic>? userData,
//   }) => AuthState(
//       status: status ?? this.status,
//       errorMessage: errorMessage ?? this.errorMessage,
//       userData: userData ?? this.userData,
//     );
//
//   bool get isAuthenticated => status == AuthenticationStatus.authenticated;
//   bool get isAuthenticating => status == AuthenticationStatus.authenticating;
//   bool get hasError => status == AuthenticationStatus.error;
// }
