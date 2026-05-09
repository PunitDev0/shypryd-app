import 'dart:convert';

import 'package:Maxryd_app/core/error/exceptions.dart';
import 'package:Maxryd_app/features/auth/data/models/auth_response.dart';

import 'package:Maxryd_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber); // returns nothing on success
  Future<AuthResponse> verifyOtp(PhoneOtpParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String baseUrl = 'http://192.168.1.43:5008';

  @override
  Future<void> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/send-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Send OTP API Response: $data');
      if (data['success'] == true) {
        // OTP sent successfully, nothing to return
        return;
      } else {
        throw ServerException(data['message'] ?? 'OTP send failed');
      }
    } else {
      print('Send OTP API Error: ${response.statusCode} - ${response.body}');
      throw ServerException(
        'Failed to send OTP: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Future<AuthResponse> verifyOtp(PhoneOtpParams params) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone': params.phone,
        'otp': params.otp,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Verify OTP API Response: $data');
      if (data['success'] == true) {
        return AuthResponse.fromJson(data);
      } else {
        throw ServerException(
            data['error'] ?? data['message'] ?? 'Verification failed');
      }
    } else {
      print('Verify OTP API Error: ${response.statusCode} - ${response.body}');
      throw ServerException(
        'Failed to verify OTP: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
