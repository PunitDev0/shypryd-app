import "package:ShipRyd_app/core/constants/api_constants.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import 'package:ShipRyd_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  // These should match backend enums/IDs
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final Map<String, String> genderApiMap = {
    'Male': 'Male',
    'male': 'Male',
    'Female': 'Female',
    'female': 'Female',
    'Other': 'Other',
    'other': 'Other',
  };
  final Map<String, String> regionToZoneId = {
    // TODO: Replace with actual zone IDs from backend
    'Delhi NCR': '65c0e7e2e2b7e2b7e2b7e2b7',
    'Mumbai': '65c0e7e2e2b7e2b7e2b7e2b8',
    'Bangalore': '65c0e7e2e2b7e2b7e2b7e2b9',
    'Chandigarh': '65c0e7e2e2b7e2b7e2b7e2ba',
  };
  Future<void> _submitPersonalInfo() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Auth token not found. Please login again.')),
      );
      return;
    }
    final zoneId = regionToZoneId[serviceRegion];
    if (zoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid service region.')),
      );
      return;
    }
    final genderApi = genderApiMap[gender] ?? 'male';
    final body = {
      "personalInformation": {
        "fullName": _fullName.text,
        "gender": genderApi,
        "serviceRegion": serviceRegion,
        "currentFullAddress": _address.text,
        "zone": zoneId,
        "emergencyReference1": {
          "referenceName": _ref1Name.text,
          "referenceRelation": _ref1Relation.text,
          "referencePhoneNumber": _ref1Number.text,
        },
        "emergencyReference2": {
          "referenceName": _ref2Name.text,
          "referenceRelation": _ref2Relation.text,
          "referencePhoneNumber": _ref2Number.text,
        }
      }
    };
    final url = Uri.parse('${ApiConstants.baseUrl}/api/driver/personal-info');
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
      print('Personal details submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Personal details submitted successfully!')),
      );
      print('Snackbar: Personal details submitted successfully!');
      if (mounted) Navigator.pop(context);
    } else {
      String msg = 'Failed to submit: [1m${response.statusCode}[0m';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null) msg = data['message'];
      } catch (_) {}
      print('Personal details submission failed: $msg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      print('Snackbar: $msg');
    }
  }

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
  // Removed OTP verification flags

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

  // Removed OTP popup and verification logic for references

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf5c034),
        elevation: 0,
        centerTitle: true,
        title: const Text('Personal Details',
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Tell us about yourself",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
                "We need some basic information to set up your driver profile",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
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
                    color: Color.fromARGB(255, 188, 188, 188),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFf5c034),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    color: Color(0xFFf5c034),
                    width: 1.5,
                  ),
                ),
              ),
              items: ['Delhi NCR', 'Mumbai', 'Bangalore', 'Chandigarh']
                  .map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
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
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Emergency References (Revamped UI)
            const Text("Emergency References",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

// Reference 1
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6).shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reference 1",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildReferenceField(
                    controller: _ref1Name,
                    hint: "Reference name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildReferenceField(
                    controller: _ref1Relation,
                    hint: "Reference relation",
                    icon: Icons.family_restroom,
                  ),
                  const SizedBox(height: 10),
                  _buildReferencePhoneFieldSimple(
                    controller: _ref1Number,
                  ),
                ],
              ),
            ),

// Reference 2
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6).shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reference 2",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildReferenceField(
                    controller: _ref2Name,
                    hint: "Reference name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildReferenceField(
                    controller: _ref2Relation,
                    hint: "Reference relation",
                    icon: Icons.family_restroom,
                  ),
                  const SizedBox(height: 10),
                  _buildReferencePhoneFieldSimple(
                    controller: _ref2Number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitPersonalInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf5c034),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  const Text("Continue", style: TextStyle(color: Colors.black)),
            ),
          ],
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
            color: isSelected ? const Color(0xFFf5c034) : const Color(0xFFf5c034),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.6).shade300),
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

Widget _buildReferenceField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFf5c034),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}

Widget _buildReferencePhoneFieldSimple({
  required TextEditingController controller,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFf5c034),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: const InputDecoration(
        counterText: '',
        prefixIcon: Icon(Icons.phone),
        hintText: "Phone number",
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
