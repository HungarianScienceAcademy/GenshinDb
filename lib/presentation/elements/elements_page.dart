import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/styles.dart';

import 'widgets/sliver_element_debuffs.dart';
import 'widgets/sliver_element_reactions.dart';
import 'widgets/sliver_element_resonances.dart';

class ElementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.elements)),
      body: SafeArea(
        child: BlocProvider<ElementsBloc>(
          create: (ctx) => Injection.elementsBloc..add(const ElementsEvent.init()),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Styles.edgeInsetAll10,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      Text(
                        s.elementalDebuffs,
                        style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(s.elementalDebuffsExplained)
                    ],
                  ),
                ),
              ),
              SliverElementDebuffs(),
              SliverPadding(
                padding: Styles.edgeInsetAll10,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      s.elementalReactions,
                      style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(s.elementalReactionsExplained),
                  ]),
                ),
              ),
              SliverElementReactions(),
              SliverPadding(
                padding: Styles.edgeInsetAll10,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      s.elementalResonances,
                      style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(s.elementalResonancesExplained),
                  ]),
                ),
              ),
              SliverElementResonances(),
            ],
          ),
        ),
      ),
    );
  }
}
