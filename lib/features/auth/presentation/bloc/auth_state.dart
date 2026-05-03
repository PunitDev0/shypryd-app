// part of 'auth_bloc.dart';

import 'package:ShipRyd_app/features/auth/data/models/auth_response.dart';
import 'package:equatable/equatable.dart';
import 'package:ShipRyd_app/features/auth/domain/entities/user.dart'; // ← Add this import

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPhoneSent extends AuthState {
  final User? user; // Make optional if you don't always need it

  const AuthPhoneSent([this.user]); // Make parameter optional

  @override
  List<Object> get props => [user ?? ''];
}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isNewUser;
  final bool? onboardingCompleted;
  final AuthResponse authResponse;

  const AuthAuthenticated(
    this.user, {
    this.isNewUser = false,
    this.onboardingCompleted,
    required this.authResponse,
  });

  @override
  List<Object> get props =>
      [user, isNewUser, onboardingCompleted ?? '', authResponse];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
