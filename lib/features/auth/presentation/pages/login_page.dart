import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:Maxryd_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:Maxryd_app/features/home/presentation/pages/home_page.dart';
import 'package:Maxryd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:Maxryd_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final String _countryCode = '+91';
  bool _isOtpMode = false;
  int _resendTimer = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start above the screen
      end: Offset.zero,             // End at center
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));

    _animationController = controller;
    _animationController!.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _pulseController?.dispose();
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
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

  void _sendOtp() {
    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(
          LoginWithPhoneEvent(_countryCode + _phoneController.text),
        );
  }

  void _verifyOtp() {
    setState(() => _isLoading = true);
    final fullPhone = _countryCode + _phoneController.text;
    context.read<AuthBloc>().add(
          VerifyOtpEvent(fullPhone, _otpController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthPhoneSent) {
            setState(() {
              _isOtpMode = true;
              _isLoading = false;
            });
            _startTimer();
          } else if (state is AuthAuthenticated) {
            setState(() => _isLoading = false);
            final storage = FlutterSecureStorage();
            await storage.write(key: 'auth_token', value: state.authResponse.token);

            if (state.isNewUser) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Access Denied: Your number is not registered. Please contact the admin.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              if (state.user.id.isNotEmpty) {
                await storage.write(key: 'driverId', value: state.user.id);
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          } else if (state is AuthError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: (_slideAnimation != null && _pulseAnimation != null) 
                          ? SlideTransition(
                              position: _slideAnimation!,
                              child: SizedBox(
                                height: 380,
                                width: 380,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Taillight Glow (Red) - Top side when rotated
                                    AnimatedBuilder(
                                      animation: _pulseAnimation!,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: 70, 
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.redAccent.withOpacity(0.9 * _pulseAnimation!.value),
                                                    blurRadius: 50 * _pulseAnimation!.value,
                                                    spreadRadius: 20 * _pulseAnimation!.value,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Headlight Glow (White/Yellow) - Bottom side when rotated
                                    AnimatedBuilder(
                                      animation: _pulseAnimation!,
                                      builder: (context, child) {
                                        return Positioned(
                                          bottom: 80,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.yellowAccent.withOpacity(0.8 * _pulseAnimation!.value),
                                                    blurRadius: 70 * _pulseAnimation!.value,
                                                    spreadRadius: 30 * _pulseAnimation!.value,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.6 * _pulseAnimation!.value),
                                                    blurRadius: 30 * _pulseAnimation!.value,
                                                    spreadRadius: 10 * _pulseAnimation!.value,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Transform.rotate(
                                      angle: math.pi, // Rotate 180 degrees
                                      child: Image.asset(
                                        'assets/images/login_scooter.png',
                                        height: 380,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Transform.rotate(
                              angle: math.pi,
                              child: Image.asset(
                                'assets/images/login_scooter.png',
                                height: 380,
                                fit: BoxFit.contain,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome to ',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        const Text(
                          'ShypRyd',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.bolt, color: Colors.greenAccent[700], size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    if (!_isOtpMode) _buildModernPhoneField() else _buildModernOtpField(),
                    const SizedBox(height: 30),
                    _buildModernSubmitButton(),
                    if (_isOtpMode) ...[
                      const SizedBox(height: 20),
                      _buildResendSection(),
                    ],
                    const SizedBox(height: 60),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'An invitation code is not required',
                          style: TextStyle(
                            color: Colors.greenAccent[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.black,
            child: Icon(Icons.public, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          const SizedBox(width: 4),
          const Text('+91', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                hintText: '000 000 0000',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                counterText: "",
              ),
              maxLength: 10,
              style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOtpField() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone, size: 18, color: Colors.black54),
              const SizedBox(width: 12),
              Text(
                '$_countryCode ${_phoneController.text}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isOtpMode = false;
                    _otpController.clear();
                    _timer?.cancel();
                  });
                },
                child: const Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'ENTER OTP',
              hintStyle: TextStyle(color: Colors.grey, letterSpacing: 2),
              border: InputBorder.none,
              counterText: "",
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (!_isOtpMode) {
                  if (_phoneController.text.length == 10) _sendOtp();
                } else {
                  if (_otpController.text.length == 6) _verifyOtp();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _isOtpMode ? 'VERIFY CODE' : 'CONTINUE',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return GestureDetector(
      onTap: _resendTimer > 0 ? null : () => _sendOtp(),
      child: Center(
        child: Text(
          _resendTimer > 0 ? "Resend in ${_resendTimer}s" : "Resend code",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            decoration: _resendTimer > 0 ? null : TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
