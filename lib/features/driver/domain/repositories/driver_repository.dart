import 'package:dartz/dartz.dart';
import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:ShipRyd_app/core/error/failures.dart';

abstract class DriverRepository {
  Future<Either<Failure, DriverProfile>> fetchDriverProfile(String token);
}
