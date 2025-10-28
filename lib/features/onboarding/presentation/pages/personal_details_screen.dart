import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridezzy_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/otpReferences/otp_bloc.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/otpReferences/otp_event.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/otpReferences/otp_state.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _ref1Name = TextEditingController();
  final TextEditingController _ref1Relation = TextEditingController();
  final TextEditingController _ref1Number = TextEditingController();
  final TextEditingController _ref2Name = TextEditingController();
  final TextEditingController _ref2Relation = TextEditingController();
  final TextEditingController _ref2Number = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  String gender = "Male";
  String serviceRegion = "Delhi NCR";
  bool _isRef1Verified = false;
  bool _isRef2Verified = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to trigger rebuild when number changes
    _ref1Number.addListener(() => setState(() {}));
    _ref2Number.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressFocusNode.dispose();
    _ref1Number.removeListener(() => setState(() {}));
    _ref2Number.removeListener(() => setState(() {}));
    _fullName.dispose();
    _address.dispose();
    _ref1Name.dispose();
    _ref1Relation.dispose();
    _ref1Number.dispose();
    _ref2Name.dispose();
    _ref2Relation.dispose();
    _ref2Number.dispose();
    super.dispose();
  }

  void _showOtpPopup(int referenceIndex, String phoneNumber, OtpBloc otpBloc) {
    final otpController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;
    StreamSubscription? subscription;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext popupContext) => BlocProvider.value(
        value: otpBloc,
        child: StatefulBuilder(
          builder: (BuildContext popupContext, StateSetter popupSetState) {
            return AlertDialog(
              title: const Text('Enter OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('OTP sent to +91$phoneNumber'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      border: const OutlineInputBorder(),
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.pop(popupContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (otpController.text.length == 4) {
                            popupSetState(() {
                              isLoading = true;
                            });
                            otpBloc.add(
                              VerifyOtpEvent(
                                phoneNumber: phoneNumber,
                                otp: otpController.text,
                                referenceIndex: referenceIndex,
                              ),
                            );
                          } else {
                            popupSetState(() {
                              errorMessage = 'Please enter a valid 4-digit OTP';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFffd700)),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Verify',
                          style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        ),
      ),
    ).then((_) {
      // Cleanup subscription when dialog is closed
      subscription?.cancel();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    // Listen to OtpBloc state changes
    subscription = otpBloc.stream.listen((state) {
      if (state is OtpVerified) {
        if (state.referenceIndex == 0 && mounted) {
          setState(() {
            _isRef1Verified = true;
          });
          Navigator.pop(context); // Pop the dialog
        } else if (state.referenceIndex == 1 && mounted) {
          setState(() {
            _isRef2Verified = true;
          });
          Navigator.pop(context); // Pop the dialog
        }
      } else if (state is OtpError && mounted) {
        setState(() {
          errorMessage = state.message;
          isLoading = false;
        });
      }
    });

    otpBloc.add(
        SendOtpEvent(phoneNumber: phoneNumber, referenceIndex: referenceIndex));
    print('OTP popup shown for $phoneNumber'); // Debug print
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OtpBloc(authRemoteDataSource: AuthRemoteDataSourceImpl()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFffd700),
          elevation: 0,
          centerTitle: true,
          title: const Text('Personal Details',
              style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: BlocListener<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingStepCompleted) {
              Navigator.pop(context); // Navigate back only on Continue
            } else if (state is OnboardingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Builder(
            builder: (context) {
              final otpBloc = context.read<OtpBloc>();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const Text("Tell us about yourself",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                        "We need some basic information to set up your driver profile",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 20),
                    // Full Name
                    TextFormField(
                      controller: _fullName,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 14),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(
                                255, 188, 188, 188), // Unfocused border color
                            width: 1.5, // Border thickness
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(
                                0xFFffd700), // Focused border color (blue)
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text("Gender",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _genderButton("Male", Icons.male),
                        _genderButton("Female", Icons.female),
                        _genderButton("Others", Icons.transgender),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text("Service Region",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: serviceRegion,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 188, 188, 188),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFffd700),
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: ['Delhi NCR', 'Mumbai', 'Bangalore', 'Chandigarh']
                          .map((region) {
                        return DropdownMenuItem(
                            value: region, child: Text(region));
                      }).toList(),
                      onChanged: (val) => setState(() => serviceRegion = val!),
                    ),

                    const SizedBox(height: 20),
                    const Text("Current Address",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 120.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 188, 188, 188),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 60.0,
                            child: Icon(Icons.home_outlined, size: 24.0),
                          ),
                          Expanded(
                            child: TextFormField(
                              maxLines: 5,
                              controller: _address,
                              cursorColor: Colors.black,
                              decoration: const InputDecoration(
                                hintText: "Enter your full address",
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text("Emergency References",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Reference 1
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _ref1Name,
                          decoration: const InputDecoration(
                            labelText: "Reference Name 1",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ref1Relation,
                          decoration: const InputDecoration(
                            labelText: "Reference Relation 1",
                            prefixIcon: Icon(Icons.family_restroom),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ref1Number,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: "Reference Number 1",
                            prefixIcon: const Icon(Icons.phone),
                            suffixIcon: _isRef1Verified
                                ? const Icon(Icons.verified,
                                    color: Colors.green)
                                : IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: _ref1Number.text.length == 10
                                        ? () {
                                            print(
                                                'Sending OTP for ${_ref1Number.text}');
                                            _showOtpPopup(
                                                0, _ref1Number.text, otpBloc);
                                          }
                                        : null,
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (_isRef1Verified)
                          const Text('Phone number verified',
                              style: TextStyle(color: Colors.green)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Reference 2
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _ref2Name,
                          decoration: const InputDecoration(
                            labelText: "Reference Name 2",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ref2Relation,
                          decoration: const InputDecoration(
                            labelText: "Reference Relation 2",
                            prefixIcon: Icon(Icons.family_restroom),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _ref2Number,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: "Reference Number 2",
                            prefixIcon: const Icon(Icons.phone),
                            suffixIcon: _isRef2Verified
                                ? const Icon(Icons.verified,
                                    color: Colors.green)
                                : IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: _ref2Number.text.length == 10
                                        ? () {
                                            print(
                                                'Sending OTP for ${_ref2Number.text}');
                                            _showOtpPopup(
                                                1, _ref2Number.text, otpBloc);
                                          }
                                        : null,
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (_isRef2Verified)
                          const Text('Phone number verified',
                              style: TextStyle(color: Colors.green)),
                      ],
                    ),

                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isRef1Verified && _isRef2Verified
                          ? () {
                              context.read<OnboardingBloc>().add(
                                    SubmitPersonalDetails(
                                      fullName: _fullName.text,
                                      gender: gender,
                                      serviceRegion: serviceRegion,
                                      address: _address.text,
                                      references: [
                                        {
                                          'name': _ref1Name.text,
                                          'relation': _ref1Relation.text,
                                          'number': _ref1Number.text,
                                        },
                                        {
                                          'name': _ref2Name.text,
                                          'relation': _ref2Relation.text,
                                          'number': _ref2Number.text,
                                        },
                                      ],
                                    ),
                                  );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFffd700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Continue",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, IconData icon) {
    final isSelected = gender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFffd700) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnboardingBloc()),
        // OtpBloc is provided within PersonalDetailsScreen
      ],
      child: const MaterialApp(
        home: PersonalDetailsScreen(),
      ),
    ),
  );
}
