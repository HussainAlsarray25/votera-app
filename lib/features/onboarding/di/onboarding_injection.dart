import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:votera/features/onboarding/data/services/onboarding_service.dart';

void initOnboardingFeature(GetIt sl) {
  sl.registerLazySingleton<OnboardingService>(
    () => OnboardingServiceImpl(sl<SharedPreferences>()),
  );
}
