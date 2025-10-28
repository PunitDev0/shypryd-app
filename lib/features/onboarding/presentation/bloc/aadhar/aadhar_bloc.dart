import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridezzy_app/features/onboarding/data/repositories/aadhar_repository.dart';

part 'aadhar_event.dart';
part 'aadhar_state.dart';

class AadharBloc extends Bloc<AadharEvent, AadharState> {
  final AadhaarRepository repository;
  String aadharNumber = '';
  List<String> images = ['', '']; // [front, back]
  String? refId;

  AadharBloc(this.repository) : super(AadharInitial()) {
    on<AadharNumberChanged>((event, emit) {
      aadharNumber = event.aadharNumber;
      emit(AadharDataUpdated(aadharNumber: aadharNumber, images: images));
    });

    on<AadharImagePicked>((event, emit) {
      images[event.index] = event.imagePath;
      emit(AadharDataUpdated(aadharNumber: aadharNumber, images: images));
    });

    on<SubmitAadharDetails>((event, emit) async {
      emit(AadharLoading());
      try {
        final refId = await repository.sendAadhaarOtp(event.aadharNumber);
        this.refId = refId;
        emit(AadharOtpSent(refId));
      } catch (e) {
        String message = e.toString();

        if (message.contains("502") ||
            message.contains("503") ||
            message.contains("temporarily unavailable")) {
          message =
              "The Aadhaar verification service is temporarily unavailable. Please try again after a few minutes.";
        } else if (message.contains("400") || message.contains("invalid")) {
          message = "Invalid Aadhaar number. Please check and try again.";
        } else {
          message = "Failed to send OTP. Please try again.";
        }

        emit(AadharError(message));
        print("Error sending Aadhaar OTP: $e");
      }
    });

    on<VerifyAadharOtp>((event, emit) async {
      emit(AadharVerifying());
      try {
        final result =
            await repository.verifyAadhaarOtp(event.refId, event.otp);
        final status = result["status"]?.toString().toUpperCase();
        final message = result["message"]?.toString().toLowerCase() ?? "";

        // ✅ Treat "Aadhaar exists" or similar as verified
        if (status == "SUCCESS" ||
            message.contains("exists") ||
            message.contains("already")) {
          emit(AadharVerified());
        } else {
          emit(AadharError("Verification failed: ${result['message']}"));
        }
      } catch (e) {
        emit(AadharError("OTP verification failed: ${e.toString()}"));
      }
    });
  }
}
