part of 'onboarding_bloc.dart';

enum OnboardingStep {
  personalInfo,
  aadhaar,
  pan,
  bank,
  agreement,
}

abstract class OnboardingEvent {}

class SubmitPersonalDetails extends OnboardingEvent {
  final String fullName;
  final String gender;
  final String address;
  final String serviceRegion;
  final List<Map<String, dynamic>>
      references; // Updated to include name, relation, number

  SubmitPersonalDetails({
    required this.fullName,
    required this.gender,
    required this.address,
    required this.serviceRegion,
    this.references = const [],
  });
}

class SubmitAadhaarDetails extends OnboardingEvent {
  final String aadhaarNumber;

  SubmitAadhaarDetails({required this.aadhaarNumber});
}

class SubmitPanDetails extends OnboardingEvent {
  final String panNumber;

  SubmitPanDetails({required this.panNumber});
}

class SubmitBankDetails extends OnboardingEvent {
  final String bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;

  SubmitBankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
  });
}

class SubmitAgreement extends OnboardingEvent {}

class DataEntered extends OnboardingEvent {
  final OnboardingStep step;

  DataEntered(this.step);
}
