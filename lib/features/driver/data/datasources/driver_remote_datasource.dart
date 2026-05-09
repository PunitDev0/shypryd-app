import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Maxryd_app/core/error/exceptions.dart';
import 'package:Maxryd_app/features/driver/data/models/driver_profile_model.dart';

abstract class DriverRemoteDataSource {
  Future<DriverProfileModel> fetchDriverProfile(String token);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  static const String baseUrl = 'http://192.168.1.43:5008';

  @override
  Future<DriverProfileModel> fetchDriverProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/driver/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Driver Profile API Response: $data');
      if (data['success'] == true && data['driver'] != null) {
        return DriverProfileModel.fromJson(data['driver']);
      } else {
        throw ServerException(
            data['message'] ?? 'Failed to fetch driver profile');
      }
    } else {
      print(
          'Driver Profile API Error: ${response.statusCode} - ${response.body}');
      throw ServerException(
          'Failed to fetch driver profile: ${response.statusCode} - ${response.body}');
    }
  }
}
