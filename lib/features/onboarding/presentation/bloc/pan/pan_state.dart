part of 'pan_bloc.dart';

abstract class PanState {}

class PanInitial extends PanState {}

class PanLoading extends PanState {}

class PanVerified extends PanState {}

class PanError extends PanState {
  final String message;
  PanError(this.message);
}

class PanDataUpdated extends PanState {
  final String? panNumber;
  final String? dob;
  final String? imagePath;

  PanDataUpdated({
    this.panNumber,
    this.dob,
    this.imagePath,
  });
}
