import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/utils/date_utils.dart';

class GenshinServiceImpl implements GenshinService {
  final LocaleService _localeService;

  late CharactersFile _charactersFile;
  late WeaponsFile _weaponsFile;
  late TranslationFile _translationFile;
  late ArtifactsFile _artifactsFile;
  late MaterialsFile _materialsFile;
  late ElementsFile _elementsFile;
  late MonstersFile _monstersFile;
  late GadgetsFile _gadgetsFile;
  late FurnitureFile _furnitureFile;
  late BannerHistoryFile _bannerHistoryFile;

  GenshinServiceImpl(this._localeService);

  @override
  Future<void> init(AppLanguageType languageType) async {
    await Future.wait([
      initCharacters(),
      initWeapons(),
      initArtifacts(),
      initMaterials(),
      initElements(),
      initMonsters(),
      initGadgets(),
      initFurniture(),
      initBannerHistory(),
      initTranslations(languageType),
    ]);
  }

  @override
  Future<void> initCharacters() async {
    final jsonStr = await rootBundle.loadString(Assets.charactersDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _charactersFile = CharactersFile.fromJson(json);
  }

  @override
  Future<void> initWeapons() async {
    final jsonStr = await rootBundle.loadString(Assets.weaponsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _weaponsFile = WeaponsFile.fromJson(json);
  }

  @override
  Future<void> initArtifacts() async {
    final jsonStr = await rootBundle.loadString(Assets.artifactsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _artifactsFile = ArtifactsFile.fromJson(json);
  }

  @override
  Future<void> initMaterials() async {
    final jsonStr = await rootBundle.loadString(Assets.materialsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _materialsFile = MaterialsFile.fromJson(json);
  }

  @override
  Future<void> initElements() async {
    final jsonStr = await rootBundle.loadString(Assets.elementsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _elementsFile = ElementsFile.fromJson(json);
  }

  @override
  Future<void> initMonsters() async {
    final jsonStr = await rootBundle.loadString(Assets.monstersDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _monstersFile = MonstersFile.fromJson(json);
  }

  @override
  Future<void> initGadgets() async {
    final jsonStr = await rootBundle.loadString(Assets.gadgetsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _gadgetsFile = GadgetsFile.fromJson(json);
    assert(
      _gadgetsFile.gadgets.map((e) => e.key).toSet().length == _gadgetsFile.gadgets.length,
      'All the gadgets keys must be unique',
    );
  }

  @override
  Future<void> initFurniture() async {
    final jsonStr = await rootBundle.loadString(Assets.furnitureDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _furnitureFile = FurnitureFile.fromJson(json);
    assert(
      _furnitureFile.furniture.map((e) => e.key).toSet().length == _furnitureFile.furniture.length,
      'All the furniture keys must be unique',
    );
  }

  @override
  Future<void> initBannerHistory() async {
    final jsonStr = await rootBundle.loadString(Assets.bannerHistoryDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _bannerHistoryFile = BannerHistoryFile.fromJson(json);
  }

  @override
  Future<void> initTranslations(AppLanguageType languageType) async {
    final transJsonStr = await rootBundle.loadString(Assets.getTranslationPath(languageType));
    final transJson = jsonDecode(transJsonStr) as Map<String, dynamic>;
    _translationFile = TranslationFile.fromJson(transJson);
  }

  @override
  List<CharacterCardModel> getCharactersForCard() {
    return _charactersFile.characters.map((e) => _toCharacterForCard(e)).toList();
  }

  @override
  CharacterFileModel getCharacter(String key) {
    return _charactersFile.characters.firstWhere((element) => element.key == key);
  }

  @override
  List<TierListRowModel> getDefaultCharacterTierList(List<int> colors) {
    assert(colors.length == 7);

    final sssTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'sss')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();
    final ssTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'ss')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();
    final sTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 's')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();
    final aTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'a')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();
    final bTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'b')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();
    final cTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'c')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();
    final dTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'd')
        .map((char) => ItemCommon(char.key, Assets.getCharacterPath(char.image)))
        .toList();

    return <TierListRowModel>[
      TierListRowModel.row(tierText: 'SSS', tierColor: colors.first, items: sssTier),
      TierListRowModel.row(tierText: 'SS', tierColor: colors[1], items: ssTier),
      TierListRowModel.row(tierText: 'S', tierColor: colors[2], items: sTier),
      TierListRowModel.row(tierText: 'A', tierColor: colors[3], items: aTier),
      TierListRowModel.row(tierText: 'B', tierColor: colors[4], items: bTier),
      TierListRowModel.row(tierText: 'C', tierColor: colors[5], items: cTier),
      TierListRowModel.row(tierText: 'D', tierColor: colors.last, items: dTier),
    ];
  }

  @override
  List<WeaponCardModel> getWeaponsForCard() {
    return _weaponsFile.weapons.map((e) => _toWeaponForCard(e)).toList();
  }

  @override
  WeaponFileModel getWeapon(String key) {
    return _weaponsFile.weapons.firstWhere((element) => element.key == key);
  }

  @override
  List<ItemCommon> getCharacterForItemsUsingWeapon(String key) {
    final weapon = getWeapon(key);
    final items = <ItemCommon>[];
    for (final char in _charactersFile.characters.where((el) => !el.isComingSoon)) {
      for (final build in char.builds) {
        final isBeingUsed = build.weaponKeys.contains(weapon.key);
        if (isBeingUsed && !items.any((el) => el.key == char.key)) {
          items.add(ItemCommon(char.key, Assets.getCharacterPath(char.image)));
        }
      }
    }

    return items;
  }

  @override
  List<ArtifactCardModel> getArtifactsForCard({ArtifactType? type}) {
    return _artifactsFile.artifacts.map((e) => _toArtifactForCard(e, type: type)).where((e) {
      //if a type was provided and it is different that crown, then return only the ones with more than 1 bonus
      if (type != null && type != ArtifactType.crown) {
        return e.bonus.length > 1;
      }
      return true;
    }).toList();
  }

  @override
  ArtifactCardModel getArtifactForCard(String key) {
    final artifact = _artifactsFile.artifacts.firstWhere((a) => a.key == key);
    return _toArtifactForCard(artifact);
  }

  @override
  ArtifactFileModel getArtifact(String key) {
    return _artifactsFile.artifacts.firstWhere((a) => a.key == key);
  }

  @override
  List<ItemCommon> getCharacterForItemsUsingArtifact(String key) {
    final artifact = getArtifact(key);
    final items = <ItemCommon>[];
    for (final char in _charactersFile.characters.where((el) => !el.isComingSoon)) {
      for (final build in char.builds) {
        final isBeingUsed = build.artifacts.any((a) => a.oneKey == artifact.key || a.multiples.any((m) => m.key == artifact.key));

        if (isBeingUsed && !items.any((el) => el.key == char.key)) {
          items.add(ItemCommon(char.key, Assets.getCharacterPath(char.image)));
        }
      }
    }

    return items;
  }

  @override
  TranslationCharacterFile getCharacterTranslation(String key) {
    return _translationFile.characters.firstWhere((element) => element.key == key);
  }

  @override
  TranslationWeaponFile getWeaponTranslation(String key) {
    return _translationFile.weapons.firstWhere((element) => element.key == key);
  }

  @override
  TranslationArtifactFile getArtifactTranslation(String key) {
    return _translationFile.artifacts.firstWhere((t) => t.key == key);
  }

  @override
  TranslationMaterialFile getMaterialTranslation(String key) {
    return _translationFile.materials.firstWhere((t) => t.key == key);
  }

  @override
  TranslationMonsterFile getMonsterTranslation(String key) {
    return _translationFile.monsters.firstWhere((el) => el.key == key);
  }

  @override
  List<TodayCharAscensionMaterialsModel> getCharacterAscensionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.talents.where((t) => t.days.isNotEmpty && t.level == 0)
        : _materialsFile.talents.where((t) => t.days.contains(day) && t.level == 0);

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.key);
      final characters = <ItemCommon>[];

      for (final char in _charactersFile.characters) {
        if (char.isComingSoon) {
          continue;
        }
        final normalAscMaterial = char.ascensionMaterials.expand((m) => m.materials).where((m) => m.key == e.key).isNotEmpty ||
            char.talentAscensionMaterials.expand((m) => m.materials).where((m) => m.key == e.key).isNotEmpty;

        //The travelers have different ascension materials, that's why we do the following
        var specialAscMaterial = false;
        if (char.multiTalentAscensionMaterials != null) {
          final keyword = e.key;
          final materials = char.multiTalentAscensionMaterials!
              .expand((m) => m.materials)
              .expand((m) => m.materials)
              .where((m) => m.type == MaterialType.talents)
              .map((e) => e.key)
              .toSet()
              .toList();

          specialAscMaterial = materials.any((m) => m == keyword);
        }

        final materialIsBeingUsed = normalAscMaterial || specialAscMaterial;
        if (materialIsBeingUsed && !characters.any((el) => el.key == char.key)) {
          characters.add(ItemCommon(char.key, Assets.getCharacterPath(char.image)));
        }
      }

      return e.isFromBoss
          ? TodayCharAscensionMaterialsModel.fromBoss(
              key: e.key,
              name: translation.name,
              image: Assets.getMaterialPath(e.image, e.type),
              bossName: translation.bossName,
              characters: characters,
            )
          : TodayCharAscensionMaterialsModel.fromDays(
              key: e.key,
              name: translation.name,
              image: Assets.getMaterialPath(e.image, e.type),
              characters: characters,
              days: e.days,
            );
    }).toList();
  }

  @override
  List<TodayWeaponAscensionMaterialModel> getWeaponAscensionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.weaponPrimary.where((t) => t.level == 0)
        : _materialsFile.weaponPrimary.where((t) => t.days.contains(day) && t.level == 0);

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.key);

      final weapons = <ItemCommon>[];
      for (final weapon in _weaponsFile.weapons) {
        final materialIsBeingUsed = weapon.ascensionMaterials.expand((m) => m.materials).where((m) => m.key == e.key).isNotEmpty;
        if (materialIsBeingUsed) {
          weapons.add(ItemCommon(weapon.key, weapon.fullImagePath));
        }
      }
      return TodayWeaponAscensionMaterialModel(
        key: e.key,
        days: e.days,
        name: translation.name,
        image: Assets.getMaterialPath(e.image, e.type),
        weapons: weapons,
      );
    }).toList();
  }

  @override
  List<ElementCardModel> getElementDebuffs() {
    return _elementsFile.debuffs.map(
      (e) {
        final translation = _translationFile.debuffs.firstWhere((t) => t.key == e.key);
        final reaction = ElementCardModel(name: translation.name, effect: translation.effect, image: e.fullImagePath);
        return reaction;
      },
    ).toList()
      ..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  List<ElementReactionCardModel> getElementReactions() {
    return _elementsFile.reactions.map(
      (e) {
        final translation = _translationFile.reactions.firstWhere((t) => t.key == e.key);
        final reaction = ElementReactionCardModel.withImages(
          name: translation.name,
          effect: translation.effect,
          principal: e.principalImages,
          secondary: e.secondaryImages,
        );
        return reaction;
      },
    ).toList()
      ..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  List<ElementReactionCardModel> getElementResonances() {
    return _elementsFile.resonance.map(
      (e) {
        final translation = _translationFile.resonance.firstWhere((t) => t.key == e.key);
        final reaction = e.hasImages
            ? ElementReactionCardModel.withImages(
                name: translation.name,
                effect: translation.effect,
                principal: e.principalImages,
                secondary: e.secondaryImages,
              )
            : ElementReactionCardModel.withoutImages(
                name: translation.name,
                effect: translation.effect,
                description: translation.description,
              );
        return reaction;
      },
    ).toList();
  }

  @override
  List<MaterialCardModel> getAllMaterialsForCard() {
    return _materialsFile.materials.where((el) => el.isReadyToBeUsed).map((e) => _toMaterialForCard(e)).toList();
  }

  @override
  MaterialFileModel getMaterial(String key) {
    return _materialsFile.materials.firstWhere((m) => m.key == key);
  }

  @override
  MaterialFileModel getMaterialByImage(String image) {
    return _materialsFile.materials.firstWhere((m) => m.fullImagePath == image);
  }

  @override
  List<MaterialFileModel> getMaterials(MaterialType type, {bool onlyReadyToBeUsed = true}) {
    if (onlyReadyToBeUsed) {
      return _materialsFile.materials.where((m) => m.type == type && m.isReadyToBeUsed).toList();
    }
    return _materialsFile.materials.where((m) => m.type == type).toList();
  }

  @override
  MaterialFileModel getMoraMaterial() {
    return _materialsFile.materials.firstWhere((el) => el.type == MaterialType.currency && el.key == 'mora');
  }

  @override
  String getMaterialImg(String key) {
    return _materialsFile.materials.firstWhere((m) => m.key == key).fullImagePath;
  }

  @override
  int getServerDay(AppServerResetTimeType type) {
    return getServerDate(type).weekday;
  }

  @override
  DateTime getServerDate(AppServerResetTimeType type) {
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    DateTime server;
    // According to this page, the server reset happens at 4 am
    // https://game8.co/games/Genshin-Impact/archives/301599
    switch (type) {
      case AppServerResetTimeType.northAmerica:
        server = nowUtc.subtract(const Duration(hours: 5));
        break;
      case AppServerResetTimeType.europe:
        server = nowUtc.add(const Duration(hours: 1));
        break;
      case AppServerResetTimeType.asia:
        server = nowUtc.add(const Duration(hours: 8));
        break;
      default:
        throw Exception('Invalid server reset type');
    }

    if (server.hour >= serverResetHour) {
      return server;
    }

    return server.subtract(const Duration(days: 1));
  }

  @override
  Duration getDurationUntilServerResetDate(AppServerResetTimeType type) {
    final serverDate = getServerDate(type);
    //Here the utc part is important, otherwise the difference will be calculated using the local time
    final serverResetDate = DateTime.utc(serverDate.year, serverDate.month, serverDate.day, serverResetHour);
    final dateToUse = serverDate.isBefore(serverResetDate) ? serverDate : serverDate.subtract(const Duration(days: 1));
    return serverResetDate.difference(dateToUse);
  }

  @override
  List<ItemCommon> getCharacterForItemsUsingMaterial(String key) {
    final material = getMaterial(key);
    final imgs = <ItemCommon>[];

    for (final char in _charactersFile.characters.where((c) => !c.isComingSoon)) {
      final multiTalentAscensionMaterials =
          (char.multiTalentAscensionMaterials?.expand((e) => e.materials).expand((e) => e.materials) ?? <ItemAscensionMaterialFileModel>[]).toList();

      final ascensionMaterial = char.ascensionMaterials.expand((e) => e.materials).toList();
      final talentMaterial = char.talentAscensionMaterials.expand((e) => e.materials).toList();

      final materials = multiTalentAscensionMaterials + ascensionMaterial + talentMaterial;
      final allMaterials = _getMaterialsToUse(materials);

      if (allMaterials.any((m) => m.key == material.key)) {
        imgs.add(ItemCommon(char.key, Assets.getCharacterPath(char.image)));
      }
    }

    return imgs;
  }

  @override
  List<ItemCommon> getWeaponForItemsUsingMaterial(String key) {
    final material = getMaterial(key);
    final items = <ItemCommon>[];

    for (final weapon in _weaponsFile.weapons) {
      final materials = weapon.craftingMaterials + weapon.ascensionMaterials.expand((e) => e.materials).toList();
      final allMaterials = _getMaterialsToUse(materials);
      if (allMaterials.any((m) => m.key == material.key)) {
        items.add(ItemCommon(weapon.key, weapon.fullImagePath));
      }
    }

    return items;
  }

  @override
  MaterialCardModel getMaterialForCard(String key) {
    final material = _materialsFile.materials.firstWhere((m) => m.key == key);
    return _toMaterialForCard(material);
  }

  @override
  CharacterCardModel getCharacterForCard(String key) {
    final character = _charactersFile.characters.firstWhere((el) => el.key == key);
    return _toCharacterForCard(character);
  }

  @override
  WeaponCardModel getWeaponForCard(String key) {
    final weapon = _weaponsFile.weapons.firstWhere((el) => el.key == key);
    return _toWeaponForCard(weapon);
  }

  @override
  List<String> getUpcomingCharactersKeys() => _charactersFile.characters.where((el) => el.isComingSoon).map((e) => e.key).toList();

  @override
  List<String> getUpcomingWeaponsKeys() => _weaponsFile.weapons.where((el) => el.isComingSoon).map((e) => e.key).toList();

  @override
  List<String> getUpcomingKeys() => getUpcomingCharactersKeys() + getUpcomingWeaponsKeys();

  @override
  MonsterFileModel getMonster(String key) {
    return _monstersFile.monsters.firstWhere((el) => el.key == key);
  }

  @override
  List<MonsterCardModel> getAllMonstersForCard() {
    return _monstersFile.monsters.map((e) => _toMonsterForCard(e)).toList();
  }

  @override
  MonsterCardModel getMonsterForCard(String key) {
    final monster = _monstersFile.monsters.firstWhere((el) => el.key == key);
    return _toMonsterForCard(monster);
  }

  @override
  List<MonsterFileModel> getMonsters(MonsterType type) {
    return _monstersFile.monsters.where((el) => el.type == type).toList();
  }

  List<MaterialFileModel> _getMaterialsToUse(
    List<ItemAscensionMaterialFileModel> materials, {
    List<MaterialType> ignore = const [MaterialType.currency],
  }) {
    final mp = <String, MaterialFileModel>{};
    for (final item in materials) {
      final material = getMaterial(item.key);
      if (!ignore.contains(item.type)) {
        mp[item.key] = material;
      }
    }

    return mp.values.toList();
  }

  @override
  List<ItemCommon> getRelatedMonsterToMaterialForItems(String key) {
    final items = <ItemCommon>[];
    for (final monster in _monstersFile.monsters) {
      if (!monster.drops.any((el) => el.type == MonsterDropType.material && el.key == key)) {
        continue;
      }
      items.add(ItemCommon(monster.key, monster.fullImagePath));
    }
    return items;
  }

  @override
  List<ItemCommon> getRelatedMonsterToArtifactForItems(String key) {
    final items = <ItemCommon>[];
    for (final monster in _monstersFile.monsters) {
      if (!monster.drops.any((el) => el.type == MonsterDropType.artifact && key == el.key)) {
        continue;
      }
      items.add(ItemCommon(monster.key, monster.fullImagePath));
    }
    return items;
  }

  @override
  List<MaterialFileModel> getAllMaterialsThatCanBeObtainedFromAnExpedition() {
    return _materialsFile.materials.where((el) => el.canBeObtainedFromAnExpedition).toList();
  }

  @override
  List<MaterialFileModel> getAllMaterialsThatHaveAFarmingRespawnDuration() {
    return _materialsFile.materials.where((el) => el.farmingRespawnDuration != null).toList();
  }

  @override
  String getItemImageFromNotificationType(
    String itemKey,
    AppNotificationType notificationType, {
    AppNotificationItemType? notificationItemType,
  }) {
    switch (notificationType) {
      case AppNotificationType.resin:
      case AppNotificationType.expedition:
      case AppNotificationType.realmCurrency:
        final material = getMaterial(itemKey);
        return material.fullImagePath;
      case AppNotificationType.furniture:
        final furniture = getFurniture(itemKey);
        return furniture.fullImagePath;
      case AppNotificationType.gadget:
        final gadget = getGadget(itemKey);
        return gadget.fullImagePath;
      case AppNotificationType.farmingArtifacts:
        final artifact = getArtifact(itemKey);
        return artifact.fullImagePath;
      case AppNotificationType.farmingMaterials:
        final material = getMaterial(itemKey);
        return material.fullImagePath;
      case AppNotificationType.weeklyBoss:
        final monsters = getMonster(itemKey);
        return monsters.fullImagePath;
      case AppNotificationType.custom:
      case AppNotificationType.dailyCheckIn:
        return getItemImageFromNotificationItemType(itemKey, notificationItemType!);
      default:
        throw Exception('The provided notification type = $notificationType is not valid');
    }
  }

  @override
  String getItemImageFromNotificationItemType(String itemKey, AppNotificationItemType notificationItemType) {
    switch (notificationItemType) {
      case AppNotificationItemType.character:
        final character = getCharacter(itemKey);
        return character.fullImagePath;
      case AppNotificationItemType.weapon:
        final weapon = getWeapon(itemKey);
        return weapon.fullImagePath;
      case AppNotificationItemType.artifact:
        final artifact = getArtifact(itemKey);
        return artifact.fullImagePath;
      case AppNotificationItemType.monster:
        final monster = getMonster(itemKey);
        return monster.fullImagePath;
      case AppNotificationItemType.material:
        final material = getMaterial(itemKey);
        return material.fullImagePath;
      default:
        throw Exception('The provided notification item type = $notificationItemType');
    }
  }

  @override
  List<GadgetFileModel> getAllGadgetsForNotifications() {
    return _gadgetsFile.gadgets.where((el) => el.cooldownDuration != null).toList();
  }

  @override
  GadgetFileModel getGadget(String key) {
    return _gadgetsFile.gadgets.firstWhere((m) => m.key == key);
  }

  @override
  FurnitureFileModel getDefaultFurnitureForNotifications() {
    return _furnitureFile.furniture.first;
  }

  @override
  FurnitureFileModel getFurniture(String key) {
    return _furnitureFile.furniture.firstWhere((m) => m.key == key);
  }

  @override
  DateTime getNextDateForWeeklyBoss(AppServerResetTimeType type) {
    final durationUntilServerReset = getDurationUntilServerResetDate(type);
    var finalDate = DateTime.now().add(durationUntilServerReset);

    while (finalDate.weekday != DateTime.monday) {
      finalDate = finalDate.add(const Duration(days: 1));
    }

    return finalDate;
  }

  @override
  List<CharacterSkillStatModel> getCharacterSkillStats(List<CharacterFileSkillStatModel> skillStats, List<String> statsTranslations) {
    final stats = <CharacterSkillStatModel>[];
    if (skillStats.isEmpty || statsTranslations.isEmpty) {
      return stats;
    }
    final statExp = RegExp('(?<={).+?(?=})');
    final maxLevel = skillStats.first.values.length;
    for (var i = 1; i <= maxLevel; i++) {
      final stat = CharacterSkillStatModel(level: i, descriptions: []);
      for (final translation in statsTranslations) {
        // "Curación continua|{param3}% Max HP + {param4}",
        final splitted = translation.split('|');
        if (splitted.isEmpty || splitted.length != 2) {
          continue;
        }
        final desc = splitted.first;
        var toReplace = splitted[1];
        final matches = statExp.allMatches(toReplace);
        for (final match in matches) {
          final val = match.group(0);
          final statValues = skillStats.firstWhereOrNull((el) => el.key == val);
          if (statValues == null) {
            continue;
          }

          if (statValues.values.length - 1 < i - 1) {
            continue;
          }

          final statValue = statValues.values[i - 1];
          toReplace = toReplace.replaceFirst('{$val}', '$statValue');
        }

        stat.descriptions.add('$desc|$toReplace');
      }

      stats.add(stat);
    }

    return stats;
  }

  @override
  List<ArtifactCardBonusModel> getArtifactBonus(TranslationArtifactFile translation) {
    final bonus = <ArtifactCardBonusModel>[];
    var pieces = translation.bonus.length == 2 ? 2 : 1;
    for (var i = 1; i <= translation.bonus.length; i++) {
      final item = ArtifactCardBonusModel(pieces: pieces, bonus: translation.bonus[i - 1]);
      bonus.add(item);
      pieces += 2;
    }
    return bonus;
  }

  @override
  List<String> getArtifactRelatedParts(String fullImagePath, String image, int bonus) {
    var imageWithoutExt = image.split('.png').first;
    imageWithoutExt = imageWithoutExt.substring(0, imageWithoutExt.length - 1);
    return bonus == 1 ? [fullImagePath] : artifactOrder.map((e) => Assets.getArtifactPath('$imageWithoutExt$e.png')).toList();
  }

  @override
  String getArtifactRelatedPart(String fullImagePath, String image, int bonus, ArtifactType type) {
    if (bonus == 1 && type != ArtifactType.crown) {
      throw Exception('Invalid artifact type');
    }

    if (bonus == 1) {
      return fullImagePath;
    }

    final imgs = getArtifactRelatedParts(fullImagePath, image, bonus);
    final order = getArtifactOrder(type);
    return imgs.firstWhere((el) => el.endsWith('$order.png'));
  }

  @override
  List<StatType> generateSubStatSummary(List<CustomBuildArtifactModel> artifacts) {
    final weightMap = <StatType, int>{};

    for (final artifact in artifacts) {
      int weight = artifact.subStats.length;
      for (var i = 0; i < artifact.subStats.length; i++) {
        final subStat = artifact.subStats[i];
        final ifAbsent = weightMap.containsKey(subStat) ? i : weight;
        weightMap.update(subStat, (value) => value + weight, ifAbsent: () => ifAbsent);
        weight--;
      }
    }

    final sorted = weightMap.entries.sorted((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  @override
  List<double> getBannerHistoryVersions(SortDirectionType type) {
    final versions = _bannerHistoryFile.banners.map((el) => el.version).toSet().toList();
    switch (type) {
      case SortDirectionType.asc:
        return versions..sort((x, y) => x.compareTo(y));
      case SortDirectionType.desc:
        return versions..sort((x, y) => y.compareTo(x));
    }
  }

  @override
  List<BannerHistoryItemModel> getBannerHistory(BannerHistoryItemType type) {
    final banners = <BannerHistoryItemModel>[];
    final itemVersionsMap = <String, List<double>>{};
    final allVersions = getBannerHistoryVersions(SortDirectionType.asc);
    final filteredBanners = _bannerHistoryFile.banners.where((el) => el.type == type).toList();

    for (final banner in filteredBanners) {
      for (final key in banner.itemKeys) {
        final alreadyAdded = banners.any((el) => el.key == key);
        switch (banner.type) {
          case BannerHistoryItemType.character:
            if (!alreadyAdded) {
              final char = getCharacterForCard(key);
              final item = BannerHistoryItemModel(
                versions: [],
                image: char.image,
                name: char.name,
                key: key,
                type: banner.type,
                rarity: char.stars,
              );
              banners.add(item);
            }
            break;
          case BannerHistoryItemType.weapon:
            if (!alreadyAdded) {
              final weapon = getWeaponForCard(key);
              final bannerItem = BannerHistoryItemModel(
                versions: [],
                image: weapon.image,
                name: weapon.name,
                key: key,
                type: banner.type,
                rarity: weapon.rarity,
              );
              banners.add(bannerItem);
            }
            break;
          default:
            throw Exception('The provided banner type = ${banner.type} is not mapped');
        }

        if (!alreadyAdded) {
          itemVersionsMap[key] = [banner.version];
        } else {
          itemVersionsMap.update(key, (value) => [...value, banner.version]);
        }
      }
    }

    for (var i = 0; i < banners.length; i++) {
      final current = banners[i];
      final values = itemVersionsMap.entries.firstWhere((el) => el.key == current.key).value;
      final updated = current.copyWith.call(versions: _getBannerVersionsForItem(allVersions, values));
      banners.removeAt(i);
      banners.insert(i, updated);
    }

    return banners;
  }

  @override
  List<BannerHistoryPeriodModel> getBanners(double version) {
    if (version < getBannerHistoryVersions(SortDirectionType.asc).first) {
      throw Exception('Version = $version is not valid');
    }
    final banners = _bannerHistoryFile.banners
        .where((el) => el.version == version)
        .map(
          (e) => BannerHistoryPeriodModel(
            from: e.from,
            until: e.until,
            type: e.type,
            version: e.version,
            items: e.itemKeys.map((key) {
              String? imagePath;
              int? rarity;
              ItemType? type;
              switch (e.type) {
                case BannerHistoryItemType.character:
                  final character = getCharacter(key);
                  rarity = character.rarity;
                  imagePath = character.fullImagePath;
                  type = ItemType.character;
                  break;
                case BannerHistoryItemType.weapon:
                  final weapon = getWeapon(key);
                  rarity = weapon.rarity;
                  imagePath = weapon.fullImagePath;
                  type = ItemType.weapon;
                  break;
                default:
                  throw Exception('Banner history item type = ${e.type} is not valid');
              }
              return ItemCommonWithRarityAndType(key, imagePath, rarity, type);
            }).toList(),
          ),
        )
        .toList()
      ..sort((x, y) => x.from.compareTo(y.from));

    return banners;
  }

  @override
  List<ItemReleaseHistoryModel> getItemReleaseHistory(String itemKey) {
    final history = _bannerHistoryFile.banners
        .where((el) => el.itemKeys.contains(itemKey))
        .map((e) => ItemReleaseHistoryModel(version: e.version, dates: [ItemReleaseHistoryDatesModel(from: e.from, until: e.until)]))
        .toList();

    if (history.isEmpty) {
      throw Exception('There is no banner history associated to itemKey = $itemKey');
    }
    return history.groupListsBy((el) => el.version).entries.map((e) {
      //with the multi banners, we need to group the dates to avoid showing up repeated ones
      final dates = e.value
          .expand((el) => el.dates)
          .groupListsBy((d) => '${d.from}__${d.until}')
          .values
          .map((e) => ItemReleaseHistoryDatesModel(from: e.first.from, until: e.first.until))
          .toList();
      return ItemReleaseHistoryModel(version: e.key, dates: dates);
    }).toList()
      ..sort((x, y) => x.version.compareTo(y.version));
  }

  @override
  List<ChartTopItemModel> getTopCharts(ChartType type) {
    final fiveStars = [
      ChartType.topFiveStarCharacterMostReruns,
      ChartType.topFiveStarCharacterLeastReruns,
      ChartType.topFiveStarWeaponMostReruns,
      ChartType.topFiveStarWeaponLeastReruns,
    ];
    final stars = fiveStars.contains(type) ? 5 : 4;

    final mostRerunsTypes = [
      ChartType.topFiveStarCharacterMostReruns,
      ChartType.topFourStarCharacterMostReruns,
      ChartType.topFiveStarWeaponMostReruns,
      ChartType.topFourStarWeaponMostReruns,
    ];
    final mostReruns = mostRerunsTypes.contains(type);

    switch (type) {
      case ChartType.topFiveStarCharacterMostReruns:
      case ChartType.topFourStarCharacterMostReruns:
      case ChartType.topFiveStarCharacterLeastReruns:
      case ChartType.topFourStarCharacterLeastReruns:
        final characters = getCharactersForCard().where((el) => el.stars == stars).map((e) => ItemCommonWithName(e.key, e.image, e.name)).toList();
        return _getTopCharts(mostReruns, type, BannerHistoryItemType.character, characters);
      case ChartType.topFiveStarWeaponMostReruns:
      case ChartType.topFourStarWeaponMostReruns:
      case ChartType.topFiveStarWeaponLeastReruns:
      case ChartType.topFourStarWeaponLeastReruns:
        final weapons = getWeaponsForCard().where((el) => el.rarity == stars).map((e) => ItemCommonWithName(e.key, e.image, e.name)).toList();
        return _getTopCharts(mostReruns, type, BannerHistoryItemType.weapon, weapons);
      default:
        throw Exception('Type = $type is not valid in the getTopCharts method');
    }
  }

  @override
  List<ChartBirthdayMonthModel> getCharacterBirthdaysForCharts() {
    final grouped = _charactersFile.characters
        .where((char) => !char.isComingSoon && !char.birthday.isNullEmptyOrWhitespace)
        .groupListsBy((char) => _localeService.getCharBirthDate(char.birthday).month)
        .entries;

    final birthdays = grouped
        .map(
          (e) => ChartBirthdayMonthModel(
            month: e.key,
            items: e.value.map((e) {
              final translation = getCharacterTranslation(e.key);
              return ItemCommonWithName(e.key, e.fullImagePath, translation.name);
            }).toList(),
          ),
        )
        .toList()
      ..sort((x, y) => x.month.compareTo(y.month));

    assert(birthdays.length == 12, 'Birthday items for chart should not be empty and must be equal to 12');

    return birthdays;
  }

  @override
  List<ChartElementItemModel> getElementsForCharts(double fromVersion, double untilVersion) {
    final allVersions = getBannerHistoryVersions(SortDirectionType.asc);
    if (fromVersion < allVersions.first) {
      throw Exception('The fromVersion = $fromVersion is not valid');
    }

    if (untilVersion > allVersions.last) {
      throw Exception('The untilVersion = $untilVersion is not valid');
    }

    if (fromVersion > untilVersion) {
      throw Exception('The fromVersion = $fromVersion cannot be greater than untilVersion = $untilVersion');
    }

    final banners = _bannerHistoryFile.banners
        .where((el) => el.type == BannerHistoryItemType.character && el.version >= fromVersion && el.version <= untilVersion)
        .toList()
      ..sort((x, y) => x.version.compareTo(y.version));
    final charts = <ChartElementItemModel>[];
    final characters = getCharactersForCard();
    final usedChars = <double, List<String>>{};
    const double incrementY = 1;

    for (final banner in banners) {
      for (final key in banner.itemKeys) {
        final bannerHasAlreadyBeenAdded = usedChars.containsKey(banner.version);
        final characterAlreadyAppearedInThisBanner = usedChars.entries.any((el) => el.key == banner.version && el.value.contains(key));
        if (!bannerHasAlreadyBeenAdded) {
          usedChars.putIfAbsent(banner.version, () => [key]);
        } else if (characterAlreadyAppearedInThisBanner) {
          continue;
        } else {
          usedChars.update(banner.version, (value) => [...value, key]);
        }

        final char = characters.firstWhere((el) => el.key == key);
        final existing = charts.firstWhereOrNull((el) => el.type == char.elementType);
        final points = existing?.points ?? [];
        final existingPoint = points.firstWhereOrNull((el) => el.x == banner.version);
        final newPoint = existingPoint != null
            ? Point<double>(existingPoint.x, (existingPoint.y + incrementY).truncateToDecimalPlaces())
            : Point<double>(banner.version, incrementY);

        if (existing == null) {
          final newItem = ChartElementItemModel(type: char.elementType, points: [newPoint]);
          charts.add(newItem);
          continue;
        }

        if (existingPoint != null) {
          final index = points.indexOf(existingPoint);
          points.removeAt(index);
          points.insert(index, newPoint);
        } else {
          points.add(newPoint);
        }
        final updated = existing.copyWith.call(points: points);
        final index = charts.indexOf(existing);
        charts.removeAt(index);
        charts.insert(index, updated);
      }
    }

    double from = fromVersion;
    while (from <= untilVersion) {
      for (final chart in charts) {
        if (!chart.points.any((el) => el.x == from)) {
          chart.points.add(Point<double>(from, 0));
        }
      }
      from = (from + gameVersionIncrementsBy).truncateToDecimalPlaces();
    }

    for (final chart in charts) {
      chart.points.sort((x, y) => x.x.compareTo(y.x));
    }

    assert(charts.isNotEmpty, 'Element chart items must not be empty');

    return charts..sort((x, y) => x.type.index.compareTo(y.type.index));
  }

  @override
  List<ChartAscensionStatModel> getItemAscensionStatsForCharts(ItemType itemType) {
    if (itemType != ItemType.character && itemType != ItemType.weapon) {
      throw Exception('ItemType = $itemType is not Not supported');
    }

    final stats = itemType == ItemType.character ? getCharacterPossibleAscensionStats() : getWeaponPossibleAscensionStats();
    return stats.map(
      (stat) {
        final count = itemType == ItemType.character
            ? _charactersFile.characters.where((el) => !el.isComingSoon && el.subStatType == stat).length
            : _weaponsFile.weapons.where((el) => !el.isComingSoon && el.secondaryStat == stat).length;
        return ChartAscensionStatModel(type: stat, itemType: itemType, quantity: count);
      },
    ).toList()
      ..sort((x, y) => y.quantity.compareTo(x.quantity));
  }

  @override
  List<ChartCharacterRegionModel> getCharacterRegionsForCharts() {
    return RegionType.values.where((el) => el != RegionType.anotherWorld).map((type) {
      final quantity = _charactersFile.characters.where((el) => !el.isComingSoon && el.region == type).length;
      return ChartCharacterRegionModel(regionType: type, quantity: quantity);
    }).toList()
      ..sort((x, y) => y.quantity.compareTo(x.quantity));
  }

  @override
  List<ChartGenderModel> getCharacterGendersForCharts() =>
      RegionType.values.where((el) => el != RegionType.anotherWorld).map((e) => getCharacterGendersByRegionForCharts(e)).toList()
        ..sort((x, y) => y.maxCount.compareTo(x.maxCount));

  @override
  ChartGenderModel getCharacterGendersByRegionForCharts(RegionType regionType) {
    if (regionType == RegionType.anotherWorld) {
      throw Exception('Another world is not supported');
    }

    final characters = _charactersFile.characters.where((el) => !el.isComingSoon && el.region == regionType).toList();
    final maleCount = characters.where((el) => !el.isFemale).length;
    final femaleCount = characters.where((el) => el.isFemale).length;
    return ChartGenderModel(regionType: regionType, maleCount: maleCount, femaleCount: femaleCount, maxCount: max(maleCount, femaleCount));
  }

  @override
  List<ItemCommonWithName> getCharactersForItemsByRegion(RegionType regionType) {
    if (regionType == RegionType.anotherWorld) {
      throw Exception('Another world is not supported');
    }

    return _charactersFile.characters.where((el) => !el.isComingSoon && el.region == regionType).map((e) {
      final char = getCharacterForCard(e.key);
      return ItemCommonWithName(e.key, char.image, char.name);
    }).toList()
      ..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  List<ItemCommonWithName> getCharactersForItemsByRegionAndGender(RegionType regionType, bool onlyFemales) {
    if (regionType == RegionType.anotherWorld) {
      throw Exception('Another world is not supported');
    }

    return _charactersFile.characters.where((el) => !el.isComingSoon && el.region == regionType && el.isFemale == onlyFemales).map((e) {
      final char = getCharacterForCard(e.key);
      return ItemCommonWithName(e.key, char.image, char.name);
    }).toList()
      ..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  List<CharacterBirthdayModel> getCharacterBirthdays({int? month, int? day}) {
    if (month == null && day == null) {
      throw Exception('You must provide a month, day or both');
    }

    if (month != null && (month < DateTime.january || month > DateTime.december)) {
      throw Exception('The provided month = $month is not valid');
    }

    if (day != null && day <= 0) {
      throw Exception('The provided day = $day is not valid');
    }

    if (day != null && month != null) {
      final lastDay = DateUtils.getLastDayOfMonth(month);
      if (day > lastDay) {
        throw Exception('The provided day = $day is not valid for month = $month');
      }
    }

    return _charactersFile.characters.where((char) {
      if (char.isComingSoon) {
        return false;
      }

      if (char.birthday.isNullEmptyOrWhitespace) {
        return false;
      }

      final charBirthday = _localeService.getCharBirthDate(char.birthday);
      if (month != null && day != null) {
        return charBirthday.month == month && charBirthday.day == day;
      }
      if (month != null) {
        return charBirthday.month == month;
      }
      if (day != null) {
        return charBirthday.day == day;
      }

      return true;
    }).map((e) {
      final char = getCharacterForCard(e.key);
      final birthday = _localeService.getCharBirthDate(e.birthday, useCurrentYear: true);
      final now = DateTime.now();
      final nowFromZero = DateTime(now.year, now.month, now.day);
      return CharacterBirthdayModel(
        key: e.key,
        name: char.name,
        image: char.image,
        birthday: birthday,
        birthdayString: e.birthday!,
        daysUntilBirthday: nowFromZero.difference(birthday).inDays.abs(),
      );
    }).toList()
      ..sort((x, y) => x.daysUntilBirthday.compareTo(y.daysUntilBirthday));
  }

  @override
  List<ItemCommonWithName> getItemsAscensionStats(StatType statType, ItemType itemType) {
    final items = <ItemCommonWithName>[];
    switch (itemType) {
      case ItemType.character:
        items.addAll(
          _charactersFile.characters.where((el) => el.subStatType == statType && !el.isComingSoon).map((e) {
            final translation = getCharacterTranslation(e.key);
            return ItemCommonWithName(e.key, e.fullImagePath, translation.name);
          }).toList(),
        );
        break;
      case ItemType.weapon:
        items.addAll(
          _weaponsFile.weapons.where((el) => el.secondaryStat == statType && !el.isComingSoon).map((e) {
            final translation = getWeaponTranslation(e.key);
            return ItemCommonWithName(e.key, e.fullImagePath, translation.name);
          }).toList(),
        );
        break;
      default:
        throw Exception('Invalid itemType = $itemType');
    }
    return items..sort((x, y) => x.name.compareTo(y.name));
  }

  CharacterCardModel _toCharacterForCard(CharacterFileModel character) {
    final translation = getCharacterTranslation(character.key);

    //The reduce is to take the material with the biggest level of each type
    final multiTalentAscensionMaterials = character.multiTalentAscensionMaterials ?? <CharacterFileMultiTalentAscensionMaterialModel>[];

    final ascensionMaterial = character.ascensionMaterials.isNotEmpty
        ? character.ascensionMaterials.reduce((current, next) => current.level > next.level ? current : next)
        : null;

    final talentMaterial = character.talentAscensionMaterials.isNotEmpty
        ? character.talentAscensionMaterials.reduce((current, next) => current.level > next.level ? current : next)
        : multiTalentAscensionMaterials.isNotEmpty
            ? multiTalentAscensionMaterials.expand((e) => e.materials).reduce((current, next) => current.level > next.level ? current : next)
            : null;

    final materials =
        (ascensionMaterial?.materials ?? <ItemAscensionMaterialFileModel>[]) + (talentMaterial?.materials ?? <ItemAscensionMaterialFileModel>[]);

    final quickMaterials = _getMaterialsToUse(materials);

    return CharacterCardModel(
      key: character.key,
      elementType: character.elementType,
      image: Assets.getCharacterPath(character.image),
      materials: quickMaterials.map((m) => m.fullImagePath).toList(),
      name: translation.name,
      stars: character.rarity,
      weaponType: character.weaponType,
      isComingSoon: character.isComingSoon,
      isNew: character.isNew,
      roleType: character.role,
      regionType: character.region,
      subStatType: character.subStatType,
    );
  }

  WeaponCardModel _toWeaponForCard(WeaponFileModel weapon) {
    final translation = getWeaponTranslation(weapon.key);
    return WeaponCardModel(
      key: weapon.key,
      baseAtk: weapon.atk,
      image: weapon.fullImagePath,
      name: translation.name,
      rarity: weapon.rarity,
      type: weapon.type,
      subStatType: weapon.secondaryStat,
      subStatValue: weapon.secondaryStatValue,
      isComingSoon: weapon.isComingSoon,
      locationType: weapon.location,
    );
  }

  ArtifactCardModel _toArtifactForCard(ArtifactFileModel artifact, {ArtifactType? type}) {
    final translation = _translationFile.artifacts.firstWhere((t) => t.key == artifact.key);
    final bonus = getArtifactBonus(translation);
    final mapped = ArtifactCardModel(
      key: artifact.key,
      name: translation.name,
      image: artifact.fullImagePath,
      rarity: artifact.maxRarity,
      bonus: bonus,
    );

    //only search for other images if the artifact has more than 1 bonus effect
    if (type != null && bonus.length > 1) {
      final img = getArtifactRelatedPart(artifact.fullImagePath, artifact.image, bonus.length, type);
      return mapped.copyWith.call(image: img);
    }

    return mapped;
  }

  MaterialCardModel _toMaterialForCard(MaterialFileModel material) {
    final translation = getMaterialTranslation(material.key);
    return MaterialCardModel.item(
      key: material.key,
      image: material.fullImagePath,
      rarity: material.rarity,
      position: material.position,
      type: material.type,
      name: translation.name,
      level: material.level,
      hasSiblings: material.hasSiblings,
    );
  }

  MonsterCardModel _toMonsterForCard(MonsterFileModel monster) {
    final translation = getMonsterTranslation(monster.key);
    return MonsterCardModel(
      key: monster.key,
      image: monster.fullImagePath,
      name: translation.name,
      type: monster.type,
      isComingSoon: monster.isComingSoon,
    );
  }

  List<BannerHistoryItemVersionModel> _getBannerVersionsForItem(List<double> allVersions, List<double> releasedOn) {
    final history = <BannerHistoryItemVersionModel>[];
    int number = 0;
    for (var i = 0; i < allVersions.length; i++) {
      final current = allVersions[i];
      final released = releasedOn.contains(current);
      final notReleasedYet = releasedOn.every((e) => current < e);
      if (notReleasedYet) {
        history.add(BannerHistoryItemVersionModel(version: current, number: 0, released: false));
      } else if (!released) {
        number++;
        history.add(BannerHistoryItemVersionModel(version: current, number: number, released: false));
      } else {
        history.add(BannerHistoryItemVersionModel(version: current, released: true));
        number = 0;
      }
    }
    return history;
  }

  List<ChartTopItemModel> _getTopCharts(bool mostReruns, ChartType type, BannerHistoryItemType bannerType, List<ItemCommonWithName> items) {
    final selected = _bannerHistoryFile.banners
        .where((el) => el.type == bannerType)
        .expand((el) => el.itemKeys)
        .groupListsBy((el) => el)
        .entries
        .map((g) {
          final element = items.firstWhereOrNull((el) => el.key == g.key);
          if (element == null) {
            return null;
          }
          return ItemCommonWithQuantity(g.key, element.image, g.value.length);
        })
        .where((el) => el != null)
        .map((e) => e!)
        .toList();

    if (mostReruns) {
      selected.sort((x, y) => y.quantity.compareTo(x.quantity));
    } else {
      selected.sort((x, y) => x.quantity.compareTo(y.quantity));
    }

    assert(selected.isNotEmpty, 'The selected item list should not be empty');
    assert(selected.length >= 5, 'There should be at least 5 top items');

    final tops = selected.take(5).toList();
    final total = tops.map((e) => e.quantity).sum;

    return tops
        .map(
          (e) => ChartTopItemModel(
            key: e.key,
            name: items.firstWhere((el) => el.key == e.key).name,
            type: type,
            value: e.quantity,
            percentage: (e.quantity * 100 / total).truncateToDecimalPlaces(fractionalDigits: 2),
          ),
        )
        .toList();
  }
}
