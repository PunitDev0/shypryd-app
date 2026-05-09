import 'package:dartz/dartz.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:Maxryd_app/core/error/failures.dart';

abstract class DriverRepository {
  Future<Either<Failure, DriverProfile>> fetchDriverProfile(String token);
}
