part of 'aadhar_bloc.dart';

abstract class AadharEvent {}

class AadharNumberChanged extends AadharEvent {
  final String aadharNumber;
  AadharNumberChanged(this.aadharNumber);
}

class AadharImagePicked extends AadharEvent {
  final int index; // 0 = front, 1 = back
  final String imagePath;
  AadharImagePicked({required this.index, required this.imagePath});
}

class SubmitAadharDetails extends AadharEvent {
  final String aadharNumber;
  final List<String> images;
  SubmitAadharDetails({
    required this.aadharNumber,
    required this.images,
  });
}

class VerifyAadharOtp extends AadharEvent {
  final String refId;
  final String otp;
  VerifyAadharOtp({required this.refId, required this.otp});
}
