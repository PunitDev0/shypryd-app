part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPhoneSent extends AuthState {
  final User user;

  const AuthPhoneSent(this.user);

  @override
  List<Object> get props => [user];
}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isNewUser;

  const AuthAuthenticated(this.user,{this.isNewUser = false});

  @override
  List<Object> get props => [user, isNewUser];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

