import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:ridezzy_app/core/error/exceptions.dart';
import 'package:ridezzy_app/features/auth/domain/usescases/phone_otp_params.dart';
import 'dart:convert';

import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> loginWithPhone(String phoneNumber);
  Future<User> verifyOtp(PhoneOtpParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String _apiKey =
      "bc31B2Orn7puoDKAzsqFWMv9C5iNdgEQPx0wtHfRySUZlVYh6JSGkWil6wnVajL30yYEK2UM5dHDzTst";
  static const String _senderId = "RIDZYO"; // Your OTP sender
  static const String _templateId = "188950"; // Your OTP template ID
  static const String _entityId = "1001215398339008228";
  final Map<String, String> _pendingOtps =
      {}; // In-memory: nationalNumber -> OTP

  // Fixed: Fetch templates across ALL senders (not just first)
  static Future<String?> fetchOtpTemplateId() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.fast2sms.com/dev/dlt_manager?authorization=$_apiKey&type=template'),
      );
      print('Fetch Response Status: ${response.statusCode}'); // Debug
      print('Fetch Response Body: ${response.body}'); // Full JSON for check

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List?;
        if (data != null && data.isNotEmpty) {
          // Loop through ALL senders (e.g., RIDZYS and RIDZYO)
          for (var sender in data) {
            final templates = sender['templates'] as List?;
            if (templates != null) {
              for (var temp in templates) {
                if (temp['message'].toString().contains('One-Time Password')) {
                  final id = temp['message_id'].toString();
                  print(
                      'Found OTP Template ID: $id for sender ${sender['sender_id']}'); // Log match
                  return id;
                }
              }
            }
          }
        }
      }
      print('No OTP template matched in any sender'); // If none found
    } catch (e) {
      print('Fetch Error: $e');
    }
    return null;
  }

  @override
  Future<User> loginWithPhone(String phoneNumber) async {
    final nationalNumber = phoneNumber.substring(1); // e.g., "91234567890"
    final otp = (Random().nextInt(9000) + 1000).toString(); // 4-digit

    String templateIdToUse = _templateId; // Default to const

    // Optional: Try dynamic fetch (now fixed to check all senders)
    // Uncomment below to enable auto-fetch; comment to use hardcoded only
    final dynamicTemplateId = await fetchOtpTemplateId();
    if (dynamicTemplateId != null) {
      templateIdToUse = dynamicTemplateId;
      print('Using dynamic Template ID: $templateIdToUse');
    } else {
      print(
          'Dynamic fetch failed; falling back to hardcoded: $templateIdToUse');
      // Uncomment to throw if you want strict fetch: throw ServerException('No OTP template found');
    }

    final body = {
      "route": "dlt",
      "sender_id": _senderId,
      "message": templateIdToUse, // Use resolved ID
      "variables_values": otp, // Replaces {#VAR#}
      "entity_id": _entityId,
      "flash": 0,
      "numbers": nationalNumber,
    };

    print('API Body: ${jsonEncode(body)}'); // Debug full request
    print('Sending OTP to $nationalNumber');

    final response = await http.post(
      Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
      headers: {
        'authorization': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('Fast2Sms Response Status: ${response.statusCode}'); // Log
    print('Fast2Sms Response Body: ${response.body}'); // Full response

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final bool success = jsonResponse['return'] == true ||
          (jsonResponse['sms_reports'] != null &&
              jsonResponse['sms_reports'].isNotEmpty);
      if (success) {
        _pendingOtps[nationalNumber] = otp; // Store for verification
        return User(id: 'temp', phone: phoneNumber); // Partial user
      } else {
        final errorMsg = jsonResponse['message'] ?? 'Unknown API error';
        throw ServerException(
            'SMS failed: $errorMsg (e.g., Balance low or invalid ID)');
      }
    } else {
      throw ServerException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<User> verifyOtp(PhoneOtpParams params) async {
    final nationalNumber = params.phone.substring(1);
    if (_pendingOtps.containsKey(nationalNumber) &&
        _pendingOtps[nationalNumber] == params.otp) {
      _pendingOtps.remove(nationalNumber); // Expire after use
      return User(id: nationalNumber, phone: params.phone); // Full user
    } else {
      throw ServerException('Invalid or expired OTP');
    }
  }
}
