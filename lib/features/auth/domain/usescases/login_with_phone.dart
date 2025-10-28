import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhone implements UseCase<User, String> {
  final AuthRepository repository;

  LoginWithPhone(this.repository);

  @override
  Future<Either<Failure, User>> call(String phoneNumber) async {
    return await repository.loginWithPhone(phoneNumber);
  }
}