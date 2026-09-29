import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mockmaster/features/chatbot/controllers/chat_controller.dart';
import 'package:mockmaster/features/chatbot/screens/widgets/chat_bubble.dart';
import 'package:mockmaster/features/chatbot/screens/widgets/suggestion_chip.dart';
import 'package:mockmaster/features/chatbot/screens/widgets/typing_indicator.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_Strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

/// The MockMaster AI Assistant chatbot screen.
///
/// No longer a full page route -- call [ChatbotScreen.show] instead of
/// Navigator.push. That opens this as a small floating window (like a
/// website live-chat widget) docked bottom-right on wide screens or
/// bottom-center on phones, instead of covering the whole screen.
class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  /// Opens the chatbot as a small floating window over whatever screen
  /// is currently showing, instead of a full-page route.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MockMaster AI Assistant',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;
        // Phones get a wide bottom-docked panel; tablets/desktop get a
        // fixed-size window anchored to the bottom-right corner, like a
        // typical website chat widget.
        final isNarrow = size.width < 600;
        final width = isNarrow ? size.width * 0.94 : 380.0;
        final height = isNarrow ? size.height * 0.75 : 600.0;

        return Align(
          alignment: isNarrow ? Alignment.bottomCenter : Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: isNarrow ? 0 : 24,
              bottom: isNarrow ? 0 : 24,
              left: isNarrow ? 0 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: isNarrow
                    ? const BorderRadius.vertical(top: Radius.circular(24))
                    : BorderRadius.circular(24),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: const ChatbotScreen(),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    ).whenComplete(() {
      // Force onClose() to run now (history-clear lives there) -- a plain
      // Get.put() isn't auto-disposed just because the dialog closed.
      if (Get.isRegistered<ChatController>()) {
        Get.delete<ChatController>(force: true);
      }
    });
  }

  static const List<_Suggestion> _suggestions = [
    _Suggestion(Icons.event_available_rounded, MTexts.suggestionPrepareInterview,
        "I have an interview coming up. How should I prepare?"),
    _Suggestion(Icons.checklist_rounded, MTexts.suggestionChooseInterview,
        "Which MockMaster interview should I take?"),
    _Suggestion(Icons.forum_rounded, MTexts.suggestionPracticeQuestions,
        "Practice With Me"),
    _Suggestion(Icons.insights_rounded, MTexts.suggestionAnalyzePerformance,
        "Analyze my interview performance."),
    _Suggestion(Icons.description_rounded, MTexts.suggestionResumeHelp,
        "What should I include in my CV/resume?"),
    _Suggestion(Icons.help_outline_rounded, MTexts.suggestionHowItWorks,
        "What is the difference between Pre-generated and Custom Interview?"),
  ];

  @override
  Widget build(BuildContext context) {
    // Never reuse a controller instance left over from a previous window.
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>(force: true);
    }
    final controller = Get.put(ChatController());
    final dark = MHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(MTexts.chatbotAppbarTitle),
            Text(
              MTexts.chatbotAppbarSubtitle,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        // Explicit close button -- this is a floating window now, not a
        // pushed page, so there's no default back arrow to dismiss it.
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final messages = controller.messages;
                final showSuggestions = messages.length <= 1;
                final itemCount =
                    messages.length + (controller.isSending.value ? 1 : 0);

                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(MSizes.defaultSpace),
                  itemCount: itemCount + (showSuggestions ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Suggestions render right after the welcome message.
                    if (showSuggestions && index == itemCount) {
                      return _SuggestionsGrid(
                        suggestions: _suggestions,
                        onTap: (prompt) => controller.sendSuggestion(prompt),
                      );
                    }
                    if (index >= messages.length) {
                      return const TypingIndicator();
                    }
                    return ChatBubble(message: messages[index]);
                  },
                );
              }),
            ),
            _ChatInputBar(dark: dark),
          ],
        ),
      ),
    );
  }
}

class _Suggestion {
  final IconData icon;
  final String label;
  final String prompt;
  const _Suggestion(this.icon, this.label, this.prompt);
}

class _SuggestionsGrid extends StatelessWidget {
  final List<_Suggestion> suggestions;
  final ValueChanged<String> onTap;

  const _SuggestionsGrid({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MSizes.sm),
      child: Wrap(
        spacing: MSizes.sm,
        runSpacing: MSizes.sm,
        children: suggestions
            .map((s) => MSuggestionChip(
                  icon: s.icon,
                  label: s.label,
                  onTap: () => onTap(s.prompt),
                ))
            .toList(),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final bool dark;
  const _ChatInputBar({required this.dark});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController.instance;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: MSizes.md,
        right: MSizes.md,
        top: MSizes.sm,
        // Keeps the input bar above the on-screen keyboard.
        bottom: MediaQuery.of(context).viewInsets.bottom + MSizes.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendCurrentInput(),
                decoration: InputDecoration(
                  hintText: MTexts.chatbotInputHint,
                  filled: true,
                  fillColor: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MSizes.cardRadiusLg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: MSizes.md,
                    vertical: MSizes.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(width: MSizes.sm),
            Obx(
              () => Material(
                color: scheme.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap:
                      controller.isSending.value ? null : controller.sendCurrentInput,
                  child: Padding(
                    padding: const EdgeInsets.all(MSizes.sm + 2),
                    child: controller.isSending.value
                        ? SizedBox(
                            width: MSizes.iconSm,
                            height: MSizes.iconSm,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : Icon(Icons.send_rounded, color: scheme.onPrimary, size: MSizes.iconMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}