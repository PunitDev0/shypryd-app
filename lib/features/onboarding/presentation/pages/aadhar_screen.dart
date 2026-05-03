import "package:ShipRyd_app/core/constants/api_constants.dart";
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:ShipRyd_app/features/onboarding/data/repositories/aadhar_repository.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/aadhar/aadhar_bloc.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AadharVerificationScreen extends StatelessWidget {
  /// Uploads an image file to the upload API and returns the image URL.
  Future<String?> uploadImage(String imagePath, String token) async {
    if (imagePath.isEmpty) {
      print('Image upload skipped: empty path');
      return null;
    }
    final allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp'
    ];
    final ext = imagePath.toLowerCase().split('.').last;
    if (!allowedExtensions.any((e) => imagePath.toLowerCase().endsWith(e))) {
      print('Image upload skipped: not an allowed image type ($imagePath)');
      return null;
    }
    print('Uploading image: $imagePath');
    final url = Uri.parse('${ApiConstants.baseUrl}/api/upload/image');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    final file = File(imagePath);
    String mimeType = 'image/jpeg';
    if (imagePath.toLowerCase().endsWith('.png')) mimeType = 'image/png';
    if (imagePath.toLowerCase().endsWith('.gif')) mimeType = 'image/gif';
    if (imagePath.toLowerCase().endsWith('.bmp')) mimeType = 'image/bmp';
    if (imagePath.toLowerCase().endsWith('.webp')) mimeType = 'image/webp';
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
    print('Image upload response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Use the correct field from your backend response
      final url = data['imageUrl'] ??
          data['url'] ??
          data['secure_url'] ??
          data['data'] ??
          null;
      if (url == null) {
        print(
            'Image upload succeeded but no URL found in response: ${response.body}');
      }
      return url;
    } else {
      print('Image upload failed: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  /// Converts an image file path to a base64 string. Returns empty string if file not found.
  Future<String> _imageFileToBase64(String path) async {
    if (path.isEmpty) return '';
    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return '';
    }
  }

  /// Submits Aadhaar details to the backend API with image URLs.
  Future<void> submitAadhaarDetails({
    required BuildContext context,
    required String aadhaarNumber,
    required String frontImageUrl,
    required String backImageUrl,
    required String token,
  }) async {
    final body = {
      "aadhaarNumber": aadhaarNumber,
      "aadhaarFrontImage": frontImageUrl,
      "aadhaarBackImage": backImageUrl,
    };
    final url = Uri.parse('${ApiConstants.baseUrl}/api/driver/aadhaar');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Aadhaar details submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Aadhaar details submitted successfully!')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } else {
      String msg = 'Failed to submit Aadhaar: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null) msg = data['message'];
      } catch (_) {}
      print('Aadhaar submission failed: $msg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  const AadharVerificationScreen({super.key});

  Future<void> _pickImage(BuildContext modalContext, int index,
      void Function(String) onImagePicked) async {
    showModalBottomSheet(
      context: modalContext,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                Navigator.pop(modalContext);
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  onImagePicked(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                Navigator.pop(modalContext);
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  onImagePicked(pickedFile.path);
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
    // We'll use local state for images
    List<String> images = ['', ''];

    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf5c034),
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
          child: StatefulBuilder(
            builder: (statefulContext, setState) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your Aadhaar details for verification",
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
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
                            color: Color(0xFFf5c034), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFf5c034), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Upload Aadhaar Images",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text("Upload both front and back sides.",
                      style: TextStyle(color: Colors.black.withOpacity(0.6))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildImageBox(
                          statefulContext, 0, images[0], setState, images),
                      _buildImageBox(
                          statefulContext, 1, images[1], setState, images),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
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
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        final frontUrl = await uploadImage(images[0], token);
                        final backUrl = await uploadImage(images[1], token);
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // Remove loading
                        if (frontUrl == null || backUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Image upload failed.\nCheck logs for details.\nFront: $frontUrl\nBack: $backUrl',
                                maxLines: 5,
                              ),
                            ),
                          );
                          return;
                        }
                        await submitAadhaarDetails(
                          context: context,
                          aadhaarNumber: aadharController.text.trim(),
                          frontImageUrl: frontUrl,
                          backImageUrl: backUrl,
                          token: token,
                        );
                      },
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
          ),
        ),
      ),
    );
  }

  Widget _buildImageBox(BuildContext modalContext, int index, String imagePath,
      void Function(void Function()) setState, List<String> images) {
    return GestureDetector(
      onTap: () async {
        await _pickImage(modalContext, index, (pickedImage) {
          setState(() {
            images[index] = pickedImage;
          });
        });
      },
      child: Container(
        height: 120,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFf5c034), width: 2),
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
                child: Icon(Icons.camera_alt, color: Colors.black.withOpacity(0.6), size: 40),
              )
            : const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.check_circle, color: Color(0xFFffd700)),
                ),
              ),
      ),
    );
  }
}
