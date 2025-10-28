import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridezzy_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/otpReferences/otp_event.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/otpReferences/otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthRemoteDataSource authRemoteDataSource;

  OtpBloc({required this.authRemoteDataSource}) : super(OtpInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      await authRemoteDataSource.loginWithPhone('+91${event.phoneNumber}');
      emit(OtpSent(
          phoneNumber: event.phoneNumber,
          referenceIndex: event.referenceIndex));
    } catch (e) {
      emit(OtpError('Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      await authRemoteDataSource
          .verifyOtp(PhoneOtpParams('+91${event.phoneNumber}', event.otp));
      emit(OtpVerified(
          phoneNumber: event.phoneNumber,
          referenceIndex: event.referenceIndex));
    } catch (e) {
      emit(OtpError('Invalid or expired OTP: ${e.toString()}'));
    }
  }
}
