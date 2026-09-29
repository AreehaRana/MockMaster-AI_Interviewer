import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// ---------------------------------------------------------------------------
/// MODELS
/// ---------------------------------------------------------------------------

class QuestionEvaluation {
  final int index;
  final bool wasAnswered;
  final int score;
  final String feedback;

  QuestionEvaluation({
    required this.index,
    required this.wasAnswered,
    required this.score,
    required this.feedback,
  });

  factory QuestionEvaluation.fromJson(Map<String, dynamic> json) {
    return QuestionEvaluation(
      index: (json['index'] as num?)?.toInt() ?? 0,
      wasAnswered: json['wasAnswered'] as bool? ?? false,
      score: (json['score'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? '',
    );
  }

  QuestionEvaluation copyWith({
    int? index,
    bool? wasAnswered,
    int? score,
    String? feedback,
  }) {
    return QuestionEvaluation(
      index: index ?? this.index,
      wasAnswered: wasAnswered ?? this.wasAnswered,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
    );
  }
}

class InterviewEvaluation {
  final int overallScore;
  final List<String> strengths;
  final List<String> improvements;
  final List<QuestionEvaluation> perQuestion;

  InterviewEvaluation({
    required this.overallScore,
    required this.strengths,
    required this.improvements,
    required this.perQuestion,
  });

  factory InterviewEvaluation.fromJson(Map<String, dynamic> json) {
    return InterviewEvaluation(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      strengths:
          (json['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [],
      improvements:
          (json['improvements'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      perQuestion: (json['perQuestion'] as List? ?? [])
          .whereType<Map>()
          .map((e) => QuestionEvaluation.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Number of questions the candidate actually attempted.
  int get answeredCount => perQuestion.where((q) => q.wasAnswered).length;

  /// Builds a fully validated evaluation: the model's raw JSON is parsed,
  /// then every question is re-checked against [AnswerGuard] and the
  /// overall score is recomputed from the (possibly corrected) per-question
  /// scores. The AI can never "gift" marks for a non-answer anymore.
  factory InterviewEvaluation.fromModelJson(
    Map<String, dynamic> json, {
    required List<String> questions,
    required Map<int, String> answers,
  }) {
    final raw = InterviewEvaluation.fromJson(json);
    final byIndex = {for (final q in raw.perQuestion) q.index: q};

    final fixed = <QuestionEvaluation>[];
    for (var i = 0; i < questions.length; i++) {
      final answer = answers[i]?.trim() ?? '';
      final model = byIndex[i];

      // Rule 1: blank / "I don't know" / filler-only => hard zero.
      if (AnswerGuard.isNonAnswer(answer)) {
        fixed.add(QuestionEvaluation(
          index: i,
          wasAnswered: false,
          score: 0,
          feedback: AnswerGuard.nonAnswerFeedback(answer),
        ));
        continue;
      }

      // Rule 2: model returned nothing for this index => treat as unscored 0.
      if (model == null) {
        fixed.add(QuestionEvaluation(
          index: i,
          wasAnswered: true,
          score: 0,
          feedback:
              'This answer could not be evaluated automatically, so it was not '
              'awarded any marks. Try re-recording a clearer, more complete '
              'answer for this question.',
        ));
        continue;
      }

      // Rule 3: clamp + keep score and wasAnswered consistent with each other.
      var score = model.score.clamp(0, 100);
      var wasAnswered = model.wasAnswered;
      if (!wasAnswered) score = 0;
      if (score == 0) wasAnswered = false;

      fixed.add(model.copyWith(
        index: i,
        score: score,
        wasAnswered: wasAnswered,
        feedback: model.feedback.trim().isEmpty
            ? 'No detailed feedback was returned for this answer.'
            : model.feedback.trim(),
      ));
    }

    // Rule 4: overall score is the average over ALL questions, so skipped
    // questions drag the total down instead of being quietly ignored.
    final total = fixed.fold<int>(0, (sum, q) => sum + q.score);
    final overall =
        questions.isEmpty ? 0 : (total / questions.length).round().clamp(0, 100);

    return InterviewEvaluation(
      overallScore: overall,
      strengths: raw.strengths,
      improvements: raw.improvements,
      perQuestion: fixed,
    );
  }

  /// Offline / last-resort fallback. Deliberately conservative: non-answers
  /// get 0 and everything else gets a capped "unverified" score, because no
  /// model actually checked the content for correctness.
  factory InterviewEvaluation.heuristic({
    required List<String> questions,
    required Map<int, String> answers,
  }) {
    final perQuestion = <QuestionEvaluation>[];

    for (var i = 0; i < questions.length; i++) {
      final answer = answers[i]?.trim() ?? '';

      if (AnswerGuard.isNonAnswer(answer)) {
        perQuestion.add(QuestionEvaluation(
          index: i,
          wasAnswered: false,
          score: 0,
          feedback: AnswerGuard.nonAnswerFeedback(answer),
        ));
        continue;
      }

      final words = AnswerGuard.meaningfulWordCount(answer);
      // 12 words ~ a bare attempt, 60+ words ~ a developed answer.
      final depth = ((words - 12) / 48).clamp(0.0, 1.0);
      final score = (35 + depth * 25).round(); // 35..60 only

      perQuestion.add(QuestionEvaluation(
        index: i,
        wasAnswered: true,
        score: score,
        feedback:
            'This is an offline estimate based on how developed your answer '
            'was ($words meaningful words), not on whether it was technically '
            'correct. Reconnect to the internet and re-run the feedback to get '
            'a real evaluation of the content.',
      ));
    }

    final total = perQuestion.fold<int>(0, (sum, q) => sum + q.score);
    final overall = questions.isEmpty
        ? 0
        : (total / questions.length).round().clamp(0, 100);

    return InterviewEvaluation(
      overallScore: overall,
      strengths: const [
        'You attempted the interview end to end, which is the hardest part of '
            'building interview confidence.',
      ],
      improvements: const [
        'This score is an offline estimate only — it does not check whether '
            'your answers were correct. Run the feedback again while online for '
            'a real, content-based evaluation.',
      ],
      perQuestion: perQuestion,
    );
  }
}

/// ---------------------------------------------------------------------------
/// ANSWER VALIDATION (the actual fix)
/// ---------------------------------------------------------------------------

/// Detects answers that should never earn marks — blank transcripts,
/// "I don't know" style refusals, and filler-only speech. This runs on the
/// device, so it works even if the model ignores the prompt.
class AnswerGuard {
  static final RegExp _punct = RegExp(r"[^a-z0-9\s']");
  static final RegExp _spaces = RegExp(r'\s+');

  static final RegExp _fillers = RegExp(
    r"\b(um+|uh+|hmm+|mm+|er+|ah+|eh+|like|okay|ok|yeah|yep|nope|so|well|"
    r"basically|actually|literally|you know|i mean|right|hello|hi|thanks|"
    r"thank you|next|question)\b",
  );

  /// Refusals / non-answers. Matched against the cleaned (lowercased,
  /// punctuation-stripped) transcript.
  static const List<String> _refusalPhrases = [
    "i dont know",
    "i do not know",
    "dont know",
    "do not know",
    "no idea",
    "not sure",
    "im not sure",
    "i am not sure",
    "idk",
    "i cant answer",
    "i cannot answer",
    "cant answer this",
    "i have no clue",
    "no clue",
    "i forgot",
    "i dont remember",
    "i dont understand",
    "i didnt understand",
    "skip this",
    "skip it",
    "lets skip",
    "pass",
    "next question",
    "leave it",
    "no comment",
    "nothing",
    "pata nahi",
    "nahi pata",
    "mujhe nahi pata",
    "nahi ata",
    "nahi aata",
    "mujhe nahi ata",
    "skip karo",
    "agla sawal",
  ];

  static String clean(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(_punct, ' ')
        .replaceAll(_spaces, ' ')
        .trim();
  }

  /// Words left after stripping filler / stopword noise.
  static int meaningfulWordCount(String raw) {
    final stripped = clean(raw)
        .replaceAll(_fillers, ' ')
        .replaceAll(_spaces, ' ')
        .trim();
    if (stripped.isEmpty) return 0;
    return stripped.split(' ').where((w) => w.length > 2).length;
  }

  /// True when the transcript is not a genuine attempt at the question.
  static bool isNonAnswer(String raw) {
    final cleaned = clean(raw);
    if (cleaned.isEmpty) return true;

    final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();

    // Too short to be a real interview answer.
    if (words.length < 4) return true;

    // A refusal phrase inside a SHORT utterance is a refusal.
    // (Long answers may legitimately say "I'm not sure about X, but ...",
    // so we only apply this when there is nothing else of substance.)
    if (words.length <= 15) {
      for (final phrase in _refusalPhrases) {
        if (cleaned.contains(phrase)) return true;
      }
    } else {
      for (final phrase in _refusalPhrases) {
        if (cleaned.startsWith(phrase) && meaningfulWordCount(raw) < 10) {
          return true;
        }
      }
    }

    // Only fillers ("umm okay yeah so like...") — no real content.
    if (meaningfulWordCount(raw) < 4) return true;

    return false;
  }

  static String nonAnswerFeedback(String raw) {
    final cleaned = clean(raw);
    if (cleaned.isEmpty) {
      return 'No answer was recorded for this question, so it scores 0. Even '
          'when you are unsure, say what you do know — name the concept, give '
          'a rough definition, or describe a related example. Silence gives an '
          'interviewer nothing to work with, while a partial answer can still '
          'earn most of the marks. Next time, take a breath, restate the '
          'question in your own words, and build an answer from there.';
    }
    return 'This was not a real attempt at the question, so it scores 0. '
        'Saying you do not know (or skipping) ends the conversation instead of '
        'opening it up. A much stronger move is to say what you do recall, '
        'reason out loud from first principles, and then admit the specific '
        'gap — for example, "I know it is used for X, I am less clear on how Y '
        'works." Interviewers reward structured thinking far more than a '
        'perfect recall of terminology.';
  }
}

/// ---------------------------------------------------------------------------
/// SHARED PROMPT (used by both Gemini and Ollama so grading stays identical)
/// ---------------------------------------------------------------------------

class EvaluationPrompt {
  static String build(List<Map<String, dynamic>> qaPairs) => '''
You are a strict but fair technical interview evaluator. Grade the candidate
on the CONTENT and CORRECTNESS of each answer, not on how long they talked.

STEP 1 - VALIDATE THE ANSWER. Before scoring, decide whether the candidate
actually attempted the question:
- Blank, silence, or a transcript with no real content -> wasAnswered: false, score: 0
- "I don't know", "not sure", "no idea", "pass", "skip", "next question",
  "pata nahi" / "nahi pata" or any similar refusal -> wasAnswered: false, score: 0
- Filler-only speech ("umm okay yeah so like...") -> wasAnswered: false, score: 0
- An answer about a completely different topic than the question asked
  -> wasAnswered: true, score 0-15 (it was attempted, but it is wrong)
NEVER award marks for length, confidence, or fluency alone. A long, confident,
wrong answer scores LOWER than a short, correct one.

STEP 2 - SCORE 0-100 using this rubric:
- 0-15  : no attempt, refusal, or completely off-topic / factually wrong
- 16-39 : on-topic but mostly incorrect, or only repeats the question back
- 40-59 : partially correct; the core idea is touched but key concepts,
          terminology, or reasoning are missing or muddled
- 60-79 : correct and relevant, but shallow — lacks depth, examples, trade-offs,
          or precise terminology
- 80-89 : correct, well-structured, uses the right terminology, includes a
          concrete example or trade-off
- 90-100: expert-level — correct, precise, well-structured, with examples,
          edge cases, and trade-offs discussed

Be honest and conservative. Most real candidate answers fall in the 30-70 band.
Do not cluster every score around 70-80.

STEP 3 - WRITE DETAILED FEEDBACK, not one-liners:
- "feedback" (per question): 3-5 sentences. State plainly whether the answer was
  correct, partially correct, or wrong, and WHY. Name the specific concepts,
  terms, or examples the candidate should have mentioned. Quote or reference the
  actual words they used. Note if it was vague, rambling, or off-topic. End with
  one concrete tip for improving that answer.
- "strengths": 3-5 bullets, each 1-2 full sentences describing a specific pattern
  across the answers (not generic praise — explain WHERE and WHY it showed up).
  If the candidate genuinely showed few strengths, return fewer bullets and say
  so honestly rather than inventing praise.
- "improvements": 3-5 bullets, each 1-2 full sentences, specific and actionable,
  tied to concrete examples from their answers.

STEP 4 - "overallScore" must be the plain average of every per-question score,
including the questions that scored 0. Do not round it upward to be kind.

Return ONE object for EVERY question index, even the unanswered ones.

Return ONLY a JSON object -- no markdown, no commentary, no text before or
after -- in this exact shape:
{
  "overallScore": 0,
  "strengths": ["detailed multi-sentence bullet", "detailed multi-sentence bullet"],
  "improvements": ["detailed multi-sentence bullet", "detailed multi-sentence bullet"],
  "perQuestion": [
    {"index": 0, "wasAnswered": true, "score": 80, "feedback": "3-5 detailed sentences explaining the evaluation of this specific answer"}
  ]
}

Question/Answer pairs:
${jsonEncode(qaPairs)}
''';

  /// Builds the payload sent to the model. Answers already flagged as
  /// non-answers are labelled so the model cannot misread a stray filler
  /// transcript as a real attempt.
  static List<Map<String, dynamic>> buildPairs({
    required List<String> questions,
    required Map<int, String> answers,
  }) {
    return List.generate(questions.length, (i) {
      final answer = answers[i]?.trim() ?? '';
      final isNonAnswer = AnswerGuard.isNonAnswer(answer);
      return {
        'index': i,
        'question': questions[i],
        'answer': answer.isEmpty ? '(no answer given)' : answer,
        'candidateAttempted': !isNonAnswer,
        if (isNonAnswer)
          'note':
              'This transcript was flagged as a refusal/blank/filler-only '
                  'answer. It MUST receive wasAnswered=false and score=0.',
      };
    });
  }
}

/// ---------------------------------------------------------------------------
/// GEMINI SERVICE
/// ---------------------------------------------------------------------------

class GeminiFeedbackService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<InterviewEvaluation?> evaluateAnswers({
    required List<String> questions,
    required Map<int, String> answers,
  }) async {
    if (_apiKey.isEmpty) return null;
    if (questions.isEmpty) return null;

    // Shortcut: if the candidate answered nothing at all, there is nothing
    // to send to the model — it is a guaranteed zero.
    final attemptedAny = List.generate(questions.length, (i) => i).any(
      (i) => !AnswerGuard.isNonAnswer(answers[i]?.trim() ?? ''),
    );
    if (!attemptedAny) {
      return InterviewEvaluation.fromModelJson(
        {'overallScore': 0, 'strengths': [], 'improvements': [], 'perQuestion': []},
        questions: questions,
        answers: answers,
      );
    }

    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        // Low temperature = consistent, less generous grading.
        temperature: 0.2,
      ),
    );

    final prompt = EvaluationPrompt.build(
      EvaluationPrompt.buildPairs(questions: questions, answers: answers),
    );

    try {
      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 35));
      final text = response.text;
      if (text == null || text.isEmpty) return null;

      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        // Every score passes through the guard before it reaches the UI.
        return InterviewEvaluation.fromModelJson(
          decoded,
          questions: questions,
          answers: answers,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}