import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.phone,
    required super.isPhoneVerified,
    required super.lastLoginAt,
    required super.personalInfoCompleted,
    required super.aadhaarInfoCompleted,
    required super.panInfoCompleted,
    required super.bankInfoCompleted,
    required super.isProfileCompleted,
    required super.status,
    required super.userAgreement,
    required super.isOnline,
    required super.rating,
    required super.totalTrips,
    required super.walletBalance,
    required super.createdAt,
    required super.updatedAt,
    super.personalInformation,
    super.aadhaarVerification,
    super.panVerification,
    super.bankDetails,
    super.swapStatus,
    super.activeSubscription,
    super.vehicle,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['_id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] as String? ?? '',
      personalInfoCompleted: json['personalInfoCompleted'] as bool? ?? false,
      aadhaarInfoCompleted: json['aadhaarInfoCompleted'] as bool? ?? false,
      panInfoCompleted: json['panInfoCompleted'] as bool? ?? false,
      bankInfoCompleted: json['bankInfoCompleted'] as bool? ?? false,
      isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      userAgreement: json['userAgreement'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      personalInformation: json['personalInformation'] != null
          ? PersonalInformation.fromJson(json['personalInformation'])
          : null,
      aadhaarVerification: json['aadhaarVerification'] != null
          ? AadhaarVerification.fromJson(json['aadhaarVerification'])
          : null,
      panVerification: json['panVerification'] != null
          ? PanVerification.fromJson(json['panVerification'])
          : null,
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : null,
      swapStatus: json['swapStatus'] as String?,
      activeSubscription: json['activeSubscription'] != null
          ? ActiveSubscription.fromJson(json['activeSubscription'])
          : null,
      vehicle: (json['vehicle'] != null && json['vehicle'] is Map)
          ? VehicleDetails.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }
}
