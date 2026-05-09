part of 'onboarding_bloc.dart';

class OnboardingState {
  final List<StepStatus> steps;
  final bool isSubmitting;

  OnboardingState({required this.steps, this.isSubmitting = false});

  OnboardingState copyWith({List<StepStatus>? steps, bool? isSubmitting}) {
    return OnboardingState(
      steps: steps ?? this.steps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class StepStatus {
  final OnboardingStep step;
  final bool hasData;

  StepStatus({required this.step, this.hasData = false});
}

class OnboardingInitial extends OnboardingState {
  OnboardingInitial()
      : super(
          steps: [
            StepStatus(step: OnboardingStep.personalInfo),
            StepStatus(step: OnboardingStep.aadhaar),
            StepStatus(step: OnboardingStep.pan),
            StepStatus(step: OnboardingStep.bank),
            StepStatus(step: OnboardingStep.agreement),
          ],
        );

  @override
  OnboardingInitial copyWith({List<StepStatus>? steps, bool? isSubmitting}) {
    return OnboardingInitial();
  }
}

class OnboardingSubmitting extends OnboardingState {
  OnboardingSubmitting({required List<StepStatus> steps})
      : super(steps: steps, isSubmitting: true);

  @override
  OnboardingSubmitting copyWith({List<StepStatus>? steps, bool? isSubmitting}) {
    return OnboardingSubmitting(steps: steps ?? this.steps);
  }
}

class OnboardingStepCompleted extends OnboardingState {
  final OnboardingStep step;

  OnboardingStepCompleted({required this.step, required List<StepStatus> steps})
      : super(steps: steps, isSubmitting: false);

  @override
  OnboardingStepCompleted copyWith(
      {List<StepStatus>? steps, bool? isSubmitting}) {
    return OnboardingStepCompleted(step: step, steps: steps ?? this.steps);
  }
}

class OnboardingFailure extends OnboardingState {
  final String error;

  OnboardingFailure({required this.error, required List<StepStatus> steps})
      : super(steps: steps, isSubmitting: false);

  @override
  OnboardingFailure copyWith({List<StepStatus>? steps, bool? isSubmitting}) {
    return OnboardingFailure(error: error, steps: steps ?? this.steps);
  }
}
