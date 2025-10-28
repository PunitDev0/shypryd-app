import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/login_with_phone.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/verify_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithPhone loginWithPhone;
  final VerifyOtp verifyOtp;

  AuthBloc({
    required this.loginWithPhone,
    required this.verifyOtp,
  }) : super(AuthInitial()) {
    on<LoginWithPhoneEvent>(_onLoginWithPhone);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  /// Handles phone number submission
  Future<void> _onLoginWithPhone(
    LoginWithPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginWithPhone(event.phoneNumber);

    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(AuthError(message: _mapFailureToMessage(failure)));
        }
      },
      (user) async {
        if (!emit.isDone) {
          emit(AuthPhoneSent(user));
        }
      },
    );
  }

  /// Handles OTP verification and determines if onboarding is needed
  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = PhoneOtpParams(event.phone, event.otp);
    final result = await verifyOtp(params);

    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(AuthError(message: _mapFailureToMessage(failure)));
        }
      },
      (user) async {
        // ✅ Check if the user has already completed onboarding
        final isUserOnboarded = await _checkIfUserIsOnboarded(user);

        if (!emit.isDone) {
          emit(AuthAuthenticated(user, isNewUser: !isUserOnboarded));
        }
      },
    );
  }

  /// Checks whether the user has completed onboarding (using SharedPreferences)
  Future<bool> _checkIfUserIsOnboarded(User user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isProfileComplete_${user.id}') ?? false;
  }

  /// Maps failures into user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache error: ${failure.message}';
    }
    return 'An unexpected error occurred';
  }
}
