import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

//TODO: MOVE THIS TO AN UTIL ?
final _regExp = RegExp(r'({color}).*?({\/color})', caseSensitive: false);

class HighlightedText extends StatelessWidget {
  final String text;
  final TextStyle highlightedStyle;
  final TextAlign textAlign;
  final EdgeInsets padding;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.highlightedStyle,
    this.textAlign = TextAlign.center,
    this.padding = Styles.edgeInsetAll10,
  }) : super(key: key);

  HighlightedText.color({
    Key? key,
    required this.text,
    required Color color,
    this.textAlign = TextAlign.center,
    this.padding = Styles.edgeInsetAll10,
  })  : highlightedStyle = TextStyle(color: color, fontWeight: FontWeight.bold),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    final matches = _regExp.allMatches(text);
    var currentIndex = 0;
    for (final match in matches) {
      final value = match.group(0);
      if (value.isNullEmptyOrWhitespace) {
        continue;
      }
      final x = text.indexOf(value!, currentIndex);

      final part = text.substring(currentIndex, x);
      spans.add(TextSpan(text: part));

      final highlighted = text.substring(currentIndex + part.length, currentIndex + part.length + value.length);
      spans.add(TextSpan(text: replaceColorTags(highlighted), style: highlightedStyle));

      currentIndex += part.length + highlighted.length;
    }

    if (text.length > currentIndex) {
      final remaining = text.substring(currentIndex);
      spans.add(TextSpan(text: remaining));
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Tooltip(
          message: replaceColorTags(text),
          child: RichText(
            textAlign: textAlign,
            text: TextSpan(children: spans, style: theme.textTheme.bodyText2),
          ),
        ),
      ),
    );
  }

  String replaceColorTags(String from) {
    return from.replaceAll('{color}', '').replaceAll('{/color}', '');
  }
}
