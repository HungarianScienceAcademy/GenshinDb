import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'widgets/monster_card.dart';

class MonstersPage extends StatelessWidget {
  final bool isInSelectionMode;
  final List<String> excludeKeys;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final route = MaterialPageRoute<String>(
      builder: (ctx) => MonstersPage(isInSelectionMode: true, excludeKeys: excludeKeys),
    );
    final keyName = await Navigator.of(context).push(route);
    await route.completed;
    return keyName;
  }

  const MonstersPage({
    Key? key,
    this.isInSelectionMode = false,
    this.excludeKeys = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final s = S.of(context);
    return BlocProvider(
      create: (context) => Injection.monstersBloc..add(MonstersEvent.init(excludeKeys: excludeKeys)),
      child: BlocBuilder<MonstersBloc, MonstersState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => SliverScaffoldWithFab(
            appbar: AppBar(title: Text(isInSelectionMode ? s.selectAMonster : s.monsters)),
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.monsters,
                onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.monsters),
                searchChanged: (v) => context.read<MonstersBloc>().add(MonstersEvent.searchChanged(search: v)),
              ),
              if (state.monsters.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  sliver: SliverWaterfallFlow(
                    gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, isOnMainPage: !isInSelectionMode),
                      crossAxisSpacing: isPortrait ? 10 : 5,
                      mainAxisSpacing: 5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MonsterCard.item(item: state.monsters[index], isInSelectionMode: isInSelectionMode),
                      childCount: state.monsters.length,
                    ),
                  ),
                )
              else
                const SliverNothingFound(),
            ],
          ),
        ),
      ),
    );
  }
}
