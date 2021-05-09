import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';

class NotificationDropdownType extends StatelessWidget {
  final AppNotificationType selectedValue;
  final bool isInEditMode;
  final bool isExpanded;

  const NotificationDropdownType({
    Key key,
    @required this.selectedValue,
    @required this.isInEditMode,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DropdownButton<AppNotificationType>(
      isExpanded: isExpanded,
      hint: Text(s.notificationType),
      value: selectedValue,
      onChanged: isInEditMode ? null : (v) => context.read<NotificationBloc>().add(NotificationEvent.typeChanged(newValue: v)),
      items: AppNotificationType.values
          .map((type) => DropdownMenuItem<AppNotificationType>(value: type, child: Text(s.translateAppNotificationType(type))))
          .toList(),
    );
  }
}
