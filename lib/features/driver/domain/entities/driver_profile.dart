import 'package:equatable/equatable.dart';

// ────────────────────────────────────────────────
// Main DriverProfile Entity
// ────────────────────────────────────────────────
class DriverProfile extends Equatable {
  final String id;
  final String phone;
  final bool isPhoneVerified;
  final String lastLoginAt;
  final bool personalInfoCompleted;
  final bool aadhaarInfoCompleted;
  final bool panInfoCompleted;
  final bool bankInfoCompleted;
  final bool isProfileCompleted;
  final String status;
  final bool userAgreement;
  final bool isOnline;
  final int rating;
  final int totalTrips;
  final int walletBalance;
  final String createdAt;
  final String updatedAt;

  // Nested objects
  final PersonalInformation? personalInformation;
  final AadhaarVerification? aadhaarVerification;
  final PanVerification? panVerification;
  final BankDetails? bankDetails;

  // Extra field from API response
  final String? swapStatus;

  const DriverProfile({
    required this.id,
    required this.phone,
    required this.isPhoneVerified,
    required this.lastLoginAt,
    required this.personalInfoCompleted,
    required this.aadhaarInfoCompleted,
    required this.panInfoCompleted,
    required this.bankInfoCompleted,
    required this.isProfileCompleted,
    required this.status,
    required this.userAgreement,
    required this.isOnline,
    required this.rating,
    required this.totalTrips,
    required this.walletBalance,
    required this.createdAt,
    required this.updatedAt,
    this.personalInformation,
    this.aadhaarVerification,
    this.panVerification,
    this.bankDetails,
    this.swapStatus,
  });

  @override
  List<Object?> get props => [
        id,
        phone,
        isPhoneVerified,
        lastLoginAt,
        personalInfoCompleted,
        aadhaarInfoCompleted,
        panInfoCompleted,
        bankInfoCompleted,
        isProfileCompleted,
        status,
        userAgreement,
        isOnline,
        rating,
        totalTrips,
        walletBalance,
        createdAt,
        updatedAt,
        personalInformation,
        aadhaarVerification,
        panVerification,
        bankDetails,
        swapStatus,
      ];
}

// ────────────────────────────────────────────────
// Nested Classes (with factory constructors)
// ────────────────────────────────────────────────

class PersonalInformation extends Equatable {
  final String? fullName;
  final String? gender;
  final String? serviceRegion;
  final String? currentFullAddress;
  final EmergencyReference? emergencyReference1;
  final EmergencyReference? emergencyReference2;
  final String? zone;

  const PersonalInformation({
    this.fullName,
    this.gender,
    this.serviceRegion,
    this.currentFullAddress,
    this.emergencyReference1,
    this.emergencyReference2,
    this.zone,
  });

  factory PersonalInformation.fromJson(Map<String, dynamic> json) {
    return PersonalInformation(
      fullName: json['fullName'] as String?,
      gender: json['gender'] as String?,
      serviceRegion: json['serviceRegion'] as String?,
      currentFullAddress: json['currentFullAddress'] as String?,
      emergencyReference1: json['emergencyReference1'] != null
          ? EmergencyReference.fromJson(json['emergencyReference1'])
          : null,
      emergencyReference2: json['emergencyReference2'] != null
          ? EmergencyReference.fromJson(json['emergencyReference2'])
          : null,
      zone: json['zone'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        gender,
        serviceRegion,
        currentFullAddress,
        emergencyReference1,
        emergencyReference2,
        zone,
      ];
}

class EmergencyReference extends Equatable {
  final String? referenceName;
  final String? referenceRelation;
  final String? referencePhoneNumber;

  const EmergencyReference({
    this.referenceName,
    this.referenceRelation,
    this.referencePhoneNumber,
  });

  factory EmergencyReference.fromJson(Map<String, dynamic> json) {
    return EmergencyReference(
      referenceName: json['referenceName'] as String?,
      referenceRelation: json['referenceRelation'] as String?,
      referencePhoneNumber: json['referencePhoneNumber'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [referenceName, referenceRelation, referencePhoneNumber];
}

class AadhaarVerification extends Equatable {
  final String? aadhaarNumber;
  final String? aadhaarFrontImage;
  final String? aadhaarBackImage;

  const AadhaarVerification({
    this.aadhaarNumber,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
  });

  factory AadhaarVerification.fromJson(Map<String, dynamic> json) {
    return AadhaarVerification(
      aadhaarNumber: json['aadhaarNumber'] as String?,
      aadhaarFrontImage: json['aadhaarFrontImage'] as String?,
      aadhaarBackImage: json['aadhaarBackImage'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [aadhaarNumber, aadhaarFrontImage, aadhaarBackImage];
}

class PanVerification extends Equatable {
  final String? panNumber;
  final String? dateOfBirth;
  final String? panCardImage;

  const PanVerification({
    this.panNumber,
    this.dateOfBirth,
    this.panCardImage,
  });

  factory PanVerification.fromJson(Map<String, dynamic> json) {
    return PanVerification(
      panNumber: json['panNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      panCardImage: json['panCardImage'] as String?,
    );
  }

  @override
  List<Object?> get props => [panNumber, dateOfBirth, panCardImage];
}

class BankDetails extends Equatable {
  final String? bankName;
  final String? accountNumber;
  final String? confirmAccountNumber;
  final String? ifscCode;

  const BankDetails({
    this.bankName,
    this.accountNumber,
    this.confirmAccountNumber,
    this.ifscCode,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      confirmAccountNumber: json['confirmAccountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [bankName, accountNumber, confirmAccountNumber, ifscCode];
}
