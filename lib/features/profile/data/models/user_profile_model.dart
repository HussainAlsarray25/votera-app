import 'package:votera/features/profile/domain/entities/user_profile.dart';

class ProfileIdentifierModel extends ProfileIdentifier {
  const ProfileIdentifierModel({
    required super.id,
    required super.type,
    required super.value,
    required super.isVerified,
  });

  factory ProfileIdentifierModel.fromJson(Map<String, dynamic> json) {
    return ProfileIdentifierModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      value: json['value'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'is_verified': isVerified,
    };
  }
}

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.roles,
    required super.identifiers,
    super.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      roles: List<String>.from(json['roles'] as List? ?? []),
      identifiers: (json['identifiers'] as List? ?? [])
          .map((e) =>
              ProfileIdentifierModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      avatarUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'roles': roles,
      'identifiers': identifiers
          .map((e) => ProfileIdentifierModel(
                id: e.id,
                type: e.type,
                value: e.value,
                isVerified: e.isVerified,
              ).toJson(),)
          .toList(),
      'profile_picture_url': avatarUrl,
    };
  }
}
