import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../bloc/onboarding_bloc.dart' hide SubmitPanDetails;
import '../bloc/pan/pan_bloc.dart';

class PanVerificationScreen extends StatefulWidget {
  const PanVerificationScreen({super.key});

  @override
  State<PanVerificationScreen> createState() => _PanVerificationScreenState();
}

class _PanVerificationScreenState extends State<PanVerificationScreen> {
  Future<String?> uploadPanImage(String imagePath) async {
    if (imagePath.isEmpty) return null;
    final allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp'
    ];
    if (!allowedExtensions.any((e) => imagePath.toLowerCase().endsWith(e))) {
      print('PAN image upload skipped: not an allowed image type ($imagePath)');
      return null;
    }
    print('Uploading PAN image: $imagePath');
    final url = Uri.parse('http://192.168.1.43:5008/api/upload/image');
    final request = http.MultipartRequest('POST', url);
    String mimeType = 'image/jpeg';
    if (imagePath.toLowerCase().endsWith('.png')) mimeType = 'image/png';
    if (imagePath.toLowerCase().endsWith('.gif')) mimeType = 'image/gif';
    if (imagePath.toLowerCase().endsWith('.bmp')) mimeType = 'image/bmp';
    if (imagePath.toLowerCase().endsWith('.webp')) mimeType = 'image/webp';
    final file = File(imagePath);
    request.files.add(
      http.MultipartFile(
        'image',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('PAN image upload response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final url = data['imageUrl'] ??
          data['url'] ??
          data['secure_url'] ??
          data['data'] ??
          null;
      if (url == null) {
        print(
            'PAN image upload succeeded but no URL found in response: ${response.body}');
      }
      return url;
    } else {
      print('PAN image upload failed: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  Future<void> submitPanDetails(BuildContext context, String panNumber,
      String dob, String imagePath) async {
    // Format DOB as yyyy-MM-dd
    DateTime? parsedDob;
    try {
      parsedDob = DateFormat('dd/MM/yyyy').parse(dob);
    } catch (_) {
      parsedDob = null;
    }
    final formattedDob =
        parsedDob != null ? DateFormat('yyyy-MM-dd').format(parsedDob) : dob;
    // Upload image
    String? imageUrl;
    if (imagePath.isNotEmpty) {
      imageUrl = await uploadPanImage(imagePath);
    }
    // Send PAN details
    final body = {
      "panNumber": panNumber,
      "dateOfBirth": formattedDob,
      "panCardImage": imageUrl ?? '',
    };
    // Get token from secure storage
    String? token;
    try {
      final storage = FlutterSecureStorage();
      token = await storage.read(key: 'auth_token');
    } catch (_) {
      token = null;
    }
    print('PAN SUBMIT: body = ' + jsonEncode(body));
    print('PAN SUBMIT: token = $token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Auth token not found. Please login again.')),
      );
      return;
    }
    final response = await http.put(
      Uri.parse('http://192.168.1.43:5008/api/driver/pan'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    print('PAN SUBMIT: response = ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PAN details submitted successfully!')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } else {
      String msg = 'Failed to submit PAN: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null) msg = data['message'];
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  final panController = TextEditingController();
  final dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dobController.text = '20/05/1990';
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final bloc = context.read<PanBloc>();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && mounted) {
      bloc.add(PanImagePicked(pickedFile.path));
    }
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PanBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFFf5c034),
              elevation: 0,
              centerTitle: true,
              title: const Text("PAN Verification",
                  style: TextStyle(color: Colors.black)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocConsumer<PanBloc, PanState>(
                  listener: (context, state) {
                    if (state is PanVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ PAN details saved successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is PanError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(state.message),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final bloc = context.read<PanBloc>();
                    final imagePath = bloc.imagePath;
                    final isVerified = state is PanVerified;
                    final isLoading = state is PanLoading;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Enter PAN details",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              "We need to verify your identity for compliance",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          const Text("PAN Number",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: panController,
                            maxLength: 10,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: "Enter PAN Number",
                              counterText: "",
                              prefixIcon: const Icon(Icons.credit_card,
                                  color: Color(0xFFf5c034)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                              ),
                            ),
                            onChanged: (val) => bloc.add(PanNumberChanged(val)),
                          ),
                          const SizedBox(height: 16),
                          const Text("Date of Birth",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: dobController,
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today,
                                  color: Color(0xFFf5c034)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFf5c034), width: 2),
                              ),
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1994, 5, 16),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                final formatted =
                                    DateFormat('dd/MM/yyyy').format(date);
                                dobController.text = formatted;
                                bloc.add(PanDobChanged(formatted));
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text("Upload PAN Card",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showImageSourceSheet(context),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFf5c034), width: 2),
                              ),
                              child: imagePath == null ||
                                      !File(imagePath).existsSync()
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload,
                                              color: Color(0xFFf5c034),
                                              size: 50),
                                          SizedBox(height: 6),
                                          Text("Upload PAN Card Image",
                                              style: TextStyle(
                                                  color: Color(0xFFf5c034))),
                                          Text(
                                              "Tap to select from camera or gallery",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(File(imagePath),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFf5c034),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!isVerified) {
                                        await submitPanDetails(
                                          context,
                                          panController.text,
                                          dobController.text,
                                          bloc.imagePath ?? '',
                                        );
                                      } else {
                                        context.read<OnboardingBloc>().add(
                                            DataEntered(OnboardingStep.pan));
                                        Navigator.pop(context);
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black)
                                  : Text(
                                      isVerified ? "Continue" : "Save",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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
