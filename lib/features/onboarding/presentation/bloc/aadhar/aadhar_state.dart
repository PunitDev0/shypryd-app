part of 'aadhar_bloc.dart';

abstract class AadharState {}

class AadharInitial extends AadharState {}

class AadharLoading extends AadharState {}

class AadharVerifying extends AadharState {} // ✅ Added new verifying state

class AadharSubmitted extends AadharState {}

class AadharOtpSent extends AadharState {
  final String refId;
  AadharOtpSent(this.refId);
}

class AadharVerified extends AadharState {}

class AadharError extends AadharState {
  final String message;
  AadharError(this.message);
}

class AadharDataUpdated extends AadharState {
  final String aadharNumber;
  final List<String> images;
  AadharDataUpdated({required this.aadharNumber, required this.images});
}
