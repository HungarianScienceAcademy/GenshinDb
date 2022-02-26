import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'custom_build_team_character_model.freezed.dart';

@freezed
class CustomBuildTeamCharacterModel with _$CustomBuildTeamCharacterModel {
  const factory CustomBuildTeamCharacterModel({
    required String key,
    required int index,
    required String name,
    required String image,
    required CharacterRoleType roleType,
    required CharacterRoleSubType subType,
  }) = _CustomBuildTeamCharacterModel;
}
