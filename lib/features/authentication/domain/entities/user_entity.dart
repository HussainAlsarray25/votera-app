import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.status,
  });

  final String id;
  final String fullName;
  final String email;
  final String status;

  @override
  List<Object?> get props => [id, fullName, email, status];
}
