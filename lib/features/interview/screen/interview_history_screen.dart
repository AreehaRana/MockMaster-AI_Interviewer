import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_panel.dart';
import 'package:mockmaster/features/interview/services/interview_session_services.dart';
import 'package:mockmaster/utils/constants/sizes.dart';

/// Shows every interview the signed-in user has completed -- title,
/// score, and date -- not just the drawer's plain count. Opened by
/// tapping "Interviews Completed" in MAppDrawer.
class InterviewHistoryScreen extends StatelessWidget {
  const InterviewHistoryScreen({super.key});

  Color _scoreColor(int score, ColorScheme scheme) {
    if (score >= 75) return Colors.green;
    if (score >= 45) return Colors.orange;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final scheme = Theme.of(context).colorScheme;

    // Transparent scaffold + app bar so the ombre gradient shows through everywhere.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Interview History'),
      ),
      body: MGradientBackground(
        child: SafeArea(
          child: uid == null
              ? const Center(child: Text('Sign in to see your interview history.'))
              : StreamBuilder<List<InterviewSessionModel>>(
                  stream: InterviewSessionService.instance.watchSessions(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Could not load history: ${snapshot.error}'),
                      );
                    }

                    final sessions = snapshot.data ?? [];
                    if (sessions.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(MSizes.defaultSpace),
                          child: Text(
                            'No interviews completed yet.\nTake your first one from the dashboard!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(MSizes.defaultSpace),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final scoreColor = _scoreColor(session.overallScore, scheme);
                        final dateLabel = session.completedAt != null
                            ? DateFormat('MMM d, yyyy • h:mm a').format(session.completedAt!)
                            : 'Just now';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: MSizes.sm),
                          child: MGlassPanel(
                            padding: const EdgeInsets.all(MSizes.md),
                            animate: false,
                            child: Row(
                              children: [
                                // Score badge
                                Container(
                                  width: 52,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: scoreColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${session.overallScore}%',
                                    style: TextStyle(
                                      color: scoreColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: MSizes.md),

                                // Title + date + answered count
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.interviewTitle,
                                        style: Theme.of(context).textTheme.titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${session.answeredQuestions} / ${session.totalQuestions} answered  •  $dateLabel',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}