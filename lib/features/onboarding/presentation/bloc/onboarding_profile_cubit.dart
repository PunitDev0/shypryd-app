import 'package:bloc/bloc.dart';
import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:ShipRyd_app/features/driver/domain/usecases/fetch_driver_profile.dart';

class OnboardingProfileCubit extends Cubit<DriverProfile?> {
  final FetchDriverProfile fetchDriverProfile;
  final String token;

  OnboardingProfileCubit(
      {required this.fetchDriverProfile, required this.token})
      : super(null);

  Future<void> loadProfile() async {
    final result = await fetchDriverProfile(token);
    result.fold(
      (failure) => emit(null),
      (profile) => emit(profile),
    );
  }
}
