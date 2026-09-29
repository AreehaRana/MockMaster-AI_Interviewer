import 'package:flutter/material.dart';
import 'package:mockmaster/features/chatbot/models/chat_message_model.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

/// One message bubble, styled for either the user or the AI assistant.
/// Colors come from Theme.of(context) / MColors via the color scheme --
/// nothing hardcoded -- so it matches both the light and dark themes.
class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    final bubbleColor = isUser
        ? scheme.primary
        : (dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerHighest);
    final textColor = isUser ? scheme.onPrimary : Theme.of(context).textTheme.bodyMedium?.color;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: MSizes.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: MSizes.md,
          vertical: MSizes.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(MSizes.cardRadiusMd),
            topRight: const Radius.circular(MSizes.cardRadiusMd),
            bottomLeft: Radius.circular(isUser ? MSizes.cardRadiusMd : MSizes.xs),
            bottomRight: Radius.circular(isUser ? MSizes.xs : MSizes.cardRadiusMd),
          ),
        ),
        child: SelectableText(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}
