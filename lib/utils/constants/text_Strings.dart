/// This class contains all the App Text in String formats.
class MTexts {
  // -- GLOBAL Texts

  // -- OnBoarding Texts
  static const String onBoardingTitle1 = "Ace Your Next Interview";
  static const String onBoardingTitle2 = "Practice With AI";
  static const String onBoardingTitle3 = "Get Instant Feedback";

  static const String onBoardingSubTitle1 =
      "Prepare for any job with realistic AI-powered mock interviews tailored for you.";
  static const String onBoardingSubTitle2 =
      "Choose your role, industry, and difficulty. Practice anytime, anywhere.";
  static const String onBoardingSubTitle3 =
      "Receive detailed feedback on answers, confidence, and communication skills instantly.";
  // -- Authentication Form Text
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String email = "E-mail";
  static const String password = "Password";
  static const String newPassword = "New Password";
  static const String username = "UserName";
  static const String phoneNo = "Phone No";
  static const String rememberMe = "Remember Me";
  static const String forgetPassword = "Forget Password";
  static const String signIn = "Sign In";
  static const String createAccount = "Create Account";
  static const String orSignInWith = "or sign in with";
  static const String orSignUpWith = "or sign up with";
  static const String iAgreeTo = "I agree to";
  static const String privacyPolicy = "Privacy Policy";
  static const String termsOfUse = "Terms of Use";
  static const String and = "and ";

  static const String verificationCode = "verification Code";
  static const String resendEmail = "Resend Email";
  static const String resendEmailIn = "Resend email in";

  /// -- Authentication Heading Text
  static const String loginTitle = "Welcome back";
  static const String loginSubTitle =
      "Sign in to continue your AI mock interview journey.";
  static const String signupTitle = "Let's create your account";
  static const String forgetPasswordTitle = "Forget password";
  static const String forgetPasswordSubTitle =
      "Enter your email and we will send you a password reset link";
  static const String changeYourPasswordTitle = "Password reset Email Sent";
  static const String changeYourPasswordSubTitle =
      "we've Sent You a Secure Link to Safely Change Your Password and keep Your Account Protected";
  static const String confirmEmail = "Verify your email address";
  static const String confirmEmailSubTitle =
      "Welcome to MockMaster! Verify your email address to activate your account and start practicing AI interviews.";
  static const String yourAccountCreatedTitle =
      "Your account successfully created";
  static const String yourAccountCreatedSubTitle =
      "Your MockMaster account is ready. Start practicing AI-powered mock interviews and improve your interview skills.";

  // -- Home
  static const String homeAppbarTitle = "Ready to Practice?";
  static const String homeAppbarSubTitle = "Welcome Back";

  // -- Dashboard Greeting (shown inside the Hero Banner, next to the user's name)
  static const String greetingWelcome = "Welcome,";
  static const String greetingDefaultName = "Guest";

  // -- Dashboard Hero Banner
  static const String heroTitle =
      "Get Interview-Ready with AI-Powered Practice & Feedback";
  static const String heroSubTitle =
      "Practice real interview questions & get instant feedback.";
  static const String startAnInterview = "Start an Interview";

  // -- Dashboard Interview Categories
  static const String interviewCategoriesTitle = "Choose an Interview";
  static const String takeInterview = "Take interview";
  static const String technicalBadge = "Technical";
  static const String nonTechnicalBadge = "Non-Technical";

  // -- Create Interview Screen (reached from the Hero Banner button)
  static const String createInterviewTitle = "Create Interview";
  static const String desiredInterviewLabel = "Which interview do you want?";
  static const String desiredInterviewHint =
      "e.g. Frontend Developer, HR Executive...";
  static const String interviewDurationLabel = "Interview Duration";
  static const String numberOfQuestions = "Number of Questions";
  static const String selectDifficulty = "Difficulty Level";

  // Dropdown option labels
  static const List<String> durationOptions = [
    "10 minutes",
    "15 minutes",
    "20 minutes",
    "30 minutes",
    "45 minutes",
  ];
  static const List<String> questionCountOptions = [
    "5 Questions",
    "10 Questions",
    "15 Questions",
    "20 Questions",
  ];

  // -- Interview (Live Session) Screen
  static const String startInterview = "Start Mock Interview";
  static const String chooseRole = "Choose Your Role";
  static const String chooseDifficulty = "Select Difficulty";
  static const String questionLabel = "Question";
  static const String previousQuestion = "Previous";
  static const String skipQuestion = "Skip";
  static const String nextQuestion = "Next";
  static const String endInterview = "End Interview";

  // -- Feedback Screen (shown after "End Interview")
  static const String feedbackScreenTitle = "Interview Feedback";
  static const String feedbackOverallScore = "Overall Score";
  static const String savePdf = "Save as PDF";
  static const String backToDashboard = "Back to Dashboard";
  static const String pdfComingSoonMessage =
      "PDF export will be enabled once the AI feedback engine is connected.";

  // -- Roles
  static const String roleSoftwareEngineer = "Software Engineer";
  static const String roleMarketing = "Marketing Executive";
  static const String roleSales = "Sales Manager";
  static const String roleHR = "HR Manager";

  // -- Difficulty
  static const String difficultyEasy = "Easy";
  static const String difficultyMedium = "Medium";
  static const String difficultyHard = "Hard";

  // -- Feedback
  static const String feedbackScore = "Score";
  static const String feedbackStrengths = "Strengths";
  static const String feedbackImprovements = "Areas to Improve";
  static const String feedbackTip = "Pro Tip";
  static const String continueText = "Continue";
  static const String submitText = "Submit";

  // ===========================================================================
  // -- MOCK QUESTION BANK -----------------------------------------------------
  // These are placeholder/static questions ONLY. Once the real AI question
  // generator is ready, these lists can simply be replaced/fed dynamically —
  // every screen already reads questions from here, nothing else needs to
  // change.
  // ===========================================================================

  /// Used when the user types a custom role on the Create Interview screen
  /// instead of picking one of the 9 Dashboard cards.
  static const List<String> genericInterviewQuestions = [
    "Tell me about yourself and your professional background.",
    "Why are you interested in this role?",
    "What are your greatest strengths relevant to this position?",
    "Describe a challenging project you worked on and how you handled it.",
    "How do you prioritize tasks when working under a deadline?",
    "Tell me about a time you disagreed with a teammate. How was it resolved?",
    "Where do you see yourself professionally in the next few years?",
    "What tools or technologies do you use daily in this field?",
    "How do you handle feedback or criticism on your work?",
    "Do you have any questions for us about the role or the team?",
  ];

  static const List<String> softwareEngineerQuestions = [
    "Walk me through how you approach debugging a production issue.",
    "Explain the difference between a stack and a queue with an example.",
    "How would you design a scalable REST API for a growing app?",
    "Describe a time you had to refactor messy legacy code.",
    "What is the difference between synchronous and asynchronous code?",
    "How do you ensure code quality in a team project?",
    "Explain the concept of Big-O notation with a simple example.",
    "How do you approach writing unit tests for new features?",
    "Tell me about a bug that was hard to reproduce and how you found it.",
    "What version control practices do you follow in a team?",
  ];

  static const List<String> dataAnalystQuestions = [
    "How do you handle missing or inconsistent data in a dataset?",
    "Explain the difference between INNER JOIN and LEFT JOIN with an example.",
    "How would you present a complex dataset to a non-technical stakeholder?",
    "What steps do you take to validate the accuracy of your analysis?",
    "Describe a time your analysis directly influenced a business decision.",
    "Which visualization would you choose to show a trend over time, and why?",
    "How do you decide which metrics matter most for a given business problem?",
    "Explain the difference between correlation and causation.",
    "How do you handle a stakeholder who disagrees with your findings?",
    "What tools do you use for data cleaning and reporting?",
  ];

  static const List<String> machineLearningQuestions = [
    "Explain the difference between supervised and unsupervised learning.",
    "How do you handle overfitting in a machine learning model?",
    "What is the bias-variance tradeoff?",
    "Walk me through your process for evaluating a classification model.",
    "How would you handle an imbalanced dataset?",
    "Explain how a decision tree makes predictions.",
    "What is the purpose of a validation set versus a test set?",
    "Describe a machine learning project you're proud of, end-to-end.",
    "How do you decide which algorithm to try first for a new problem?",
    "How would you explain a model's prediction to a non-technical manager?",
  ];

  static const List<String> fullStackDeveloperQuestions = [
    "How do you manage state between the frontend and backend of an app?",
    "Explain how you would secure a REST API endpoint.",
    "Describe your process for turning a UI design into working code.",
    "How do you handle version conflicts when merging branches?",
    "What is your approach to optimizing a slow-loading web page?",
    "How would you structure a full-stack project from scratch?",
    "Explain the role of a database index and when you'd add one.",
    "How do you keep the frontend and backend in sync during development?",
    "Describe a bug that spanned both frontend and backend. How did you fix it?",
    "What's your approach to deploying a full-stack application?",
  ];

  static const List<String> digitalMarketingQuestions = [
    "How do you measure the success of a digital marketing campaign?",
    "Describe a campaign you ran that didn't perform well. What did you learn?",
    "How do you decide which platform to prioritize for a new product?",
    "What is your approach to keyword research for SEO?",
    "How do you allocate budget across multiple ad campaigns?",
    "Explain how you would improve a landing page's conversion rate.",
    "How do you stay updated with changing marketing trends?",
    "Describe how you'd build a content calendar for a brand.",
    "How do you handle negative feedback or reviews online?",
    "What metrics matter most to you when reporting to a client?",
  ];

  static const List<String> socialMediaManagerQuestions = [
    "How do you plan a content calendar across multiple platforms?",
    "Describe how you'd grow engagement for a brand with a small following.",
    "How do you handle a social media crisis or negative viral post?",
    "What tools do you use to schedule and analyze social posts?",
    "How do you tailor content differently for Instagram vs LinkedIn?",
    "Describe a campaign you managed and its results.",
    "How do you decide on posting frequency for a brand?",
    "How would you collaborate with influencers for a campaign?",
    "How do you measure ROI from social media efforts?",
    "How do you stay creative when producing content consistently?",
  ];

  static const List<String> contentWriterQuestions = [
    "How do you research a topic you're unfamiliar with before writing?",
    "Describe your process for editing and proofreading your own work.",
    "How do you adapt your tone for different brands or audiences?",
    "How do you approach writing SEO-friendly content?",
    "Tell me about a piece of content you're especially proud of.",
    "How do you handle tight deadlines with multiple writing assignments?",
    "How do you incorporate feedback from an editor or client?",
    "What's your process for coming up with content ideas?",
    "How do you ensure consistency across a brand's content?",
    "How do you measure whether a piece of content performed well?",
  ];

  static const List<String> hrRecruiterQuestions = [
    "How do you evaluate a candidate's cultural fit during an interview?",
    "Describe how you'd handle a conflict between two team members.",
    "What is your approach to sourcing candidates for a hard-to-fill role?",
    "How do you keep candidates engaged throughout a long hiring process?",
    "Describe a time you had to deliver difficult news to an employee.",
    "How do you ensure fairness and reduce bias in interviews?",
    "How would you onboard a new remote employee effectively?",
    "What HR metrics do you track regularly, and why?",
    "How do you handle a high employee turnover situation?",
    "How do you stay updated on labor laws and HR best practices?",
  ];

  static const List<String> virtualAssistantQuestions = [
    "How do you manage multiple clients' schedules at the same time?",
    "Describe your process for organizing and prioritizing daily tasks.",
    "How do you handle a client who is unclear about their requirements?",
    "What tools do you use for task and time management?",
    "How do you maintain confidentiality when handling sensitive information?",
    "Describe a time you solved a problem without direct supervision.",
    "How do you handle communication across different time zones?",
    "What steps do you take to ensure accuracy in repetitive tasks?",
    "How do you handle a sudden increase in workload?",
    "How do you keep clients updated on the status of ongoing tasks?",
  ];

  // -- Chatbot / MockMaster AI Assistant
  static const String chatbotAppbarTitle = "MockMaster AI Assistant";
  static const String chatbotAppbarSubtitle = "Your AI Career & Interview Coach";
  static const String chatbotWelcomeMessage =
      "Hi! I'm your MockMaster AI Assistant \u{1F44B}\n\n"
      "I can help you prepare for interviews, choose the right interview, "
      "answer career questions, and guide you through MockMaster.\n\n"
      "How can I help you today?";
  static const String chatbotInputHint = "Ask me anything about interviews or careers...";
  static const String chatbotErrorMessage =
      "Sorry, I'm having trouble connecting right now. Please try again in a moment.";
  static const String chatbotEmptyInputMessage = "Type a message before sending.";
  static const String chatbotDrawerLabel = "AI Assistant";

  static const String suggestionPrepareInterview = "Prepare for an Interview";
  static const String suggestionChooseInterview = "Choose an Interview";
  static const String suggestionPracticeQuestions = "Practice Interview Questions";
  static const String suggestionAnalyzePerformance = "Analyze My Performance";
  static const String suggestionResumeHelp = "Resume/CV Help";
  static const String suggestionHowItWorks = "How MockMaster Works";
}
