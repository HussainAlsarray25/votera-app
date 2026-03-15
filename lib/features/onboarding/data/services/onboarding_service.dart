import 'package:shared_preferences/shared_preferences.dart';
import 'package:votera/core/constants/app_constants.dart';

abstract class OnboardingService {
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete();
}

class OnboardingServiceImpl implements OnboardingService {
  const OnboardingServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  @override
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(AppConstants.onboardingCompleteKey, true);
  }
}
