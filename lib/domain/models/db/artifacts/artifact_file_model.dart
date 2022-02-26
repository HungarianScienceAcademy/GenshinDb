import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../assets.dart';

part 'artifact_file_model.freezed.dart';
part 'artifact_file_model.g.dart';

@freezed
class ArtifactFileModel with _$ArtifactFileModel {
  String get fullImagePath => Assets.getArtifactPath(image);

  factory ArtifactFileModel({
    required String key,
    required String image,
    required int minRarity,
    required int maxRarity,
  }) = _ArtifactFileModel;

  ArtifactFileModel._();

  factory ArtifactFileModel.fromJson(Map<String, dynamic> json) => _$ArtifactFileModelFromJson(json);
}
