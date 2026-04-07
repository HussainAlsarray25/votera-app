import 'package:equatable/equatable.dart';

/// Represents the version information returned by GET /v1/app-versions/latest.
class AppVersionEntity extends Equatable {
  const AppVersionEntity({
    required this.id,
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.minSupportedVersionCode,
    required this.updateUrl,
    required this.forceUpdate,
    required this.messageEn,
    required this.messageAr,
    required this.isActive,
  });

  final String id;

  /// Version code used for comparison (e.g. "10200" for 1.2.0).
  final String latestVersionCode;

  /// Human-readable version name (e.g. "1.2.0").
  final String latestVersionName;

  /// Minimum version code the app must be at to continue operating.
  final String minSupportedVersionCode;

  /// The URL to the store or download page.
  final String updateUrl;

  /// When true, the user must update before continuing — set by the server.
  final bool forceUpdate;

  /// Localized update message in English.
  final String messageEn;

  /// Localized update message in Arabic.
  final String messageAr;

  /// Whether this version entry is active on the server.
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        latestVersionCode,
        latestVersionName,
        minSupportedVersionCode,
        updateUrl,
        forceUpdate,
        messageEn,
        messageAr,
        isActive,
      ];
}
