import "package:ShipRyd_app/core/constants/api_constants.dart";
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as onboardingEvent;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as onboarding;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToEnd = false;
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.95) {
        setState(() {
          _isScrolledToEnd = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<onboarding.OnboardingBloc, onboarding.OnboardingState>(
      builder: (context, state) {
        final bloc = context.read<onboarding.OnboardingBloc>();
        return Scaffold(
            backgroundColor: const Color(0xFFf5c034),
            appBar: AppBar(
              backgroundColor: const Color(0xFFf5c034),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'User Agreement',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Please read the agreement carefully and fully before proceeding.",
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: const Text(
                          '''Combined Policy – ShipRyd Private Limited

This Combined Policy includes the Terms of Service, Privacy Policy, and Refund & Cancellation Policy of ShipRyd Private Limited. By registering on the ShipRyd mobile application, website, or platform, and by clicking “I Agree”, you confirm that you have read, understood, and accepted all the terms and conditions mentioned below.

1. Company Details
Legal Name: ShipRyd Private Limited
CIN: U49231KA2026PTC213656
Registered Address:
H-1003, Near Hoodi Metro Station,
Hoodi, Whitefield, Bangalore,
Karnataka – 560048, India

2. User Eligibility
For low-speed electric scooters:
- Minimum age: 16 years
- No driving license required (as per applicable laws)

For high-speed electric scooters:
- Minimum age: 18 years
- Valid driving license is mandatory

Users must provide true and accurate information and comply with all applicable laws and traffic rules.

3. Services Offered
ShipRyd provides electric scooter rental services for delivery partners, gig workers, and individuals. Service availability may vary by location.

4. User Responsibilities
Users agree to use vehicles responsibly, follow traffic rules, avoid misuse or damage, bear responsibility for fines or penalties, and keep login credentials confidential.

5. Payments & Charges
All applicable rent, deposits, and charges must be paid in advance. Payments are processed through authorized payment gateways. Non-payment may lead to suspension or termination of services.

6. Refund & Security Deposit Policy
Rental Amount:
All rental amounts paid are strictly non-refundable.

Security Deposit:
The security deposit will be refunded only if the rider completes a minimum of 2 months of active usage. If the rider does not complete 2 months, the security deposit will not be refunded. Refunds are subject to no pending dues, no major damages, and proper return of vehicle and accessories.

7. Cancellation Policy
ShipRyd does not offer any cancellation policy. Once registration or vehicle allocation is completed, it cannot be cancelled.

8. Privacy & Data Usage
ShipRyd may collect personal, KYC, payment, service usage, and technical data for service delivery, operations, compliance, and communication. Personal data is not sold.

9. Data Security & Retention
Reasonable security measures are used to protect data. Data is retained only as required for legal or operational purposes.

10. Limitation of Liability
ShipRyd is not liable for indirect losses, loss of income, or damages caused due to misuse, negligence, or rule violations.

11. Account Suspension & Termination
ShipRyd reserves the right to suspend or terminate accounts in case of false information, policy violations, unpaid dues, or misuse of vehicles.

12. Policy Updates
ShipRyd may update this policy at any time. Continued use of the platform implies acceptance of the updated terms.

13. Governing Law & Jurisdiction
This policy is governed by the laws of India. Courts in Bangalore, Karnataka shall have exclusive jurisdiction.

14. Acceptance of Policy
By clicking “I Agree”, you confirm that you have read, understood, and accepted this policy and agree to comply with all its terms.''',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          onChanged: _isScrolledToEnd
                              ? (value) {
                                  setState(() {
                                    _isAgreed = value ?? false;
                                  });
                                }
                              : null,
                        ),
                        const Text(
                          "I understand and agree with the User Agreement",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isAgreed && _isScrolledToEnd
                            ? () async {
                                const storage = FlutterSecureStorage();
                                final token = await storage.read(key: 'auth_token');
                                if (token == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Auth token not found. Please login again.')),
                                  );
                                  return;
                                }

                                final response = await http.put(
                                  Uri.parse(
                                      '${ApiConstants.baseUrl}/api/driver/agreement'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Accept': 'application/json',
                                    'Authorization': 'Bearer $token',
                                  },
                                  body: jsonEncode({"userAgreement": true}),
                                );

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  context.read<onboarding.OnboardingBloc>().add(
                                      onboardingEvent.DataEntered(
                                          onboarding.OnboardingStep.agreement));
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to update agreement: ${response.statusCode}')),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFf5c034),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                  ],
                ),
              ),
            ));
      },
    );
  }
}
