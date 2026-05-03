import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:ShipRyd_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:ShipRyd_app/features/home/presentation/pages/home_page.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final String _countryCode = '+91'; // From screenshot
  bool _isOtpMode = false;
  int _resendTimer = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Timer starts only after OTP sent
  }

  void _startTimer() {
    _timer?.cancel();
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthPhoneSent) {
            setState(() {
              _isOtpMode = true;
              _isLoading = false;
            });
            _startTimer(); // Start countdown
          } else if (state is AuthAuthenticated) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Authenticated! Welcome, ${state.user.phone}')),
            );

            // Save token securely
            final storage = FlutterSecureStorage();
            await storage.write(
                key: 'auth_token', value: state.authResponse.token);

            if (state.isNewUser) {
              // 🟡 Navigate to onboarding flow
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => OnboardingBloc(),
                    child: const OnboardingScreen(),
                  ),
                ),
              );
            } else {
              // ✅ Existing user goes directly to home
              // Existing user → save driverId if available in state.user.id
              if (state.user.id.isNotEmpty) {
                await storage.write(key: 'driverId', value: state.user.id);
                print('Driver ID saved after login: ${state.user.id}');
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          } else if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              // Handles keyboard scroll
              child: ConstrainedBox(
                // Ensures full height for centering
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  // Adapts to content height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100), // Top spacing for status bar
                      const Text(
                        'ShipRyd',
                        style: TextStyle(
                          fontSize: 52, // Slightly smaller for responsiveness
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 80),
                      const Text(
                        'Driver App',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome back! Please login to continue.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      if (!_isOtpMode) ...[
                        // Phone input mode
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Enter Your Phone Number',
                              labelStyle: const TextStyle(color: Colors.black),
                              prefixText: '$_countryCode ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 188, 188,
                                      188), // Unfocused border color
                                  width: 1.5, // Border thickness
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(
                                      0xFFf5c034), // Focused border color (blue)
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            maxLength: 10,
                            onFieldSubmitted: (value) {
                              if (value.length == 10) {
                                _sendOtp();
                              }
                            },
                          ),
                        ),
                      ] else ...[
                        // OTP mode
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: _countryCode + _phoneController.text),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: const TextStyle(color: Colors.black),
                              prefixIcon: const Icon(Icons.phone),
                              suffixIcon: IconButton(
                                icon: const Text(
                                  'Edit',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isOtpMode = false;
                                    _otpController.clear();
                                    _timer?.cancel(); // Stop timer on edit
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 188, 188,
                                      188), // Unfocused border color
                                  width: 1.5, // Border thickness
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(
                                      0xFFf5c034), // Focused border color (blue)
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: 'Enter OTP',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 188, 188,
                                      188), // Unfocused border color
                                  width: 1.5, // Border thickness
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(
                                      0xFFf5c034), // Focused border color (blue)
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              if (value.length == 6) {
                                _verifyOtp();
                              }
                            },
                          ),
                        ),
                      ],
                      if (!_isOtpMode) ...[
                        const SizedBox(height: 60),
                      ] else ...[
                        const SizedBox(height: 30),
                      ],
                      // const SizedBox(height: 30),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (!_isOtpMode) {
                                          if (_phoneController.text.length ==
                                              10) {
                                            _sendOtp();
                                          }
                                        } else {
                                          if (_otpController.text.length == 6) {
                                            _verifyOtp();
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black)
                                    : Text(
                                        _isOtpMode ? 'Verify OTP' : 'Send OTP',
                                        style: const TextStyle(
                                          color: Color(0xFFf5c034),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_isOtpMode) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _resendTimer > 0
                              ? null
                              : () {
                                  _sendOtp(); // Re-trigger send OTP event
                                },
                          child: Text(
                            _resendTimer > 0
                                ? "Didn't receive the code? Resend in $_resendTimer s"
                                : "Didn't receive the code? Resend",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6)[500],
                              fontSize: 14,
                              decoration: _resendTimer > 0
                                  ? null
                                  : TextDecoration.underline,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Spacer(), // Pushes terms to bottom
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'By continuing, you agree to our Terms of Service and Privacy Policy.',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6)[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendOtp() {
    setState(() {
      _isLoading = true;
    });
    context.read<AuthBloc>().add(
          LoginWithPhoneEvent(_countryCode + _phoneController.text),
        );
  }

  void _verifyOtp() {
    setState(() {
      _isLoading = true;
    });
    final fullPhone = _countryCode + _phoneController.text;
    context.read<AuthBloc>().add(
          VerifyOtpEvent(fullPhone, _otpController.text),
        );
  }
}
