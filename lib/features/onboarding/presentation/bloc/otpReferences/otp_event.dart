abstract class OtpEvent {}

class SendOtpEvent extends OtpEvent {
  final String phoneNumber;
  final int referenceIndex;

  SendOtpEvent({required this.phoneNumber, required this.referenceIndex});
}

class VerifyOtpEvent extends OtpEvent {
  final String phoneNumber;
  final String otp;
  final int referenceIndex;

  VerifyOtpEvent({
    required this.phoneNumber,
    required this.otp,
    required this.referenceIndex,
  });
}