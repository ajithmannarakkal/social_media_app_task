import 'package:flutter/material.dart';

class SocialTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = value.text;
    final List<TextSpan> children = [];

    // Use regex to find mentions (@username) and hashtags (#hashtag)
    // This simple regex looks for @ or # followed by word characters
    final regex = RegExp(r"([@#]\w+)");
    
    // Split the text by the regex matches, keeping the delimiters
    // Wait, split alone doesn't keep delimiters easily in Dart unless we capture groups...
    // Let's iterate manually or use splitMapJoin if available, or just iterate matches.
    
    // A better approach for styling:
    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final matchText = match[0]!;
        final isMention = matchText.startsWith('@');
        final isHashtag = matchText.startsWith('#');
        
        children.add(TextSpan(
          text: matchText,
          style: style?.copyWith(
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

    return TextSpan(style: style, children: children);
  }
}
