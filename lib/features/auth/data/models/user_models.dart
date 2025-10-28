import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
    };
  }
}