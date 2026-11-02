import 'package:flutter/material.dart';

// Memastikan teks panjang dipotong pada batas kata bila melebihi, lalu diikuti " ..."
class WordEllipsisText extends StatelessWidget {
  const WordEllipsisText(
    this.text, {
    super.key,
    required this.style,
    this.maxLines = 1,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign? textAlign;

  static const String ellipsis = ' ...';

  static String truncate(
    String text,
    TextStyle style,
    double maxWidth,
    TextScaler textScaler, {
    int maxLines = 1,
  }) {
    bool fits(String value) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      final bool exceeded = painter.didExceedMaxLines;
      painter.dispose();
      return !exceeded;
    }

    final String trimmed = text.trim();
    if (fits(trimmed)) return text;

    final List<String> words = trimmed.split(RegExp(r'\s+'));
    int lo = 1;
    int hi = words.length - 1;
    int best = 0;
    while (lo <= hi) {
      final int mid = (lo + hi) ~/ 2;
      final String candidate = '${words.sublist(0, mid).join(' ')}$ellipsis';
      if (fits(candidate)) {
        best = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    if (best == 0) return text;
    return '${words.sublist(0, best).join(' ')}$ellipsis';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextStyle effective =
            DefaultTextStyle.of(context).style.merge(style);
        final String display = truncate(
          text,
          effective,
          constraints.maxWidth,
          MediaQuery.textScalerOf(context),
          maxLines: maxLines,
        );
        return Text(
          display,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: style,
        );
      },
    );
  }
}