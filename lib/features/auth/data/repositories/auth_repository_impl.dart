import 'dart:convert';

import 'package:ShipRyd_app/core/error/exceptions.dart';
import 'package:ShipRyd_app/core/error/failures.dart';
import 'package:ShipRyd_app/features/auth/data/models/auth_response.dart';
import 'package:ShipRyd_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      await remoteDataSource.sendOtp(phoneNumber);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyOtp(PhoneOtpParams params) async {
    try {
      final response = await remoteDataSource.verifyOtp(params);
      // Cache user part
      final userJson = jsonEncode(response.user.toJson());
      await localDataSource.cacheUser(userJson);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
