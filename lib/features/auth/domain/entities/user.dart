import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phone;

  const User({
    required this.id,
    required this.phone,
  });

  @override
  List<Object> get props => [id, phone];
}