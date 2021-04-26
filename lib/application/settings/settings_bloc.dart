import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';

import '../bloc.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final MainBloc _mainBloc;
  final HomeBloc _homeBloc;

  SettingsBloc(this._settingsService, this._deviceInfoService, this._mainBloc, this._homeBloc) : super(const SettingsState.loading());

  _LoadedState get currentState => state as _LoadedState;

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    final s = await event.map(
      init: (_) async {
        final settings = _settingsService.appSettings;
        return SettingsState.loaded(
          currentTheme: settings.appTheme,
          currentAccentColor: settings.accentColor,
          currentLanguage: settings.appLanguage,
          appVersion: _deviceInfoService.version,
          showCharacterDetails: settings.showCharacterDetails,
          showWeaponDetails: settings.showWeaponDetails,
          serverResetTime: settings.serverResetTime,
          doubleBackToClose: settings.doubleBackToClose,
        );
      },
      themeChanged: (event) async {
        _settingsService.appTheme = event.newValue;
        _mainBloc.add(MainEvent.themeChanged(newValue: event.newValue));
        return currentState.copyWith.call(currentTheme: event.newValue);
      },
      accentColorChanged: (event) async {
        _settingsService.accentColor = event.newValue;
        _mainBloc.add(MainEvent.accentColorChanged(newValue: event.newValue));
        return currentState.copyWith.call(currentAccentColor: event.newValue);
      },
      languageChanged: (event) async {
        _settingsService.language = event.newValue;
        _mainBloc.add(MainEvent.languageChanged(newValue: event.newValue));
        return currentState.copyWith.call(currentLanguage: event.newValue);
      },
      showCharacterDetailsChanged: (event) async {
        _settingsService.showCharacterDetails = event.newValue;
        return currentState.copyWith.call(showCharacterDetails: event.newValue);
      },
      showWeaponDetailsChanged: (event) async {
        _settingsService.showWeaponDetails = event.newValue;
        return currentState.copyWith.call(showWeaponDetails: event.newValue);
      },
      serverResetTimeChanged: (event) async {
        _settingsService.serverResetTime = event.newValue;
        _homeBloc.add(const HomeEvent.init());
        return currentState.copyWith.call(serverResetTime: event.newValue);
      },
      doubleBackToCloseChanged: (event) async {
        _settingsService.doubleBackToClose = event.newValue;
        return currentState.copyWith.call(doubleBackToClose: event.newValue);
      },
    );

    yield s;
  }

  bool doubleBackToClose() => _settingsService.doubleBackToClose;
}
