import 'package:dartz/dartz.dart';
import 'package:ShipRyd_app/core/error/failures.dart';
import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:ShipRyd_app/features/driver/domain/repositories/driver_repository.dart';

class FetchDriverProfile {
  final DriverRepository repository;
  FetchDriverProfile(this.repository);

  Future<Either<Failure, DriverProfile>> call(String token) async {
    return await repository.fetchDriverProfile(token);
  }
}
