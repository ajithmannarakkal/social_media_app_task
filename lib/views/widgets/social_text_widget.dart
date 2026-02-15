import 'package:flutter/material.dart';

class SocialTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const SocialTextWidget(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> children = [];
    final regex = RegExp(r"([@#]\w+)");

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final matchText = match[0]!;
        final isMention = matchText.startsWith('@');
        final isHashtag = matchText.startsWith('#');

        children.add(TextSpan(
          text: matchText,
          style: (style ?? const TextStyle()).copyWith(
            color: isMention ? Colors.blue : (isHashtag ? Colors.blue : null),
            fontWeight: FontWeight.bold,
          ),
        ));
        return matchText;
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return text;
      },
    );

    return RichText(
      textAlign: textAlign,
      text: TextSpan(style: style, children: children),
    );
  }
}
