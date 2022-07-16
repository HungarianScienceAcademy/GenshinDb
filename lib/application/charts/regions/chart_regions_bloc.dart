import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'chart_regions_bloc.freezed.dart';
part 'chart_regions_event.dart';
part 'chart_regions_state.dart';

class ChartRegionsBloc extends Bloc<ChartRegionsEvent, ChartRegionsState> {
  final GenshinService _genshinService;

  ChartRegionsBloc(this._genshinService) : super(const ChartRegionsState.loading());

  @override
  Stream<ChartRegionsState> mapEventToState(ChartRegionsEvent event) async* {
    final s = event.map(
      init: (_) => _init(),
    );

    yield s;
  }

  ChartRegionsState _init() {
    final items = _genshinService.getCharacterRegionsForCharts();
    final maxCount = items.map((e) => e.quantity).reduce(max);
    return ChartRegionsState.loaded(maxCount: maxCount, items: items);
  }
}
