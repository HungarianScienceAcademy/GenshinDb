import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/calculator_ascension_materials_page.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

import 'add_edit_session_dialog.dart';

class SessionListItem extends StatelessWidget {
  final CalculatorSessionModel session;

  const SessionListItem({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final numberOfChars = session.items.where((e) => e.isCharacter).length;
    final numberOfWeapons = session.items.where((e) => !e.isCharacter).length;
    final extentRatio = SizeUtils.getExtentRatioForSlidablePane(context);
    return Slidable(
      key: ValueKey(session.key),
      startActionPane: ActionPane(
        extentRatio: extentRatio,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            label: s.delete,
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (_) => _showDeleteSessionDialog(session.key, session.name, context),
          ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: extentRatio,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            label: s.edit,
            backgroundColor: Colors.lightBlueAccent,
            icon: Icons.edit,
            onPressed: (_) => _showEditSessionDialog(session.key, session.name, context),
          ),
        ],
      ),
      child: ListTile(
        onLongPress: () => _showEditSessionDialog(session.key, session.name, context),
        title: Text(session.name),
        onTap: () => _gotoCalculatorAscensionMaterialsPage(context),
        subtitle: Text('${s.charactersX(numberOfChars)} / ${s.weaponsX(numberOfWeapons)}'),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.list),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Future<void> _showEditSessionDialog(int sessionKey, String name, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CalculatorAscMaterialsSessionsBloc>(),
        child: AddEditSessionDialog.update(sessionKey: sessionKey, name: name),
      ),
    );
  }

  Future<void> _showDeleteSessionDialog(int sessionKey, String name, BuildContext context) async {
    final s = S.of(context);
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.deleteSession),
        content: Text(s.confirmDeleteSessionX(name)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CalculatorAscMaterialsSessionsBloc>().add(CalculatorAscMaterialsSessionsEvent.deleteSession(key: sessionKey));
              Navigator.pop(context);
            },
            child: Text(s.ok),
          )
        ],
      ),
    );
  }

  Future<void> _gotoCalculatorAscensionMaterialsPage(BuildContext context) async {
    final route = MaterialPageRoute(
      builder: (c) => BlocProvider.value(
        value: context.read<CalculatorAscMaterialsSessionsBloc>(),
        child: CalculatorAscensionMaterialsPage(sessionKey: session.key),
      ),
    );
    await Navigator.push(context, route);
    await route.completed;
  }
}
