import '../../domain/entities/user.dart';

class UserModel extends User {
  final bool isProfileCompleted;

  const UserModel({
    required super.id,
    required super.phone,
    required this.isProfileCompleted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '', // handle both _id and id
      phone: json['phone'] as String? ?? '',
      isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'isProfileCompleted': isProfileCompleted,
    };
  }
}