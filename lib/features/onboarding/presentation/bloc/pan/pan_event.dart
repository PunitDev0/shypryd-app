part of 'pan_bloc.dart';

abstract class PanEvent {}

class PanNumberChanged extends PanEvent {
  final String panNumber;
  PanNumberChanged(this.panNumber);
}

class PanDobChanged extends PanEvent {
  final String dob;
  PanDobChanged(this.dob);
}

class PanImagePicked extends PanEvent {
  final String imagePath;
  PanImagePicked(this.imagePath);
}

class SubmitPanDetails extends PanEvent {
  final String panNumber;
  final String dob;
  final String? imagePath;
  SubmitPanDetails({
    required this.panNumber,
    required this.dob,
    required this.imagePath,
  });
}
