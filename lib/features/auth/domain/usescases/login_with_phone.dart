import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhone implements UseCase<void, String> {
  final AuthRepository repository;

  LoginWithPhone(this.repository);

  @override
  Future<Either<Failure, void>> call(String phoneNumber) async {
    return await repository.sendOtp(phoneNumber);
  }
}
