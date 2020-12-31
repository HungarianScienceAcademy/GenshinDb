import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/app_constants.dart';
import '../../common/assets.dart';
import '../../services/genshing_service.dart';
import '../../telemetry.dart';

part 'artifact_details_bloc.freezed.dart';
part 'artifact_details_event.dart';
part 'artifact_details_state.dart';

class ArtifactDetailsBloc extends Bloc<ArtifactDetailsEvent, ArtifactDetailsState> {
  final GenshinService _genshinService;

  ArtifactDetailsBloc(this._genshinService) : super(const ArtifactDetailsState.loading());

  @override
  Stream<ArtifactDetailsState> mapEventToState(
    ArtifactDetailsEvent event,
  ) async* {
    yield const ArtifactDetailsState.loading();

    final s = await event.map(
      loadArtifact: (e) async {
        await trackArtifactLoaded(e.name);
        final artifact = _genshinService.getArtifact(e.name);
        final translation = _genshinService.getArtifactTranslation(e.name);
        var image = artifact.image.split('.png').first;
        image = image.substring(0, image.length - 1);

        return ArtifactDetailsState.loaded(
          name: artifact.name,
          image: artifact.fullImagePath,
          rarityMin: artifact.rarityMin,
          rarityMax: artifact.rarityMax,
          bonus: translation.bonus,
          images: translation.bonus.length == 1
              ? [artifact.fullImagePath]
              : artifactOrder.map((e) => Assets.getArtifactPath('$image$e.png')).toList(),
        );
      },
    );

    yield s;
  }
}
