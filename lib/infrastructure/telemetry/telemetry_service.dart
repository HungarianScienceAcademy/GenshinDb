import 'package:enum_to_string/enum_to_string.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/telemetry/flutter_appcenter_bundle.dart';
import 'package:shiori/infrastructure/telemetry/secrets.dart';

class TelemetryServiceImpl implements TelemetryService {
  final DeviceInfoService _deviceInfoService;

  TelemetryServiceImpl(this._deviceInfoService);

  //Only call this function from the main.dart
  @override
  Future<void> initTelemetry() async {
    await AppCenter.startAsync(appSecretAndroid: Secrets.appCenterKey, appSecretIOS: '');
  }

  @override
  Future<void> trackEventAsync(String name, [Map<String, String>? properties]) {
    properties ??= {};
    properties.addAll(_deviceInfoService.deviceInfo);
    return AppCenter.trackEventAsync(name, properties);
  }

  @override
  Future<void> trackCharacterLoaded(String value) async {
    await trackEventAsync('Character-FromKey', {'Key': value});
  }

  @override
  Future<void> trackWeaponLoaded(String value) async {
    await trackEventAsync('Weapon-FromKey', {'Key': value});
  }

  @override
  Future<void> trackArtifactLoaded(String value) async {
    await trackEventAsync('Artifact-FromKey', {'Key': value});
  }

  @override
  Future<void> trackAscensionMaterialsOpened() async {
    await trackEventAsync('AscensionMaterials-Opened');
  }

  @override
  Future<void> trackUrlOpened(bool loadMap, bool loadWishSimulator, bool loadDailyCheckIn, bool networkAvailable) async {
    final props = {
      'NetworkAvailable': networkAvailable.toString(),
    };

    if (loadMap) {
      await trackEventAsync('Map-Opened', props);
    } else if (loadWishSimulator) {
      await trackEventAsync('WishSimulator-Opened', props);
    } else if (loadDailyCheckIn) {
      await trackEventAsync('DailyCheckIn-Opened', props);
    }
  }

  @override
  Future<void> trackCalculatorItemAscMaterialLoaded(String item) async {
    await trackEventAsync('Calculator-Asc-Mat', {
      'Name': item,
    });
  }

  @override
  Future<void> trackTierListOpened() => trackEventAsync('TierListBuilder-Opened');

  @override
  Future<void> trackInit(AppSettings settings) async {
    await trackEventAsync('Init', {
      'Theme': EnumToString.convertToString(settings.appTheme),
      'AccentColor': EnumToString.convertToString(settings.accentColor),
      'Language': EnumToString.convertToString(settings.appLanguage),
      'ShowCharacterDetails': settings.showCharacterDetails.toString(),
      'ShowWeaponDetails': settings.showWeaponDetails.toString(),
      'IsFirstInstall': settings.isFirstInstall.toString(),
      'ServerResetTime': EnumToString.convertToString(settings.serverResetTime),
      'DoubleBackToClose': settings.doubleBackToClose.toString(),
      'UseOfficialMap': settings.useOfficialMap.toString(),
    });
  }

  @override
  Future<void> trackGameCodesOpened() => trackEventAsync('GameCodes-Opened');

  @override
  Future<void> trackTierListBuilderScreenShootTaken() => trackEventAsync('TierListBuilder-ScreenShootTaken');

  @override
  Future<void> trackMaterialLoaded(String key) async {
    await trackEventAsync('Material-FromKey', {'Key': key});
  }

  @override
  Future<void> trackCalculatorAscMaterialsSessionsLoaded() => trackEventAsync('Calculator-Asc-Mat-Sessions-Loaded');

  @override
  Future<void> trackCalculatorAscMaterialsSessionsCreated() => trackEventAsync('Calculator-Asc-Mat-Sessions-Created');

  @override
  Future<void> trackCalculatorAscMaterialsSessionsUpdated() => trackEventAsync('Calculator-Asc-Mat-Sessions-Updated');

  @override
  Future<void> trackCalculatorAscMaterialsSessionsDeleted({bool all = false}) =>
      trackEventAsync('Calculator-Asc-Mat-Sessions-Deleted${all ? '-All' : ''}');

  @override
  Future<void> trackItemAddedToInventory(String key, int quantity) => trackEventAsync('MyInventory-Added', {'Key_Qty': '${key}_$quantity'});

  @override
  Future<void> trackItemDeletedFromInventory(String key) => trackEventAsync('MyInventory-Deleted', {'Key': key});

  @override
  Future<void> trackItemUpdatedInInventory(String key, int quantity) => trackEventAsync('MyInventory-Updated', {'Key_Qty': '${key}_$quantity'});

  @override
  Future<void> trackItemsDeletedFromInventory(ItemType type) =>
      trackEventAsync('MyInventory-Clear-All', {'Type': EnumToString.convertToString(type)});

  @override
  Future<void> trackNotificationCreated(AppNotificationType type) =>
      trackEventAsync('Notification-Created', {'Type': EnumToString.convertToString(type)});

  @override
  Future<void> trackNotificationDeleted(AppNotificationType type) =>
      trackEventAsync('Notification-Deleted', {'Type': EnumToString.convertToString(type)});

  @override
  Future<void> trackNotificationRestarted(AppNotificationType type) =>
      trackEventAsync('Notification-Restarted', {'Type': EnumToString.convertToString(type)});

  @override
  Future<void> trackNotificationStopped(AppNotificationType type) =>
      trackEventAsync('Notification-Stopped', {'Type': EnumToString.convertToString(type)});

  @override
  Future<void> trackNotificationUpdated(AppNotificationType type) =>
      trackEventAsync('Notification-Updated', {'Type': EnumToString.convertToString(type)});

  @override
  Future<void> trackCustomBuildSaved(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType) => trackEventAsync(
        'Custom-Build-Saved',
        {
          'CharKey': charKey,
          'RoleType': EnumToString.convertToString(roleType),
          'SubType': EnumToString.convertToString(subType),
        },
      );

  @override
  Future<void> trackCustomBuildScreenShootTaken(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType) => trackEventAsync(
        'Custom-Build-ScreenShootTaken',
        {
          'CharKey': charKey,
          'RoleType': EnumToString.convertToString(roleType),
          'SubType': EnumToString.convertToString(subType),
        },
      );
}
