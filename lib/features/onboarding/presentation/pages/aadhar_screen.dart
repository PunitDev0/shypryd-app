import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridezzy_app/features/onboarding/data/repositories/aadhar_repository.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/aadhar/aadhar_bloc.dart';
import 'package:ridezzy_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class AadharVerificationScreen extends StatelessWidget {
  const AadharVerificationScreen({super.key});

  Future<void> _pickImage(BuildContext context, int index) async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  context.read<AadharBloc>().add(
                        AadharImagePicked(
                            index: index, imagePath: pickedFile.path),
                      );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  context.read<AadharBloc>().add(
                        AadharImagePicked(
                            index: index, imagePath: pickedFile.path),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aadharController = TextEditingController();
    final otpController = TextEditingController();

    return BlocProvider(
      create: (_) => AadharBloc(AadhaarRepository()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFffd700),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Aadhaar Verification',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<AadharBloc, AadharState>(
              listener: (context, state) {
                if (state is AadharError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          final bloc = context.read<AadharBloc>();
                          bloc.add(SubmitAadharDetails(
                              aadharNumber: bloc.aadharNumber,
                              images: bloc.images));
                        },
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else if (state is AadharOtpSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP sent successfully ✅")),
                  );
                } else if (state is AadharVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Aadhaar Verified Successfully ✅"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3), // Give user time to read
                    ),
                  );
                }
              },
              builder: (context, state) {
                final bloc = context.read<AadharBloc>();
                final images = bloc.images;
                final isOtpSent =
                    state is AadharOtpSent || state is AadharVerifying;
                final isVerified = state is AadharVerified;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter your Aadhaar details for verification",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text("Aadhaar Number",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: aadharController,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        decoration: InputDecoration(
                          hintText: "Enter Aadhaar Number",
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFffd700), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFffd700), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) {
                          context
                              .read<AadharBloc>()
                              .add(AadharNumberChanged(val));
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text("Upload Aadhaar Images",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text("Upload both front and back sides.",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildImageBox(context, 0, images[0]),
                          _buildImageBox(context, 1, images[1]),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (isOtpSent && !isVerified) ...[
                        const Text(
                          "Enter OTP sent to your Aadhaar-linked number",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter OTP",
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.deepPurple, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.deepPurple, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state is AadharLoading ||
                                  state is AadharVerifying
                              ? null
                              : () {
                                  if (!isOtpSent && !isVerified) {
                                    context.read<AadharBloc>().add(
                                          SubmitAadharDetails(
                                            aadharNumber: bloc.aadharNumber,
                                            images: bloc.images,
                                          ),
                                        );
                                  } else if (isOtpSent && !isVerified) {
                                    context.read<AadharBloc>().add(
                                          VerifyAadharOtp(
                                            otp: otpController.text,
                                            refId: bloc.refId ?? '',
                                          ),
                                        );
                                  } else if (isVerified) {
                                    // Navigate back to OnboardingScreen and mark as entered
                                    context.read<OnboardingBloc>().add(
                                        DataEntered(OnboardingStep.aadhaar));
                                    Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFffd700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: (state is AadharLoading ||
                                  state is AadharVerifying)
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : Text(
                                  isVerified
                                      ? "Continue"
                                      : isOtpSent
                                          ? "Verify OTP"
                                          : "Send OTP",
                                  style: const TextStyle(
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
      ),
    );
  }

  Widget _buildImageBox(BuildContext context, int index, String imagePath) {
    return GestureDetector(
      onTap: () => _pickImage(context, index),
      child: Container(
        height: 120,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFffd700), width: 2),
          borderRadius: BorderRadius.circular(12),
          image: imagePath.isNotEmpty
              ? DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath.isEmpty
            ? const Center(
                child: Icon(Icons.camera_alt, color: Colors.grey, size: 40),
              )
            : const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Icon(Icons.check_circle, color: const Color(0xFFffd700)),
                ),
              ),
      ),
    );
  }
}
