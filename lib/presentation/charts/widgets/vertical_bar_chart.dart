import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';

typedef OnBarChartTap = void Function(int, int);
typedef GetText = String Function(double);
typedef GetBarChartRodData = List<BarChartRodData> Function(int);

class VerticalBarDataModel {
  final int index;
  final Color color;
  final int x;
  final double y;

  VerticalBarDataModel(this.index, this.color, this.x, this.y);
}

const _textStyle = TextStyle(
  color: Colors.grey,
  fontWeight: FontWeight.bold,
  fontSize: 12,
);

class VerticalBarChart extends StatelessWidget {
  final List<VerticalBarDataModel> items;
  final OnBarChartTap? onBarChartTap;
  final GetText getBottomText;
  final GetText getLeftText;
  final GetBarChartRodData? getBarChartRodData;

  final double maxY;
  final double interval;

  final Color? tooltipColor;

  final int bottomTextMaxLength;
  final int leftTextMaxLength;

  final bool rotateBottomText;

  const VerticalBarChart({
    Key? key,
    required this.items,
    required this.getLeftText,
    required this.getBottomText,
    this.onBarChartTap,
    this.getBarChartRodData,
    required this.maxY,
    required this.interval,
    this.tooltipColor,
    this.bottomTextMaxLength = 10,
    this.leftTextMaxLength = 10,
    this.rotateBottomText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            tooltipBgColor: tooltipColor ?? theme.backgroundColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              rod.toY.toInt().toString(),
              const TextStyle(color: Colors.white),
            ),
          ),
          touchCallback: (FlTouchEvent event, response) {
            if (event is FlTapUpEvent && response?.spot?.touchedBarGroupIndex != null) {
              onBarChartTap?.call(response!.spot!.touchedBarGroupIndex, response.spot!.touchedRodDataIndex);
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => _BottomTitles(
                getBottomText: getBottomText,
                bottomTextMaxLength: bottomTextMaxLength,
                value: value,
                rotateBottomText: rotateBottomText,
              ),
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) => _LeftTitle(getLeftText: getLeftText, leftTextMaxLength: leftTextMaxLength, value: value),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: items
            .map(
              (e) => BarChartGroupData(
                x: e.x,
                barRods: getBarChartRodData?.call(e.x) ??
                    [
                      BarChartRodData(
                        toY: e.y,
                        color: e.color,
                        borderRadius: BorderRadius.zero,
                        width: 10,
                      ),
                    ],
              ),
            )
            .toList(),
        gridData: FlGridData(show: false),
      ),
    );
  }
}

class _BottomTitles extends StatelessWidget {
  final GetText getBottomText;
  final double value;
  final int bottomTextMaxLength;
  final bool rotateBottomText;

  const _BottomTitles({
    Key? key,
    required this.getBottomText,
    required this.value,
    required this.bottomTextMaxLength,
    required this.rotateBottomText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = getBottomText(value);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: !rotateBottomText
          ? Tooltip(
              message: text,
              child: Text(
                text.substringIfOverflow(bottomTextMaxLength),
                textAlign: TextAlign.center,
                style: _textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : RotationTransition(
              turns: const AlwaysStoppedAnimation(15 / 360),
              child: Tooltip(
                message: text,
                child: Text(
                  text.substringIfOverflow(bottomTextMaxLength),
                  textAlign: TextAlign.center,
                  style: _textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
    );
  }
}

class _LeftTitle extends StatelessWidget {
  final GetText getLeftText;
  final double value;
  final int leftTextMaxLength;

  const _LeftTitle({
    Key? key,
    required this.getLeftText,
    required this.value,
    required this.leftTextMaxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = getLeftText(value);
    return Tooltip(
      message: text,
      child: Text(
        text.substringIfOverflow(leftTextMaxLength),
        textAlign: TextAlign.center,
        style: _textStyle,
      ),
    );
  }
}
