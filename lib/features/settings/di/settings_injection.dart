import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:votera/features/settings/presentation/cubit/theme_cubit.dart';

void initSettingsFeature(GetIt sl) {
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<SharedPreferences>()),
  );
}
