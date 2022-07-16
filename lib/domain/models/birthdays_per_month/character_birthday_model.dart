import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_birthday_model.freezed.dart';

@freezed
class CharacterBirthdayModel with _$CharacterBirthdayModel {
  const factory CharacterBirthdayModel({
    required String key,
    required String name,
    required String image,
    required DateTime birthday,
    required String birthdayString,
    required int daysUntilBirthday,
  }) = _CharacterBirthdayModel;
}
