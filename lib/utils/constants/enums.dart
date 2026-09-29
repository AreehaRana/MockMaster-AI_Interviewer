/// LIST OF Enums for Mock AI Interviewer
/// They cannot be created inside a class.
library;

// Interview difficulty levels
enum InterviewDifficulty { easy, medium, hard }

// Job roles/categories for interview
enum JobRole {
  softwareEngineer,
  dataAnalyst,
  productManager,
  marketing,
  sales,
  hr,
  finance,
  customerSupport,
}

// Type of interview questions
enum QuestionType { technical, behavioral, situational, hr }

// Status of interview session
enum InterviewStatus { notStarted, inProgress, completed, paused }

// AI Feedback rating categories
enum FeedbackCategory {
  communication,
  technicalKnowledge,
  confidence,
  clarity,
  overall,
}

// Feedback score level
enum FeedbackLevel { poor, average, good, excellent }
