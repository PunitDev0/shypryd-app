import 'dart:convert';
import 'package:http/http.dart' as http;

class PanRepository {
  final String clientId = "YOUR_CLIENT_ID";
  final String clientSecret =
      "YOUR_CLIENT_SECRET";

  Future<Map<String, dynamic>> verifyPan(
      String panNumber, String dob, String? imagePath) async {
    final url = Uri.parse("https://api.cashfree.com/verification/pan");

    final headers = {
      "x-client-id": clientId,
      "x-client-secret": clientSecret,
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "pan": panNumber,
      "dob": dob,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed PAN verification: ${response.statusCode} → ${response.body}");
    }
  }
}
