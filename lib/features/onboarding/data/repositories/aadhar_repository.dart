import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/asymmetric/api.dart' as crypto;
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:asn1lib/asn1lib.dart';

class AadhaarRepository {
  final String baseUrl = "https://api.cashfree.com/verification"; // Production

  /// ✅ Loads your PEM public key from assets
  Future<String> _loadPublicKey() async {
    try {
      return await rootBundle.loadString(
          'assets/accountId_87413_public_key.pem'); // Make sure this path exists
    } catch (e) {
      throw Exception('Failed to load public key: $e');
    }
  }

  /// ✅ Parses PEM string to RSAPublicKey
  crypto.RSAPublicKey _parsePublicKey(String pemString) {
    final lines =
        pemString.split('\n').where((l) => !l.startsWith('-----')).toList();
    final base64Str = lines.join('');
    final derBytes = base64.decode(base64Str);

    final asn1Parser = ASN1Parser(derBytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    // ✅ For PKCS#8 / SPKI: extract the BIT STRING that contains the key
    var publicKeyBitString = topLevelSeq.elements[1] as ASN1BitString;
    final publicKeyAsn =
        ASN1Parser(publicKeyBitString.stringValue as Uint8List);
    final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;

    final modulus = (publicKeySeq.elements[0] as ASN1Integer).valueAsBigInteger;
    final exponent =
        (publicKeySeq.elements[1] as ASN1Integer).valueAsBigInteger;

    return crypto.RSAPublicKey(modulus, exponent);
  }

  /// ✅ Generate Cashfree signature using RSA public key
  Future<String> _generateSignature(String clientId) async {
    final publicKeyString = await _loadPublicKey();
    final publicKey = _parsePublicKey(publicKeyString);

    final timestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
    final data = '$clientId.$timestamp';
    final dataBytes = utf8.encode(data);

    final encryptor = OAEPEncoding(RSAEngine())
      ..init(
        true,
        crypto.PublicKeyParameter<crypto.RSAPublicKey>(publicKey),
      );

    final cipherText = encryptor.process(Uint8List.fromList(dataBytes));
    return base64Encode(cipherText);
  }

  /// ✅ Send Aadhaar OTP using Cashfree API
  Future<String> sendAadhaarOtp(String aadhaarNumber) async {
    final clientId = dotenv.env['CASHFREE_CLIENT_ID'];
    final clientSecret = dotenv.env['CASHFREE_CLIENT_SECRET'];

    if (clientId == null || clientSecret == null) {
      throw Exception(
          "CASHFREE_CLIENT_ID or CASHFREE_CLIENT_SECRET missing in .env");
    }

    final signature = await _generateSignature(clientId);
    final url = Uri.parse("$baseUrl/offline-aadhaar/otp");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-client-id": clientId,
        "x-client-secret": clientSecret,
        "x-cf-signature": signature,
      },
      body: jsonEncode({"aadhaar_number": aadhaarNumber}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["ref_id"] == null) {
        throw Exception("No ref_id in response: ${response.body}");
      }
      return data["ref_id"];
    } else {
      throw Exception(
          "Failed OTP request: ${response.statusCode} → ${response.body}");
    }
  }

  /// ✅ Verify Aadhaar OTP using Cashfree API
  Future<Map<String, dynamic>> verifyAadhaarOtp(
      String refId, String otp) async {
    final clientId = dotenv.env['CASHFREE_CLIENT_ID'];
    final clientSecret = dotenv.env['CASHFREE_CLIENT_SECRET'];

    final signature = await _generateSignature(clientId!);
    final url = Uri.parse("$baseUrl/offline-aadhaar/verify");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-client-id": clientId,
        "x-client-secret": clientSecret!,
        "x-cf-signature": signature,
      },
      body: jsonEncode({"ref_id": refId, "otp": otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Verification failed: ${response.statusCode} → ${response.body}");
    }
  }
}
