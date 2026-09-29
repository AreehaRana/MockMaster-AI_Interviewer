import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';

/// Data model for one "Take Interview" card on the Dashboard.
///
/// [questions] is what actually gets used when the user taps "Take
/// Interview" -- it starts out equal to the static, hardcoded bank
/// (from `MTexts`) so nothing breaks before migration, but HomeScreen
/// overrides it live with Firestore data (via [copyWithQuestions]) once
/// the admin has imported/added questions for this category. That way
/// admin deletes in ManageQuestionsScreen actually take effect here.
///
/// [categoryKey] is the string stored in Firestore's `Category` field
/// (and in legacy_question_bank.dart's map keys) -- it does NOT include
/// the word "Interview" the way [title] does, so HomeScreen uses it to
/// match this card to its Firestore questions.
class InterviewCategoryModel {
  final String title;
  final String description;
  final String badge;
  final bool isTechnical;
  final IconData icon;
  final List<String> technologies;
  final String categoryKey;
  final List<String> questions;

  const InterviewCategoryModel({
    required this.title,
    required this.description,
    required this.badge,
    required this.isTechnical,
    required this.icon,
    required this.technologies,
    required this.categoryKey,
    required this.questions,
  });

  /// Returns a copy of this category with [questions] replaced -- used by
  /// HomeScreen to swap in live Firestore data without touching the rest
  /// of the card's metadata.
  InterviewCategoryModel copyWithQuestions(List<String> newQuestions) {
    return InterviewCategoryModel(
      title: title,
      description: description,
      badge: badge,
      isTechnical: isTechnical,
      icon: icon,
      technologies: technologies,
      categoryKey: categoryKey,
      questions: newQuestions,
    );
  }

  /// The 9 interview categories shown on the Dashboard.
  /// Mix of technical roles + common remote-job roles, as requested.
  static List<InterviewCategoryModel> categories() {
    return const [
      InterviewCategoryModel(
        title: 'Software Engineer Interview',
        description:
            'Practice coding, system design and problem-solving questions asked in real Software Engineer interviews.',
        badge: MTexts.technicalBadge,
        isTechnical: true,
        icon: Icons.code_rounded,
        technologies: ['DSA', 'System Design'],
        categoryKey: 'Software Engineer',
        questions: MTexts.softwareEngineerQuestions,
      ),
      InterviewCategoryModel(
        title: 'Data Analyst Interview',
        description:
            'Practice SQL, data cleaning and business-insight questions asked in real Data Analyst interviews.',
        badge: MTexts.technicalBadge,
        isTechnical: true,
        icon: Icons.query_stats_rounded,
        technologies: ['SQL', 'Excel'],
        categoryKey: 'Data Analyst',
        questions: MTexts.dataAnalystQuestions,
      ),
      InterviewCategoryModel(
        title: 'Machine Learning Interview',
        description:
            'Sharpen your ML fundamentals, model evaluation and deployment knowledge with realistic questions.',
        badge: MTexts.technicalBadge,
        isTechnical: true,
        icon: Icons.model_training_rounded,
        technologies: ['Python', 'ML'],
        categoryKey: 'Machine Learning',
        questions: MTexts.machineLearningQuestions,
      ),
      InterviewCategoryModel(
        title: 'Full-Stack Developer Interview',
        description:
            'Cover front-end, back-end and database questions in one end-to-end mock interview session.',
        badge: MTexts.technicalBadge,
        isTechnical: true,
        icon: Icons.developer_mode_rounded,
        technologies: ['React', 'Node.js'],
        categoryKey: 'Full Stack Developer',
        questions: MTexts.fullStackDeveloperQuestions,
      ),
      InterviewCategoryModel(
        title: 'Digital Marketing Interview',
        description:
            'Practice campaign strategy, SEO and analytics questions for remote digital marketing roles.',
        badge: MTexts.nonTechnicalBadge,
        isTechnical: false,
        icon: Icons.trending_up_rounded,
        technologies: ['SEO', 'Ads'],
        categoryKey: 'Digital Marketing',
        questions: MTexts.digitalMarketingQuestions,
      ),
      InterviewCategoryModel(
        title: 'Social Media Manager Interview',
        description:
            'Practice content planning, engagement and crisis-handling questions for social media roles.',
        badge: MTexts.nonTechnicalBadge,
        isTechnical: false,
        icon: Icons.campaign_rounded,
        technologies: ['Content', 'Analytics'],
        categoryKey: 'Social Media Manager',
        questions: MTexts.socialMediaManagerQuestions,
      ),
      InterviewCategoryModel(
        title: 'Content Writer Interview',
        description:
            'Practice writing process, SEO writing and editing questions for remote content roles.',
        badge: MTexts.nonTechnicalBadge,
        isTechnical: false,
        icon: Icons.edit_note_rounded,
        technologies: ['SEO Writing', 'Editing'],
        categoryKey: 'Content Writer',
        questions: MTexts.contentWriterQuestions,
      ),
      InterviewCategoryModel(
        title: 'HR / Recruiter Interview',
        description:
            'Practice common HR & recruiting questions about hiring, conflict resolution and onboarding.',
        badge: MTexts.nonTechnicalBadge,
        isTechnical: false,
        icon: Icons.groups_rounded,
        technologies: ['Hiring', 'People Ops'],
        categoryKey: 'HR Recruiter',
        questions: MTexts.hrRecruiterQuestions,
      ),
      InterviewCategoryModel(
        title: 'Virtual Assistant Interview',
        description:
            'Practice organization, communication and multitasking questions for remote assistant roles.',
        badge: MTexts.nonTechnicalBadge,
        isTechnical: false,
        icon: Icons.support_agent_rounded,
        technologies: ['Scheduling', 'Support'],
        categoryKey: 'Virtual Assistant',
        questions: MTexts.virtualAssistantQuestions,
      ),
    ];
  }
}