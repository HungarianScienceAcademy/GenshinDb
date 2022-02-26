import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/hawk_fab_menu.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';

import 'widgets/add_edit_item_bottom_sheet.dart';
import 'widgets/ascension_materials_summary.dart';
import 'widgets/item_card.dart';
import 'widgets/reorder_items_dialog.dart';

class CalculatorAscensionMaterialsPage extends StatelessWidget {
  final int sessionKey;

  const CalculatorAscensionMaterialsPage({
    Key? key,
    required this.sessionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => Injection.getCalculatorAscMaterialsBloc(ctx.read<CalculatorAscMaterialsSessionsBloc>())
        ..add(CalculatorAscMaterialsEvent.init(sessionKey: sessionKey)),
      child: Scaffold(
        appBar: _AppBar(sessionKey: sessionKey),
        body: SafeArea(
          child: _FabMenu(sessionKey: sessionKey),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final int sessionKey;

  const _AppBar({Key? key, required this.sessionKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
      builder: (ctx, state) => AppBar(
        title: Text(s.ascensionMaterials),
        actions: [
          if (state.items.length > 1)
            IconButton(
              icon: const Icon(Icons.unfold_more),
              splashRadius: Styles.mediumButtonSplashRadius,
              onPressed: () => _showReorderDialog(state.items, context),
            ),
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              splashRadius: Styles.mediumButtonSplashRadius,
              onPressed: () => _showDeleteAllDialog(context),
            )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _showReorderDialog(List<ItemAscensionMaterials> items, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CalculatorAscMaterialsBloc>(),
        child: ReorderItemsDialog(sessionKey: sessionKey, items: items),
      ),
    );
  }

  Future<void> _showDeleteAllDialog(BuildContext context) async {
    final s = S.of(context);
    await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: s.deleteAllItems,
        content: s.confirmQuestion,
        onOk: () => context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.clearAllItems(sessionKey)),
      ),
    );
  }
}

class _FabMenu extends StatelessWidget {
  final int sessionKey;

  const _FabMenu({Key? key, required this.sessionKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final size = getDeviceType(MediaQuery.of(context).size);
    return HawkFabMenu(
      icon: AnimatedIcons.menu_arrow,
      fabColor: theme.colorScheme.secondary,
      items: [
        HawkFabMenuItem(
          label: s.addCharacter,
          ontap: () => _openCharacterPage(context),
          icon: const Icon(Icons.people),
          color: theme.colorScheme.secondary,
          labelColor: theme.colorScheme.secondary,
        ),
        HawkFabMenuItem(
          label: s.addWeapon,
          ontap: () => _openWeaponPage(context),
          icon: const Icon(Shiori.crossed_swords),
          color: theme.colorScheme.secondary,
          labelColor: theme.colorScheme.secondary,
        ),
      ],
      body: BlocBuilder<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
        builder: (context, state) => state.map(
          initial: (state) {
            if (state.items.isEmpty) {
              return NothingFoundColumn(msg: s.startByAddingMsg, icon: Icons.add_circle_outline);
            }
            final summary = _buildSummary(s, state.summary);
            switch (size) {
              case DeviceScreenType.mobile:
              case DeviceScreenType.tablet:
              case DeviceScreenType.desktop:
                if (isPortrait) {
                  return _PortraitLayout(sessionKey: sessionKey, items: state.items, summary: summary);
                }
                return _LandscapeLayout(sessionKey: sessionKey, items: state.items, summary: summary);
              default:
                return _PortraitLayout(sessionKey: sessionKey, items: state.items, summary: summary);
            }
          },
        ),
      ),
    );
  }

  List<AscensionMaterialsSummaryWidget> _buildSummary(S s, List<AscensionMaterialsSummary> items) {
    items.sort((x, y) => s.translateAscensionSummaryType(x.type).compareTo(s.translateAscensionSummaryType(y.type)));

    return items.map((e) => AscensionMaterialsSummaryWidget(summary: e, sessionKey: sessionKey)).toList();
  }

  Future<void> _openCharacterPage(BuildContext context) async {
    final charactersBloc = context.read<CharactersBloc>();
    charactersBloc.add(CharactersEvent.init(excludeKeys: context.read<CalculatorAscMaterialsBloc>().getItemsKeysToExclude()));

    final route = MaterialPageRoute<String>(builder: (ctx) => const CharactersPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    charactersBloc.add(const CharactersEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.load(key: keyName!, isCharacter: true));

    await ModalBottomSheetUtils.showAppModalBottomSheet(
      context,
      EndDrawerItemType.calculatorAscMaterialsAdd,
      args: AddEditItemBottomSheet.buildNavigationArgsToAddItem(sessionKey, keyName),
    );
  }

  Future<void> _openWeaponPage(BuildContext context) async {
    final weaponsBloc = context.read<WeaponsBloc>();
    weaponsBloc.add(WeaponsEvent.init(excludeKeys: context.read<CalculatorAscMaterialsBloc>().getItemsKeysToExclude()));

    final route = MaterialPageRoute<String>(builder: (ctx) => const WeaponsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    weaponsBloc.add(const WeaponsEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.load(key: keyName!, isCharacter: false));

    await ModalBottomSheetUtils.showAppModalBottomSheet(
      context,
      EndDrawerItemType.calculatorAscMaterialsAdd,
      args: AddEditItemBottomSheet.buildNavigationArgsToAddItem(sessionKey, keyName, isAWeapon: true),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final int sessionKey;
  final List<ItemAscensionMaterials> items;
  final List<Widget> summary;

  const _PortraitLayout({
    Key? key,
    required this.sessionKey,
    required this.items,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 10),
          sliver: SliverToBoxAdapter(
            child: ItemDescriptionDetail(
              title: '${s.characters} / ${s.weapons}',
              textColor: theme.colorScheme.secondary,
            ),
          ),
        ),
        SliverPadding(
          padding: Styles.edgeInsetHorizontal16,
          sliver: SliverToBoxAdapter(
            child: ResponsiveGridRow(
              children: items
                  .mapIndex(
                    (e, index) => ResponsiveGridCol(
                      xs: 6,
                      sm: 4,
                      md: 4,
                      lg: 3,
                      xl: 2,
                      child: ItemCard(
                        sessionKey: sessionKey,
                        isActive: e.isActive,
                        index: index,
                        itemKey: e.key,
                        image: e.image,
                        name: e.name,
                        rarity: e.rarity,
                        isWeapon: !e.isCharacter,
                        materials: e.materials,
                        elementType: e.elementType,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (summary.isNotEmpty)
          SliverToBoxAdapter(
            child: ItemDescriptionDetail(
              title: s.summary,
              textColor: theme.colorScheme.secondary,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: summary,
              ),
            ),
          ),
      ],
    );
  }
}

class _LandscapeLayout extends StatefulWidget {
  final int sessionKey;
  final List<ItemAscensionMaterials> items;
  final List<Widget> summary;

  const _LandscapeLayout({
    Key? key,
    required this.sessionKey,
    required this.items,
    required this.summary,
  }) : super(key: key);

  @override
  State<_LandscapeLayout> createState() => _LandscapeLayoutState();
}

class _LandscapeLayoutState extends State<_LandscapeLayout> {
  late final ScrollController _controllerRight;
  late final ScrollController _controllerLeft;

  @override
  void initState() {
    super.initState();
    _controllerRight = ScrollController();
    _controllerLeft = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Flexible(
          flex: 60,
          fit: FlexFit.tight,
          child: CustomScrollView(
            controller: _controllerLeft,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 10),
                sliver: SliverToBoxAdapter(
                  child: ItemDescriptionDetail(
                    title: '${s.characters} / ${s.weapons}',
                    textColor: theme.colorScheme.secondary,
                  ),
                ),
              ),
              SliverPadding(
                padding: Styles.edgeInsetHorizontal16,
                sliver: SliverToBoxAdapter(
                  child: ResponsiveGridRow(
                    children: widget.items
                        .mapIndex(
                          (e, index) => ResponsiveGridCol(
                            sm: 6,
                            md: 4,
                            lg: 3,
                            xl: 3,
                            child: ItemCard(
                              sessionKey: widget.sessionKey,
                              isActive: e.isActive,
                              index: index,
                              itemKey: e.key,
                              image: e.image,
                              name: e.name,
                              rarity: e.rarity,
                              isWeapon: !e.isCharacter,
                              materials: e.materials,
                              elementType: e.elementType,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 40,
          fit: FlexFit.tight,
          child: CustomScrollView(
            controller: _controllerRight,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 10),
                sliver: SliverToBoxAdapter(
                  child: ItemDescriptionDetail(
                    title: s.summary,
                    textColor: theme.colorScheme.secondary,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.summary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
