import 'package:dartz/dartz.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/phone_otp_params.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithPhone(String phoneNumber);
  Future<Either<Failure, User>> verifyOtp(PhoneOtpParams params);
}