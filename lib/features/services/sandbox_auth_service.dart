import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SandboxAuthService {
  static final SandboxAuthService _instance = SandboxAuthService._internal();
  factory SandboxAuthService() => _instance;
  SandboxAuthService._internal();

  String? _token;
  DateTime? _expiry;

  Future<String> getToken() async {
    if (_token != null &&
        _expiry != null &&
        DateTime.now().isBefore(_expiry!)) {
      return _token!;
    }

    final response = await http.post(
      Uri.parse("https://api.sandbox.co.in/authenticate"),
      headers: {
        "x-api-key": dotenv.env['SANDBOX_API_KEY']!,
        "x-api-secret": dotenv.env['SANDBOX_API_SECRET']!,
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);
    final token = data["access_token"];

    final decoded = _decodeJwt(token);
    _token = token;
    _expiry = DateTime.fromMillisecondsSinceEpoch(decoded["exp"] * 1000);

    return _token!;
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split(".");
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }
}
