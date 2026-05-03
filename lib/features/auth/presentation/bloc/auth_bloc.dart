import 'package:ShipRyd_app/core/utils/token_storage.dart';
import 'package:ShipRyd_app/features/auth/data/models/auth_response.dart';
import 'package:ShipRyd_app/features/auth/domain/entities/user.dart';
import 'package:ShipRyd_app/features/auth/domain/usescases/login_with_phone.dart';
import 'package:ShipRyd_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'package:ShipRyd_app/features/auth/domain/usescases/verify_otp.dart';
import 'package:ShipRyd_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithPhone loginWithPhone;
  final VerifyOtp verifyOtp;

  AuthBloc({
    required this.loginWithPhone,
    required this.verifyOtp,
  }) : super(AuthInitial()) {
    on<LoginWithPhoneEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onSendOtp(
    LoginWithPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginWithPhone(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(const AuthPhoneSent()),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = PhoneOtpParams(event.phone, event.otp);
    final result = await verifyOtp(params);

    await result.fold(
      (failure) async {
        emit(AuthError(message: _mapFailureToMessage(failure)));
      },
      (authResponse) async {
        // Save token securely
        await TokenStorage().saveToken(authResponse.token);

        final isComplete = authResponse.user.isProfileCompleted;

        // Optional: persist completion flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          'isProfileComplete_${authResponse.user.id}',
          isComplete,
        );

        emit(AuthAuthenticated(
          authResponse.user,
          isNewUser: !isComplete,
          onboardingCompleted: isComplete,
          authResponse: authResponse,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return 'Server error: ${failure.message}';
    return 'An unexpected error occurred';
  }
}
