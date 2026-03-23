import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:votera/core/constants/app_constants.dart';
import 'package:votera/features/profile/data/models/user_profile_model.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfile?> getCachedProfile();
  Future<void> cacheProfile(UserProfile profile);
  Future<void> clearCache();
}

class SharedPrefsProfileLocalDataSource implements ProfileLocalDataSource {
  const SharedPrefsProfileLocalDataSource({required this.prefs});

  final SharedPreferences prefs;

  @override
  Future<UserProfile?> getCachedProfile() async {
    final raw = prefs.getString(AppConstants.cachedProfileKey);
    if (raw == null) return null;
    return UserProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> cacheProfile(UserProfile profile) async {
    final model = UserProfileModel(
      id: profile.id,
      fullName: profile.fullName,
      roles: profile.roles,
      identifiers: profile.identifiers,
    );
    await prefs.setString(
      AppConstants.cachedProfileKey,
      jsonEncode(model.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await prefs.remove(AppConstants.cachedProfileKey);
  }
}
