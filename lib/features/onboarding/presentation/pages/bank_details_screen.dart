import "package:ShipRyd_app/core/constants/api_constants.dart";
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/bank/bank_bloc.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/bank/bank_event.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/bank/bank_state.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as onboarding;
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as onboardingEvent;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  Future<void> submitBankDetails(BuildContext context) async {
    final bankName = bankNameController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final confirmAccountNumber = confirmAccountNumberController.text.trim();
    final ifscCode = ifscCodeController.text.trim().toUpperCase();

    // Simple IFSC validation: 4 letters, 0, 6 digits (e.g., SBIN0001234)
    final ifscRegExp = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegExp.hasMatch(ifscCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid IFSC code.')),
      );
      return;
    }

    final body = {
      "bankName": bankName,
      "accountNumber": accountNumber,
      "confirmAccountNumber": confirmAccountNumber,
      "ifscCode": ifscCode,
    };

    // Get token from secure storage
    String? token;
    try {
      final storage = FlutterSecureStorage();
      token = await storage.read(key: 'auth_token');
    } catch (_) {
      token = null;
    }
    print('BANK SUBMIT: body = ' + body.toString());
    print('BANK SUBMIT: token = $token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Auth token not found. Please login again.')),
      );
      return;
    }
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/driver/bank'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    print('BANK SUBMIT: response = ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank details submitted successfully!')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } else {
      String msg = 'Failed to submit bank details: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null) msg = data['message'];
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BankBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFf5c034),
            appBar: AppBar(
              backgroundColor: const Color(0xFFf5c034),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Bank Details',
                style: TextStyle(color: Colors.black),
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
                child: BlocConsumer<BankBloc, BankState>(
                  listener: (context, state) {
                    if (state is BankError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.black,
                          content: Text(state.message),
                        ),
                      );
                    } else if (state is BankVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Bank details saved successfully ✅")),
                      );
                      final onboardingBloc =
                          context.read<onboarding.OnboardingBloc>();
                      onboardingBloc.add(onboardingEvent.SubmitBankDetails(
                        bankName: bankNameController.text,
                        accountNumber: accountNumberController.text,
                        confirmAccountNumber:
                            confirmAccountNumberController.text,
                        ifscCode: ifscCodeController.text,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  builder: (context, state) {
                    final bloc = context.read<BankBloc>();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Add Your Bank Account",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "We need your bank details to process your earnings",
                            style: TextStyle(color: Colors.black.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 20),

                          // Bank Name input
                          const Text("Bank Name",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: bankNameController,
                            decoration: InputDecoration(
                              hintText: "Search or select your bank",
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) => bloc.add(BankNameChanged(val)),
                          ),

                          const SizedBox(height: 16),

                          // Account Number input
                          const Text("Bank Account Number",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: accountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter your account number",
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) =>
                                bloc.add(AccountNumberChanged(val)),
                          ),

                          const SizedBox(height: 16),

                          // Confirm Account Number input
                          const Text("Confirm Account Number",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: confirmAccountNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Re-enter your account number",
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) =>
                                bloc.add(ConfirmAccountNumberChanged(val)),
                          ),

                          const SizedBox(height: 16),

                          // IFSC Code input
                          const Text("IFSC Code",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: ifscCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: "Enter IFSC code (e.g., SBIN0001234)",
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) => bloc.add(IfscCodeChanged(val)),
                          ),

                          const SizedBox(height: 16),

                          // Info box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.black),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Your bank details are securely encrypted and will only be used for insurance purposes.",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: state is BankLoading
                                  ? null
                                  : () async {
                                      await submitBankDetails(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFf5c034),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is BankLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black)
                                  : const Text(
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
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
