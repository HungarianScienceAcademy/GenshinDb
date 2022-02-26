import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

//TODO: ADD TEST FOR FAIL CASES (E.G WEAPON NOT FOUND, IMAGE NOT FOUND ETC)

void main() {
  final languages = AppLanguageType.values.toList();
  TestWidgetsFlutterBinding.ensureInitialized();

  LocaleService _getLocaleService(AppLanguageType language) {
    final settings = MockSettingsService();
    when(settings.language).thenReturn(language);
    final service = LocaleServiceImpl(settings);

    manuallyInitLocale(service, language);
    return service;
  }

  GenshinService _getService() {
    final localeService = _getLocaleService(AppLanguageType.english);
    final service = GenshinServiceImpl(localeService);
    return service;
  }

  test('Initialize all languages', () async {
    final service = _getService();

    for (final lang in languages) {
      await expectLater(service.init(lang), completes);
    }
  });

  group('Card items', () {
    test('check for characters', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final characters = service.getCharactersForCard();
        checkKeys(characters.map((e) => e.key).toList());
        final materialImgs = service.getAllMaterialsForCard().map((e) => e.image).toList();
        for (final char in characters) {
          checkKey(char.key);
          expect(char.name, allOf([isNotEmpty, isNotNull]));
          checkAsset(char.image);
          expect(char.stars, allOf([greaterThanOrEqualTo(4), lessThanOrEqualTo(5)]));
          if (char.isNew || char.isComingSoon) {
            expect(char.isNew, isNot(char.isComingSoon));
          }

          if (!char.isComingSoon) {
            expect(char.materials, isNotEmpty);
            final expected = materialImgs.where((el) => char.materials.contains(el)).length;
            expect(char.materials.length, equals(expected));
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final weapons = service.getWeaponsForCard();
        checkKeys(weapons.map((e) => e.key).toList());
        for (final weapon in weapons) {
          checkKey(weapon.key);
          checkAsset(weapon.image);
          expect(weapon.name, allOf([isNotEmpty, isNotNull]));
          expect(weapon.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]));
          expect(weapon.baseAtk, greaterThan(0));
          expect(weapon.subStatValue, greaterThanOrEqualTo(0));
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final artifacts = service.getArtifactsForCard();
        checkKeys(artifacts.map((e) => e.key).toList());
        for (final artifact in artifacts) {
          checkKey(artifact.key);
          checkAsset(artifact.image);
          expect(artifact.name, allOf([isNotEmpty, isNotNull]));
          expect(artifact.rarity, allOf([greaterThanOrEqualTo(3), lessThanOrEqualTo(5)]));
          expect(artifact.bonus, isNotEmpty);
          for (final bonus in artifact.bonus) {
            expect(bonus.bonus, allOf([isNotEmpty, isNotNull]));
            if (artifact.bonus.length == 2) {
              expect(bonus.pieces, isIn([2, 4]));
            } else {
              expect(bonus.pieces == 1, isTrue);
            }
          }
        }
      }
    });

    test('check for materials', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final materials = service.getAllMaterialsForCard();
        checkKeys(materials.map((e) => e.key).toList());
        for (final material in materials) {
          checkKey(material.key);
          checkAsset(material.image);
          expect(material.name, allOf([isNotEmpty, isNotNull]));
          expect(material.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]));
          expect(material.level, greaterThanOrEqualTo(0));
        }
      }
    });

    test('check for monsters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final monsters = service.getAllMonstersForCard();
        checkKeys(monsters.map((e) => e.key).toList());
        for (final monster in monsters) {
          checkKey(monster.key);
          checkAsset(monster.image);
          expect(monster.name, allOf([isNotEmpty, isNotNull]));
        }
      }
    });
  });

  group('Details', () {
    test('check for characters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final localeService = _getLocaleService(AppLanguageType.english);
      final characters = service.getCharactersForCard();
      for (final character in characters) {
        final travelerKeys = ['traveler-geo', 'traveler-electro', 'traveler-anemo', 'traveler-hydro', 'traveler-pyro', 'traveler-cryo'];
        final detail = service.getCharacter(character.key);
        final isTraveler = travelerKeys.contains(character.key);
        checkKey(detail.key);
        expect(detail.rarity, character.stars);
        expect(detail.weaponType, character.weaponType);
        expect(detail.elementType, character.elementType);
        checkAsset(detail.fullImagePath);
        checkAsset(detail.fullCharacterImagePath);
        expect(detail.region, character.regionType);
        expect(detail.role, character.roleType);
        expect(detail.isComingSoon, character.isComingSoon);
        expect(detail.isNew, character.isNew);
        expect(detail.tier, isIn(['d', 'c', 'b', 'a', 's', 'ss', 'sss']));
        if (isTraveler) {
          checkAsset(detail.fullSecondImagePath!);
        } else {
          expect(detail.birthday, allOf([isNotNull, isNotEmpty]));

          //eg: 09/14
          expect(detail.birthday!.length, equals(5));

          expect(() => localeService.getCharBirthDate(detail.birthday), returnsNormally);
        }

        if (!detail.isComingSoon && !isTraveler) {
          expect(detail.ascensionMaterials, isNotEmpty);
          expect(detail.talentAscensionMaterials, isNotEmpty);
        } else if (!detail.isComingSoon && isTraveler) {
          expect(detail.multiTalentAscensionMaterials, allOf([isNotEmpty, isNotNull]));
        }

        if (!detail.isComingSoon) {
          expect(detail.builds, isNotEmpty);
          expect(detail.builds.any((el) => el.isRecommended), isTrue);
          for (final build in detail.builds) {
            expect(build.skillPriorities.length, inInclusiveRange(1, 3));
            expect(build.skillPriorities, isNotEmpty);
            for (final priority in build.skillPriorities) {
              expect(priority, isIn([CharacterSkillType.normalAttack, CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill]));
            }
          }

          expect(detail.skills, isNotEmpty);
          expect(detail.skills.length, inInclusiveRange(3, 4));
          expect(detail.passives, isNotEmpty);
          expect(detail.passives.length, inInclusiveRange(2, 4));
          expect(detail.constellations, isNotEmpty);
          expect(detail.constellations.length, 6);
          expect(detail.stats, isNotEmpty);
        }

        checkCharacterFileAscensionMaterialModel(service, detail.ascensionMaterials);
        if (!isTraveler) {
          checkCharacterFileTalentAscensionMaterialModel(service, detail.talentAscensionMaterials);
        } else {
          for (final ascMaterial in detail.multiTalentAscensionMaterials!) {
            expect(ascMaterial.number, inInclusiveRange(1, 3));
            checkCharacterFileTalentAscensionMaterialModel(service, ascMaterial.materials);
          }
        }

        for (final build in detail.builds) {
          expect(build.weaponKeys, isNotEmpty);
          expect(build.subStatsToFocus.length, greaterThanOrEqualTo(3));
          for (final key in build.weaponKeys) {
            final weapon = service.getWeapon(key);
            expect(weapon.type == detail.weaponType, isTrue);
          }

          for (final artifact in build.artifacts) {
            final valid = artifact.oneKey != null || artifact.multiples.isNotEmpty;
            expect(valid, isTrue);
            expect(artifact.stats.length, equals(5));
            expect(artifact.stats[0], equals(StatType.hp));
            expect(artifact.stats[1], equals(StatType.atk));
            if (artifact.oneKey != null) {
              expect(() => service.getArtifact(artifact.oneKey!), returnsNormally);
            } else {
              for (final partial in artifact.multiples) {
                expect(() => service.getArtifact(partial.key), returnsNormally);
                expect(partial.quantity, inInclusiveRange(1, 2));
              }
            }
          }
        }

        for (final skill in detail.skills) {
          checkKey(skill.key);
          if (!detail.isComingSoon) {
            checkAsset(skill.fullImagePath);
            expect(skill.stats, isNotEmpty);
            for (final stat in skill.stats) {
              switch (skill.type) {
                case CharacterSkillType.normalAttack:
                case CharacterSkillType.elementalSkill:
                case CharacterSkillType.elementalBurst:
                  expect(stat.values.length, 15);
                  break;
                case CharacterSkillType.others:
                  break;
                default:
                  throw Exception('Skill is not mapped');
              }
            }
            final statKeys = skill.stats.map((e) => e.key).toList();
            expect(statKeys.toSet().length, equals(statKeys.length));
            //check that all the values in the stats have the same length
            final statCount = skill.stats.map((e) => e.values.length).toSet().length;
            expect(statCount, equals(1));
          }

          for (final stat in skill.stats) {
            expect(stat.values, isNotEmpty);
          }
        }

        for (final passive in detail.passives) {
          checkKey(passive.key);
          if (!detail.isComingSoon) {
            checkAsset(passive.fullImagePath);
          }

          expect(passive.unlockedAt, isIn([-1, 1, 4]));
        }

        for (final constellation in detail.constellations) {
          checkKey(constellation.key);
          if (!detail.isComingSoon) {
            checkAsset(constellation.fullImagePath);
          }
          expect(constellation.number, inInclusiveRange(1, 6));
        }

        expect(detail.stats.where((e) => e.isAnAscension).length == 6, isTrue);
        var repetitionCount = 0;
        for (var i = 0; i < detail.stats.length; i++) {
          final stat = detail.stats[i];
          expect(stat.level, inInclusiveRange(1, 90));
          expect(stat.baseAtk, greaterThan(0));
          expect(stat.baseHp, greaterThan(0));
          expect(stat.baseDef, greaterThan(0));
          expect(stat.statValue, greaterThanOrEqualTo(0));
          if (i > 0 && i < detail.stats.length - 1) {
            final nextStat = detail.stats[i + 1];
            if (nextStat.statValue == stat.statValue) {
              repetitionCount++;
            } else {
              repetitionCount = 0;
            }
            expect(repetitionCount, lessThanOrEqualTo(4));
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final weapons = service.getWeaponsForCard();
      for (final weapon in weapons) {
        final detail = service.getWeapon(weapon.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);
        expect(detail.type, equals(weapon.type));
        expect(detail.atk, equals(weapon.baseAtk));
        expect(detail.rarity, equals(weapon.rarity));
        expect(detail.secondaryStat, equals(weapon.subStatType));
        expect(detail.secondaryStatValue, equals(weapon.subStatValue));
        expect(detail.location, equals(weapon.locationType));
        expect(detail.ascensionMaterials, isNotEmpty);
        expect(detail.stats, isNotEmpty);

        if (detail.location == ItemLocationType.crafting) {
          expect(detail.craftingMaterials, isNotEmpty);
        } else {
          expect(detail.craftingMaterials, isEmpty);
        }

        for (final ascMaterial in detail.ascensionMaterials) {
          expect(ascMaterial.level, inInclusiveRange(20, 80));
          checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
        }

        final ascensionNumber = detail.stats.where((el) => el.isAnAscension).length;
        switch (detail.rarity) {
          case 1:
          case 2:
            expect(ascensionNumber == 4, isTrue);
            break;
          default:
            expect(ascensionNumber == 6, isTrue);
            break;
        }
        var repetitionCount = 0;
        for (var i = 0; i < detail.stats.length; i++) {
          final stat = detail.stats[i];
          if (detail.rarity >= 3) {
            expect(stat.level, inInclusiveRange(1, 90));
          } else {
            expect(stat.level, inInclusiveRange(1, 70));
          }

          expect(stat.baseAtk, greaterThan(0));
          if (detail.rarity > 2) {
            expect(stat.statValue, greaterThan(0));
          } else {
            expect(stat.statValue, greaterThanOrEqualTo(0));
          }
          if (i > 0 && i < detail.stats.length - 1 && weapon.rarity > 2) {
            final nextStat = detail.stats[i + 1];
            if (nextStat.statValue == stat.statValue) {
              repetitionCount++;
            } else {
              repetitionCount = 0;
            }

            if (stat.level <= 40 && !stat.isAnAscension) {
              expect(repetitionCount, lessThanOrEqualTo(4));
            } else {
              expect(repetitionCount, lessThanOrEqualTo(2));
            }
          }
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final artifacts = service.getArtifactsForCard();
      for (final artifact in artifacts) {
        final detail = service.getArtifact(artifact.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);
        expect(detail.minRarity, inInclusiveRange(2, 4));
        expect(detail.maxRarity, inInclusiveRange(3, 5));
      }
    });

    test('check the materials', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final materials = service.getAllMaterialsForCard();
      for (final material in materials) {
        final detail = service.getMaterial(material.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);
        expect(detail.rarity, equals(material.rarity));
        expect(detail.type, equals(material.type));

        switch (detail.type) {
          case MaterialType.common:
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(1, 4));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.elementalStone:
            expect(detail.rarity, equals(4));
            expect(detail.level, equals(0));
            break;
          case MaterialType.jewels:
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(2, 5));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.local:
            expect(detail.attributes, allOf([isNotNull, isNotEmpty]));
            break;
          case MaterialType.talents:
            if (detail.rarity >= 5) {
              continue;
            }

            expect(detail.days, isNotEmpty);
            for (final day in detail.days) {
              expect(day, isIn([1, 2, 3, 4, 5, 6, 7]));
            }

            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(2, 4));
            expect(detail.level, inInclusiveRange(0, 2));
            break;
          case MaterialType.weapon:
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(1, 4));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.weaponPrimary:
            expect(detail.days, isNotEmpty);
            for (final day in detail.days) {
              expect(day, isIn([1, 2, 3, 4, 5, 6, 7]));
            }
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(2, 5));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.currency:
            break;
          case MaterialType.others:
            break;
          case MaterialType.ingredient:
            break;
          case MaterialType.expWeapon:
          case MaterialType.expCharacter:
            expect(detail.attributes, allOf([isNotNull, isNotEmpty]));
            expect(detail.experienceAttributes, isNotNull);
            expect(detail.isAnExperienceMaterial, isTrue);
            break;
        }

        final partOfRecipes = detail.recipes + detail.obtainedFrom;

        for (final part in partOfRecipes) {
          checkKey(part.createsMaterialKey);
          expect(() => service.getMaterial(part.createsMaterialKey), returnsNormally);
          for (final needs in part.needs) {
            expect(needs.quantity, greaterThanOrEqualTo(1));
            expect(() => service.getMaterial(needs.key), returnsNormally);
          }
        }

        final characters = service.getCharacterForItemsUsingMaterial(material.key);
        expect(characters.map((e) => e.key).toSet().length == characters.length, isTrue);

        final weapons = service.getWeaponForItemsUsingMaterial(material.key);
        expect(weapons.map((e) => e.key).toSet().length == weapons.length, isTrue);

        final droppedBy = service.getRelatedMonsterToMaterialForItems(detail.key);
        expect(droppedBy.map((e) => e.key).toSet().length == droppedBy.length, isTrue);
      }
    });

    test('check the monsters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final monsters = service.getAllMonstersForCard();
      for (final monster in monsters) {
        final detail = service.getMonster(monster.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);

        for (final drop in detail.drops) {
          switch (drop.type) {
            case MonsterDropType.material:
              expect(() => service.getMaterial(drop.key), returnsNormally);
              break;
            case MonsterDropType.artifact:
              expect(() => service.getArtifact(drop.key), returnsNormally);
              break;
          }
        }
      }
    });
  });

  group('Translations', () {
    test('check for characters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);

        final characters = service.getCharactersForCard();

        for (final character in characters) {
          final detail = service.getCharacter(character.key);
          final translation = service.getCharacterTranslation(character.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          if (!detail.isComingSoon) {
            checkTranslation(translation.description, canBeNull: false);
          }

          expect(translation.skills, isNotEmpty);
          expect(translation.skills.length, equals(detail.skills.length));
          expect(translation.passives, isNotEmpty);
          expect(translation.passives.length, equals(detail.passives.length));
          expect(translation.constellations, isNotEmpty);
          expect(translation.constellations.length, equals(detail.constellations.length));

          checkKeys(translation.skills.map((e) => e.key).toList());
          checkKeys(translation.passives.map((e) => e.key).toList());
          checkKeys(translation.constellations.map((e) => e.key).toList());

          for (var i = 0; i < translation.skills.length; i++) {
            final skill = translation.skills[i];
            checkKey(skill.key);
            expect(skill.key, isIn(detail.skills.map((e) => e.key).toList()));
            checkTranslation(skill.title, canBeNull: false);
            if (detail.isComingSoon) {
              continue;
            }
            expect(skill.stats, isNotEmpty);
            for (final ability in skill.abilities) {
              final oneAtLeast = ability.name.isNotNullEmptyOrWhitespace ||
                  ability.description.isNotNullEmptyOrWhitespace ||
                  ability.secondDescription.isNotNullEmptyOrWhitespace;

              if (!oneAtLeast) {
                expect(ability.descriptions, isNotEmpty);
                for (final desc in ability.descriptions) {
                  checkTranslation(desc, canBeNull: false);
                }
              }
            }

            final stats = service.getCharacterSkillStats(detail.skills[i].stats, skill.stats);
            expect(stats, isNotEmpty);
            switch (detail.skills[i].type) {
              case CharacterSkillType.normalAttack:
              case CharacterSkillType.elementalSkill:
              case CharacterSkillType.elementalBurst:
                expect(stats.length, 15);
                break;
              case CharacterSkillType.others:
                break;
              default:
                throw Exception('Skill is not mapped');
            }
            final hasPendingParam = stats.expand((el) => el.descriptions).any((el) => el.contains('param'));
            expect(hasPendingParam, equals(false));
          }

          for (final passive in translation.passives) {
            checkKey(passive.key);
            expect(passive.key, isIn(detail.passives.map((e) => e.key).toList()));
            if (detail.isComingSoon) {
              continue;
            }
            checkTranslation(passive.title, canBeNull: false);
            checkTranslation(passive.description, canBeNull: passive.descriptions.isNotEmpty);
            for (final desc in passive.descriptions) {
              checkTranslation(desc, canBeNull: false);
            }
          }

          for (final constellation in translation.constellations) {
            checkKey(constellation.key);
            expect(constellation.key, isIn(detail.constellations.map((e) => e.key).toList()));
            if (detail.isComingSoon) {
              continue;
            }
            checkTranslation(constellation.title, canBeNull: false);
            checkTranslation(constellation.description, canBeNull: false);
            checkTranslation(constellation.secondDescription);
            for (final desc in constellation.descriptions) {
              checkTranslation(desc, canBeNull: false);
            }
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final weapons = service.getWeaponsForCard();
        for (final weapon in weapons) {
          final detail = service.getWeapon(weapon.key);
          final translation = service.getWeaponTranslation(weapon.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          checkTranslation(translation.description, canBeNull: false);
          if (detail.rarity > 2) {
            expect(translation.refinements, isNotEmpty);
          } else {
            expect(translation.refinements, isEmpty);
          }

          for (final refinement in translation.refinements) {
            checkTranslation(refinement, canBeNull: false, checkForColor: false);
          }
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final artifacts = service.getArtifactsForCard();
        for (final artifact in artifacts) {
          final detail = service.getArtifact(artifact.key);
          final translation = service.getArtifactTranslation(detail.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          expect(translation.bonus.length, inInclusiveRange(1, 2));
          for (final bonus in translation.bonus) {
            checkTranslation(bonus, canBeNull: false);
          }
        }
      }
    });

    test('check the materials', () async {
      final service = _getService();
      final toCheck = [AppLanguageType.english, AppLanguageType.spanish, AppLanguageType.simplifiedChinese];
      for (final lang in toCheck) {
        await service.init(lang);
        final materials = service.getAllMaterialsForCard();
        for (final material in materials) {
          final detail = service.getMaterial(material.key);
          final translation = service.getMaterialTranslation(detail.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          checkTranslation(translation.description, canBeNull: false);
        }
      }
    });

    test('check the monsters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final monsters = service.getAllMonstersForCard();
        for (final monster in monsters) {
          final translation = service.getMonsterTranslation(monster.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
        }
      }
    });
  });

  group('Birthdays', () {
    test("check Keqing's birthday", () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final date = DateTime(2021, 11, 20);
      final chars = service.getCharactersForBirthday(date);
      expect(chars, isNotEmpty);
      expect(chars.first.key, equals('keqing'));
    });

    test("check Bennet's birthday", () {
      for (final lang in languages.where((el) => el != AppLanguageType.french)) {
        final service = _getLocaleService(lang);
        final birthday = service.getCharBirthDate('02/29');
        expect(birthday.day, equals(29));
        expect(birthday.month, equals(2));
      }
    });

    test('upcoming characters are not shown', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final localeService = _getLocaleService(AppLanguageType.english);
      final upcoming = service.getUpcomingCharactersKeys();
      for (final key in upcoming) {
        final char = service.getCharacter(key);
        final date = localeService.getCharBirthDate(char.birthday);
        final chars = service.getCharactersForBirthday(date);
        expect(chars.any((el) => el.key == key), false);
      }
    });
  });

  group('Elements', () {
    test('check debuffs', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final debuffs = service.getElementDebuffs();
        expect(debuffs.length, equals(4));
        for (final debuff in debuffs) {
          expect(debuff.name, allOf([isNotNull, isNotEmpty]));
          expect(debuff.effect, allOf([isNotNull, isNotEmpty]));
          checkAsset(debuff.image);
        }
      }
    });

    test('check resonances', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final reactions = service.getElementReactions();
        expect(reactions.length, equals(11));
        for (final reaction in reactions) {
          expect(reaction.name, allOf([isNotNull, isNotEmpty]));
          expect(reaction.effect, allOf([isNotNull, isNotEmpty]));
          expect(reaction.principal, isNotEmpty);
          expect(reaction.secondary, isNotEmpty);

          final imgs = reaction.principal + reaction.secondary;
          for (final img in imgs) {
            checkAsset(img);
          }
        }
      }
    });

    test('check resonances', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final resonances = service.getElementResonances();
        expect(resonances.length, equals(7));
        for (final resonance in resonances) {
          expect(resonance.name, allOf([isNotNull, isNotEmpty]));
          expect(resonance.effect, allOf([isNotNull, isNotEmpty]));

          final imgs = resonance.principal + resonance.secondary;
          for (final img in imgs) {
            checkAsset(img);
          }
        }
      }
    });
  });

  group('TierList', () {
    test('check the default one', () async {
      final List<int> defaultColors = [
        0xfff44336,
        0xfff56c62,
        0xffff7d06,
        0xffff9800,
        0xffffc107,
        0xffffeb3b,
        0xff8bc34a,
      ];

      final service = _getService();
      await service.init(AppLanguageType.english);
      final defaultTierList = service.getDefaultCharacterTierList(defaultColors);
      expect(defaultTierList.length, equals(7));

      final charCountInTierList = defaultTierList.expand((el) => el.items).length;
      final charCount = service.getCharactersForCard().where((el) => !el.isComingSoon).length;
      expect(charCountInTierList == charCount, isTrue);

      for (var i = 0; i < defaultColors.length; i++) {
        final tierRow = defaultTierList[i];
        expect(tierRow.tierText, allOf([isNotNull, isNotEmpty]));
        expect(tierRow.items, isNotEmpty);
        expect(tierRow.tierColor, equals(defaultColors[i]));

        for (final item in tierRow.items) {
          checkKey(item.key);
          checkAsset(item.image);
        }
      }
    });
  });

  group("Today's materials", () {
    test('check for characters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final days = [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ];

      for (final day in days) {
        final materials = service.getCharacterAscensionMaterials(day);
        expect(materials, isNotEmpty);
        for (final material in materials) {
          checkKey(material.key);
          checkAsset(material.image);
          expect(material.name, allOf([isNotNull, isNotEmpty]));
          expect(material.characters, isNotEmpty);
          expect(material.days, isNotEmpty);
          for (final item in material.characters) {
            checkItemCommon(item);
          }
        }

        if (day == DateTime.sunday) {
          final allCharacters = service.getCharactersForCard();
          final notComingSoon = allCharacters.where((el) => !el.isComingSoon).length;
          final got = materials.expand((el) => el.characters).map((e) => e.key).toSet().length;
          expect(notComingSoon, equals(got));
        }
      }
    });
  });
}
