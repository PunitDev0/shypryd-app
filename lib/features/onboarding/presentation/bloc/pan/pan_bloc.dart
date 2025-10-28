import 'package:flutter_bloc/flutter_bloc.dart';
part 'pan_event.dart';
part 'pan_state.dart';

class PanBloc extends Bloc<PanEvent, PanState> {
  String? panNumber;
  String? dob;
  String? imagePath;

  PanBloc() : super(PanInitial()) {
    on<PanNumberChanged>((event, emit) {
      panNumber = event.panNumber;
      emit(PanDataUpdated(panNumber: panNumber, dob: dob, imagePath: imagePath));
    });

    on<PanDobChanged>((event, emit) {
      dob = event.dob;
      emit(PanDataUpdated(panNumber: panNumber, dob: dob, imagePath: imagePath));
    });

    on<PanImagePicked>((event, emit) {
      imagePath = event.imagePath;
      emit(PanDataUpdated(panNumber: panNumber, dob: dob, imagePath: imagePath));
    });

    on<SubmitPanDetails>((event, emit) async {
      emit(PanLoading());
      await Future.delayed(const Duration(seconds: 1)); // simulate save
      if (event.panNumber.isNotEmpty && event.dob.isNotEmpty && event.imagePath != null) {
        emit(PanVerified());
      } else {
        emit(PanError("Please fill all details before continuing."));
      }
    });
  }
}
