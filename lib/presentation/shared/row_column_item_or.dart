import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/styles.dart';

class RowColumnItemOr extends StatelessWidget {
  final Widget widget;
  final Color color;
  final bool useColumn;

  const RowColumnItemOr({
    Key? key,
    required this.widget,
    required this.color,
    this.useColumn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useColumn) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [widget, _OrWidget(color: color)],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [widget, _OrWidget(color: color)],
    );
  }
}

class _OrWidget extends StatelessWidget {
  final Color color;

  const _OrWidget({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll5,
      padding: Styles.edgeInsetAll5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          s.or,
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
