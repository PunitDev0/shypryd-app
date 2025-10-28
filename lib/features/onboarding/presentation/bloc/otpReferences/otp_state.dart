abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSent extends OtpState {
  final String phoneNumber;
  final int referenceIndex;

  OtpSent({required this.phoneNumber, required this.referenceIndex});
}

class OtpVerified extends OtpState {
  final String phoneNumber;
  final int referenceIndex;

  OtpVerified({required this.phoneNumber, this.referenceIndex = -1});
}

class OtpError extends OtpState {
  final String message;

  OtpError(this.message);
}