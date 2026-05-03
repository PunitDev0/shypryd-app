import 'package:ShipRyd_app/features/auth/data/models/auth_response.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';
import 'phone_otp_params.dart';

class VerifyOtp implements UseCase<AuthResponse, PhoneOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(PhoneOtpParams params) async {
    return await repository.verifyOtp(params);
  }
}
