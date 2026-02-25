import 'package:Maxryd_app/features/onboarding/presentation/pages/aadhar_screen.dart';
import 'package:Maxryd_app/features/onboarding/presentation/pages/agreement_screen.dart';
import 'package:Maxryd_app/features/onboarding/presentation/pages/bank_details_screen.dart';
import 'package:Maxryd_app/features/onboarding/presentation/pages/pan_screen.dart';
import 'package:Maxryd_app/features/onboarding/presentation/pages/profile_awaiting_screen.dart';
// import 'package:Maxryd_app/features/onboarding/presentation/pages/profile_awaiting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import 'package:Maxryd_app/features/driver/domain/usecases/fetch_driver_profile.dart';
import 'package:Maxryd_app/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:Maxryd_app/features/driver/data/repositories/driver_repository_impl.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';
import 'personal_details_screen.dart';
// import 'profile_awaiting_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DriverProfile? driverProfile;
  bool isLoading = true;
  String? token;
  // @override
  // void initState() {
  //   super.initState();
  //   _fetchDriverProfile();
  // }

  // Future<void> _fetchDriverProfile() async {
  //   // TODO: Replace with actual token retrieval logic
  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchProfile();
  }

  Future<void> _loadTokenAndFetchProfile() async {
    const storage = FlutterSecureStorage();
    token = await storage.read(key: 'auth_token');
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final remote = DriverRemoteDataSourceImpl();
    final repo = DriverRepositoryImpl(remoteDataSource: remote);
    final usecase = FetchDriverProfile(repo);
    final result = await usecase(token!);
    result.fold(
      (failure) => setState(() {
        isLoading = false;
        driverProfile = null;
      }),
      (profile) => setState(() {
        // SAVE REAL DRIVER ID HERE
        const storage = FlutterSecureStorage();
        storage.write(key: 'driverId', value: profile.id);
        driverProfile = profile;
        isLoading = false;
      }),
    );
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final profile = driverProfile;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Onboarding Steps",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFf5c034),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildStepTile(
                  context,
                  step: OnboardingStep.personalInfo,
                  title: "Personal Information",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OnboardingBloc>(),
                          child: const PersonalDetailsScreen(),
                        ),
                      ),
                    );
                  },
                  hasData: profile?.personalInfoCompleted ?? false,
                ),
                const SizedBox(height: 15),
                _buildStepTile(
                  context,
                  step: OnboardingStep.aadhaar,
                  title: "Aadhaar Card",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OnboardingBloc>(),
                          child: const AadharVerificationScreen(),
                        ),
                      ),
                    );
                  },
                  hasData: profile?.aadhaarInfoCompleted ?? false,
                ),
                const SizedBox(height: 15),
                _buildStepTile(
                  context,
                  step: OnboardingStep.pan,
                  title: "PAN Card",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OnboardingBloc>(),
                          child: const PanVerificationScreen(),
                        ),
                      ),
                    );
                  },
                  hasData: profile?.panInfoCompleted ?? false,
                ),
                const SizedBox(height: 15),
                _buildStepTile(
                  context,
                  step: OnboardingStep.bank,
                  title: "Bank Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OnboardingBloc>(),
                          child: const BankDetailsScreen(),
                        ),
                      ),
                    );
                  },
                  hasData: profile?.bankInfoCompleted ?? false,
                ),
                const SizedBox(height: 15),
                _buildStepTile(
                  context,
                  step: OnboardingStep.agreement,
                  title: "User Agreement",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<OnboardingBloc>(),
                          child: const UserAgreementScreen(),
                        ),
                      ),
                    );
                  },
                  hasData: profile?.userAgreement ?? false,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf5c034),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileAwaitingApprovalScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
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
      elevation: 2,
      child: ListTile(
        minTileHeight: 80,
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
                  backgroundColor: const Color(0xFFf5c034),
                ),
                child: const Text("Start Now"),
              ),
      ),
    );
  }

  IconData _getStepIcon(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.personalInfo:
        return Icons.person_outline;
      case OnboardingStep.aadhaar:
        return Icons.credit_card_outlined;
      case OnboardingStep.pan:
        return Icons.badge_outlined;
      case OnboardingStep.bank:
        return Icons.account_balance_outlined;
      case OnboardingStep.agreement:
        return Icons.description_outlined;
    }
  }
}
