import 'package:dartz/dartz.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/phone_otp_params.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';


class VerifyOtp implements UseCase<User, PhoneOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, User>> call(PhoneOtpParams params) async {
    return await repository.verifyOtp(params);
  }
}