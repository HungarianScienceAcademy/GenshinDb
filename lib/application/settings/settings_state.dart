part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.loading() = _LoadingState;
  const factory SettingsState.loaded({
    required AppThemeType currentTheme,
    required bool useDarkAmoledTheme,
    required AppAccentColorType currentAccentColor,
    required AppLanguageType currentLanguage,
    required String appVersion,
    required bool showCharacterDetails,
    required bool showWeaponDetails,
    required AppServerResetTimeType serverResetTime,
    required bool doubleBackToClose,
    required bool useOfficialMap,
    required bool useTwentyFourHoursFormat,
    required List<AppUnlockedFeature> unlockedFeatures,
  }) = _LoadedState;
}
