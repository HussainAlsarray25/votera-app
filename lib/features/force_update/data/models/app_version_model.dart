import 'package:votera/features/force_update/domain/entities/app_version_entity.dart';

/// Data model for the version info returned by GET /v1/app-versions/latest.
///
/// Extends [AppVersionEntity] so the repository can return it directly
/// without an extra mapping step.
class AppVersionModel extends AppVersionEntity {
  const AppVersionModel({
    required super.id,
    required super.latestVersionCode,
    required super.latestVersionName,
    required super.minSupportedVersionCode,
    required super.updateUrl,
    required super.forceUpdate,
    required super.messageEn,
    required super.messageAr,
    required super.isActive,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      id: json['id']?.toString() ?? '',
      latestVersionCode: json['latest_version_code']?.toString() ?? '',
      latestVersionName: json['latest_version_name']?.toString() ?? '',
      minSupportedVersionCode:
          json['min_supported_version_code']?.toString() ?? '',
      updateUrl: json['update_url']?.toString() ?? '',
      forceUpdate: json['force_update'] as bool? ?? false,
      messageEn: json['message_en']?.toString() ?? '',
      messageAr: json['message_ar']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
