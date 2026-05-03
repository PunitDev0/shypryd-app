import 'package:ShipRyd_app/features/auth/data/models/auth_response.dart';
import 'package:ShipRyd_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phoneNumber);
  Future<Either<Failure, AuthResponse>> verifyOtp(PhoneOtpParams params);
}
