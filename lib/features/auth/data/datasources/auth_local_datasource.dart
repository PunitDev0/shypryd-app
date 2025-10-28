import 'package:ridezzy_app/features/auth/data/models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import 'dart:convert'; // For jsonDecode

abstract class AuthLocalDataSource {
  Future<void> cacheUser(String userData);
  Future<User?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(String userData) {
    return sharedPreferences.setString('USER_DATA', userData);
  }

  @override
  Future<User?> getCachedUser() async {
    final cachedString = sharedPreferences.getString('USER_DATA');
    if (cachedString == null) return null;
    try {
      final jsonMap = jsonDecode(cachedString) as Map<String, dynamic>;
      final userModel = UserModel.fromJson(jsonMap);
      return userModel; // UserModel extends User, so it returns User
    } catch (e) {
      // Handle parse error
      return null;
    }
  }
}
