import 'package:ShipRyd_app/features/onboarding/presentation/pages/hub_selection_screen.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/pages/plan_selection_screen.dart';
import 'package:ShipRyd_app/features/wallet/presentation/pages/my_subscription_screen.dart';
import 'package:flutter/material.dart';

class ProfileAwaitingApprovalScreen extends StatelessWidget {
  const ProfileAwaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf5c034),
        centerTitle: true,
        title: const Text(
          "Profile Status",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 100,
                  color: Color(0xFFf5c034),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Profile Awaiting Approval",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your profile has been submitted successfully. Once it's reviewed and approved by the admin, you'll be able to continue to the next steps.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf5c034),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Replace with your Firestore approval status check
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text(
                      //         "Checking approval status...Done on Next screen"),
                      //   ),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MySubscriptionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Check Status",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
