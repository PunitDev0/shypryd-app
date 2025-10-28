import 'dart:convert'; // Add this import for jsonEncode

import 'package:dartz/dartz.dart';
import 'package:ridezzy_app/core/error/exceptions.dart';
import 'package:ridezzy_app/features/auth/data/models/user_models.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/phone_otp_params.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> loginWithPhone(String phoneNumber) async {
    try {
      final remoteUser = await remoteDataSource.loginWithPhone(phoneNumber);
      // Convert to UserModel for serialization
      final userModel = UserModel(id: remoteUser.id, phone: remoteUser.phone);
      await localDataSource.cacheUser(jsonEncode(userModel.toJson()));
      return Right(remoteUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

 @override
  Future<Either<Failure, User>> verifyOtp(PhoneOtpParams params) async {
    try {
      final remoteUser = await remoteDataSource.verifyOtp(params);
      final userModel = UserModel(id: remoteUser.id, phone: remoteUser.phone);
      await localDataSource.cacheUser(jsonEncode(userModel.toJson()));
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
