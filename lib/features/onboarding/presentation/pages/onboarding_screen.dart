import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridezzy_app/features/onboarding/presentation/pages/aadhar_screen.dart';
import 'package:ridezzy_app/features/onboarding/presentation/pages/agreement_screen.dart';
import 'package:ridezzy_app/features/onboarding/presentation/pages/bank_details_screen.dart';
import 'package:ridezzy_app/features/onboarding/presentation/pages/pan_screen.dart';
import '../bloc/onboarding_bloc.dart';
import 'personal_details_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Onboarding Steps",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color(0xFFffd700),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          buildWhen: (previous, current) =>
              previous.steps != current.steps ||
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            final bloc = context.read<OnboardingBloc>();
            final steps = state.steps.isNotEmpty
                ? state.steps
                : [
                    StepStatus(step: OnboardingStep.personalInfo),
                    StepStatus(step: OnboardingStep.aadhaar),
                    StepStatus(step: OnboardingStep.pan),
                    StepStatus(step: OnboardingStep.bank),
                    StepStatus(step: OnboardingStep.agreement),
                  ];
            final allStepsHaveData = steps.every((step) => step.hasData);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildStepTile(
                        context,
                        step: OnboardingStep.personalInfo,
                        title: "Personal Information",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: const PersonalDetailsScreen(),
                              ),
                            ),
                          );
                        },
                        hasData: steps
                            .firstWhere(
                              (s) => s.step == OnboardingStep.personalInfo,
                              orElse: () => StepStatus(
                                  step: OnboardingStep.personalInfo,
                                  hasData: false),
                            )
                            .hasData,
                      ),
                      _buildStepTile(
                        context,
                        step: OnboardingStep.aadhaar,
                        title: "Aadhaar Card",
                        onTap: () =>
                            _navigateToScreen(context, OnboardingStep.aadhaar),
                        hasData: steps
                            .firstWhere(
                              (s) => s.step == OnboardingStep.aadhaar,
                              orElse: () => StepStatus(
                                  step: OnboardingStep.aadhaar, hasData: false),
                            )
                            .hasData,
                      ),
                      _buildStepTile(
                        context,
                        step: OnboardingStep.pan,
                        title: "PAN Card",
                        onTap: () =>
                            _navigateToScreen(context, OnboardingStep.pan),
                        hasData: steps
                            .firstWhere(
                              (s) => s.step == OnboardingStep.pan,
                              orElse: () => StepStatus(
                                  step: OnboardingStep.pan, hasData: false),
                            )
                            .hasData,
                      ),
                      _buildStepTile(
                        context,
                        step: OnboardingStep.bank,
                        title: "Bank Details",
                        onTap: () =>
                            _navigateToScreen(context, OnboardingStep.bank),
                        hasData: steps
                            .firstWhere(
                              (s) => s.step == OnboardingStep.bank,
                              orElse: () => StepStatus(
                                  step: OnboardingStep.bank, hasData: false),
                            )
                            .hasData,
                      ),
                      _buildStepTile(
                        context,
                        step: OnboardingStep.agreement,
                        title: "User Agreement",
                        onTap: () => _navigateToScreen(
                            context, OnboardingStep.agreement),
                        hasData: steps
                            .firstWhere(
                              (s) => s.step == OnboardingStep.agreement,
                              orElse: () => StepStatus(
                                  step: OnboardingStep.agreement,
                                  hasData: false),
                            )
                            .hasData,
                      ),
                    ],
                  ),
                ),
                if (allStepsHaveData && !state.isSubmitting)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        print("All steps completed, proceed to Hub Selection");
                        // Add navigation logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFffd700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Continue",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepTile(BuildContext context,
      {required OnboardingStep step,
      required String title,
      required VoidCallback onTap,
      required bool hasData}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          _getStepIcon(step),
          color: Colors.black,
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black)),
        trailing: hasData
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Awaiting", style: TextStyle(color: Colors.orange)),
                  SizedBox(width: 4),
                  Icon(Icons.hourglass_empty, color: Colors.orange),
                ],
              )
            : TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFffd700),
                ),
                child: const Text("Start Now"),
              ),
      ),
    );
  }

  IconData _getStepIcon(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.personalInfo:
        return Icons.person;
      case OnboardingStep.aadhaar:
        return Icons.credit_card;
      case OnboardingStep.pan:
        return Icons.badge;
      case OnboardingStep.bank:
        return Icons.account_balance;
      case OnboardingStep.agreement:
        return Icons.description;
    }
  }

  void _navigateToScreen(BuildContext context, OnboardingStep step) {
    final bloc = context.read<OnboardingBloc>();
    switch (step) {
      case OnboardingStep.aadhaar:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const AadharVerificationScreen(),
            ),
          ),
        );
        break;
      case OnboardingStep.pan:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const PanVerificationScreen(),
            ),
          ),
        );
        break;
      case OnboardingStep.bank:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const BankDetailsScreen(),
            ),
          ),
        );
        break;
      case OnboardingStep.agreement:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const UserAgreementScreen(),
            ),
          ),
        );
        break;
      default:
        break;
    }
  }
}
