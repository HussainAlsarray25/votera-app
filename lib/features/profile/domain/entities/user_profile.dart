import 'package:equatable/equatable.dart';

/// Represents a single identifier (e.g. email or phone) attached to a user account.
class ProfileIdentifier extends Equatable {
  const ProfileIdentifier({
    required this.id,
    required this.type,
    required this.value,
    required this.isVerified,
  });

  final String id;
  final String type;
  final String value;
  final bool isVerified;

  @override
  List<Object?> get props => [id, type, value, isVerified];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.roles,
    required this.identifiers,
  });

  final String id;
  final String fullName;
  final List<String> roles;
  final List<ProfileIdentifier> identifiers;

  /// Extracts the primary email from the identifiers list.
  String? get email =>
      identifiers.where((i) => i.type == 'email').map((i) => i.value).firstOrNull;

  /// Returns true if the user has the given role.
  /// Use this inline wherever a page or widget needs to be gated by role.
  bool hasRole(String role) => roles.contains(role);

  @override
  List<Object?> get props => [id, fullName, roles, identifiers];
}
