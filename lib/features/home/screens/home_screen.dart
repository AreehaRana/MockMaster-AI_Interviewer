import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockmaster/common/widgets/app_drawer.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/data/services/admin_firestore_services.dart';
import 'package:mockmaster/features/authentication/screens/admin/widgets/admin_entry_point.dart';
import 'package:mockmaster/features/chatbot/screens/chatbot_screen.dart';
import 'package:mockmaster/features/home/models/interview_category_model.dart';
import 'package:mockmaster/features/home/models/question_model.dart';
import 'package:mockmaster/features/home/screens/widgets/hero_banner.dart';
import 'package:mockmaster/features/home/screens/widgets/interview_category_card.dart';
import 'package:mockmaster/features/home/screens/widgets/section_heading.dart';
import 'package:mockmaster/features/personalization/controllers/user_controller.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDrawerOpen = false;

  void _setDrawerOpen(bool isOpen) {
    if (_isDrawerOpen == isOpen) return;
    setState(() => _isDrawerOpen = isOpen);
  }

  /// Merges the static Dashboard category metadata with live Firestore
  /// questions. A category keeps its hardcoded fallback list until the
  /// admin has imported/added at least one question for it in Firestore
  /// -- after that, Firestore becomes the source of truth, so deletes in
  /// ManageQuestionsScreen are reflected here immediately.
  List<InterviewCategoryModel> _mergeWithFirestore(
    List<Question> firestoreQuestions,
  ) {
    final byCategory = <String, List<String>>{};
    for (final q in firestoreQuestions) {
      byCategory.putIfAbsent(q.category, () => []).add(q.text);
    }

    return InterviewCategoryModel.categories().map((cat) {
      final liveQuestions = byCategory[cat.categoryKey];
      if (liveQuestions != null && liveQuestions.isNotEmpty) {
        return cat.copyWithQuestions(liveQuestions);
      }
      return cat; // not migrated yet for this category -- keep static bank
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(UserController());
    final dark = MHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: Colors.transparent,

      // Side menu: profile, interview count, admin entry, logout
      drawer: const MAppDrawer(),
      onDrawerChanged: _setDrawerOpen,

      // Scrim stays fully transparent — we draw our own blur+dim below,
      // so the default flat-black overlay doesn't double up on it.
      drawerScrimColor: Colors.transparent,

      // App bar: logo + "MockMaster" side by side, plus admin icon and hamburger
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              dark ? MImages.darkAppLogo : MImages.lightAppLogo,
              height: 32,
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: MSizes.sm),
            const Text('MockMaster'),
          ],
        ),
        actions: const [
          AdminEntryPointIcon(),
        ],
      ),

      body: MGradientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero banner
                    const MHeroBanner(),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    // Interview categories
                    const MSectionHeading(
                      title: MTexts.interviewCategoriesTitle,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems),

                    // Live-merges Firestore questions into the static
                    // category cards -- so admin edits/deletes show up
                    // here without needing an app restart.
                    StreamBuilder<List<Question>>(
                      stream: AdminFirestoreService.instance.watchQuestions(),
                      builder: (context, snapshot) {
                        final categories = _mergeWithFirestore(
                          snapshot.data ?? const [],
                        );

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width > 900
                                ? 3
                                : width > 560
                                    ? 2
                                    : 1;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: MSizes.gridViewSpacing,
                                mainAxisSpacing: MSizes.gridViewSpacing,
                                mainAxisExtent: 340,
                              ),
                              itemBuilder: (context, index) {
                                return MInterviewCategoryCard(
                                  category: categories[index],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    // Extra bottom padding so content isn't hidden behind the chat bubble
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Blur + dim overlay for the home screen content while the
            // drawer is open. IgnorePointer so it doesn't block the drawer's
            // own tap-to-close gesture, which Scaffold already handles.
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isDrawerOpen ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: (dark ? Colors.black : Colors.black87)
                        .withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating AI chat bubble — bottom-right, opens the chatbot screen.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _MGlassFab(
        onPressed: () => ChatbotScreen.show(context),
      ),
    );
  }
}

/// Frosted-glass floating action button, styled to match [MGlassPanel] /
/// [MGlassChip] (blurred backdrop + translucent fill + hairline border)
/// instead of Flutter's default solid FAB.
class _MGlassFab extends StatelessWidget {
  const _MGlassFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Chat with MockMaster AI',
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? MColors.glassShadowDark
                  : MColors.glassShadowLight,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: isDark ? MColors.glassFillDark : MColors.glassFillLight,
              shape: CircleBorder(
                side: BorderSide(
                  color: isDark
                      ? MColors.glassBorderDark
                      : MColors.glassBorderLight,
                  width: 1.2,
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.auto_awesome,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}