import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'banner_history_item_bloc.freezed.dart';
part 'banner_history_item_event.dart';
part 'banner_history_item_state.dart';

class BannerHistoryItemBloc extends Bloc<BannerHistoryItemEvent, BannerHistoryItemState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  static const periodDateFormat = 'yyyy/MM/dd';

  BannerHistoryItemBloc(this._genshinService, this._telemetryService) : super(const BannerHistoryItemState.loading());

  @override
  Stream<BannerHistoryItemState> mapEventToState(BannerHistoryItemEvent event) async* {
    final s = await event.map(
      init: (e) => _init(e.version),
    );

    yield s;
  }

  Future<BannerHistoryItemState> _init(double version) async {
    await _telemetryService.trackBannerHistoryItemOpened(version);
    final banners = _genshinService.getBanners(version);
    final grouped = banners
        .groupListsBy(
          (el) => '${DateFormat(periodDateFormat).format(el.from)}_${DateFormat(periodDateFormat).format(el.until)}',
        )
        .values
        .map(
      (e) {
        final group = e.first;
        final items = e.expand((el) => el.items).toList();
        final finalItems = <ItemCommonWithRarityAndType>[];
        //this is to avoid duplicate items (e.g: on double banners like 2.4)
        for (final item in items) {
          if (finalItems.any((el) => el.key == item.key)) {
            continue;
          }
          finalItems.add(item);
        }

        return BannerHistoryGroupedPeriodModel(
          from: DateFormat(periodDateFormat).format(group.from),
          until: DateFormat(periodDateFormat).format(group.until),
          items: finalItems,
        );
      },
    ).toList();
    return BannerHistoryItemState.loadedState(version: version, items: grouped);
  }
}
