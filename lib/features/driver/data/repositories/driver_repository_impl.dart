import 'package:dartz/dartz.dart';
import 'package:ShipRyd_app/core/error/failures.dart';
import 'package:ShipRyd_app/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:ShipRyd_app/features/driver/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;

  DriverRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DriverProfile>> fetchDriverProfile(
      String token) async {
    try {
      final profile = await remoteDataSource.fetchDriverProfile(token);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
