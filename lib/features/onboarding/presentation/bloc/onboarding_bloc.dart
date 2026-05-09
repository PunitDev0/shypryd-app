import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<SubmitPersonalDetails>(_onSubmitPersonalDetails);
    on<SubmitAadhaarDetails>(_onSubmitAadhaarDetails);
    on<SubmitPanDetails>(_onSubmitPanDetails);
    on<SubmitBankDetails>(_onSubmitBankDetails);
    on<DataEntered>(_onDataEntered);
  }

  Future<void> _onSubmitPersonalDetails(
      SubmitPersonalDetails event, Emitter<OnboardingState> emit) async {
    emit(OnboardingSubmitting(steps: state.steps));
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    final updatedSteps = state.steps.map((step) {
      if (step.step == OnboardingStep.personalInfo) {
        return StepStatus(step: step.step, hasData: true);
      }
      return step;
    }).toList();
    emit(OnboardingStepCompleted(
        step: OnboardingStep.personalInfo, steps: updatedSteps));
  }

  Future<void> _onSubmitAadhaarDetails(
      SubmitAadhaarDetails event, Emitter<OnboardingState> emit) async {
    emit(OnboardingSubmitting(steps: state.steps));
    await Future.delayed(const Duration(seconds: 2));
    final updatedSteps = state.steps.map((step) {
      if (step.step == OnboardingStep.aadhaar) {
        return StepStatus(step: step.step, hasData: true);
      }
      return step;
    }).toList();
    emit(OnboardingStepCompleted(
        step: OnboardingStep.aadhaar, steps: updatedSteps));
  }

  Future<void> _onSubmitPanDetails(
      SubmitPanDetails event, Emitter<OnboardingState> emit) async {
    emit(OnboardingSubmitting(steps: state.steps));
    await Future.delayed(const Duration(seconds: 2));
    final updatedSteps = state.steps.map((step) {
      if (step.step == OnboardingStep.pan) {
        return StepStatus(step: step.step, hasData: true);
      }
      return step;
    }).toList();
    emit(
        OnboardingStepCompleted(step: OnboardingStep.pan, steps: updatedSteps));
  }

  Future<void> _onSubmitBankDetails(
      SubmitBankDetails event, Emitter<OnboardingState> emit) async {
    emit(OnboardingSubmitting(steps: state.steps));
    await Future.delayed(const Duration(seconds: 2));
    final updatedSteps = state.steps.map((step) {
      if (step.step == OnboardingStep.bank) {
        return StepStatus(step: step.step, hasData: true);
      }
      return step;
    }).toList();
    emit(OnboardingStepCompleted(
        step: OnboardingStep.bank, steps: updatedSteps));
  }

  void _onDataEntered(DataEntered event, Emitter<OnboardingState> emit) {
    final updatedSteps = state.steps.map((step) {
      if (step.step == event.step) {
        return StepStatus(step: step.step, hasData: true);
      }
      return step;
    }).toList();
    emit(state.copyWith(steps: updatedSteps));
  }
}
