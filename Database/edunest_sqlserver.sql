-- SQL Server LocalDB setup for EduNest. Safe to rerun; creates missing tables and seed rows.
IF DB_ID(N'EduNestDb') IS NULL CREATE DATABASE EduNestDb;
GO
USE EduNestDb;
GO
IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Users (

    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName        VARCHAR(100)  NOT NULL,
    Email           VARCHAR(150)  NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255)  NOT NULL,
    PasswordSalt    VARCHAR(100)  NOT NULL,
    Role            VARCHAR(20) NOT NULL DEFAULT 'Student',
    IsActive        BIT    NOT NULL DEFAULT 1,
    CreatedDate     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);
END
GO
IF OBJECT_ID('dbo.Courses', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Courses (

    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    Title           VARCHAR(150)  NOT NULL,
    Description     NVARCHAR(MAX),
    Category        VARCHAR(60)   NOT NULL DEFAULT 'Technology',
    Level           VARCHAR(20) NOT NULL DEFAULT 'Beginner',
    EstimatedHours  SMALLINT NOT NULL DEFAULT 8,
    LecturerID      INT           NOT NULL,
    CreatedDate     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_course_estimated_hours CHECK (EstimatedHours >= 1),
        CONSTRAINT fk_course_lecturer FOREIGN KEY (LecturerID) REFERENCES Users(UserID) ON DELETE CASCADE
);
END
GO
IF OBJECT_ID('dbo.LearningPathTopics', 'U') IS NULL
BEGIN
CREATE TABLE dbo.LearningPathTopics (

    TopicID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID        INT           NOT NULL,
    Title           VARCHAR(150)  NOT NULL,
    Content         NVARCHAR(MAX),
    SequenceOrder   INT           NOT NULL DEFAULT 1,
    ResourceTitle   NVARCHAR(200) NULL,
    ResourceUrl     NVARCHAR(500) NULL,
    CONSTRAINT chk_topic_sequence CHECK (SequenceOrder >= 1),
    CONSTRAINT fk_topic_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);
END
GO
IF COL_LENGTH('dbo.LearningPathTopics', 'ResourceTitle') IS NULL
    ALTER TABLE dbo.LearningPathTopics ADD ResourceTitle NVARCHAR(200) NULL;
IF COL_LENGTH('dbo.LearningPathTopics', 'ResourceUrl') IS NULL
    ALTER TABLE dbo.LearningPathTopics ADD ResourceUrl NVARCHAR(500) NULL;
GO
IF OBJECT_ID('dbo.Enrollments', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Enrollments (

    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID        INT NOT NULL,
    StudentID       INT NOT NULL,
    EnrolledDate    DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT fk_enroll_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE,
    -- Keep the direct user relationship restrictive. Courses also cascade to
    -- enrollments, and SQL Server rejects both paths cascading from Users.
    CONSTRAINT fk_enroll_student FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    CONSTRAINT uq_enrollment UNIQUE (CourseID, StudentID)
);
END
GO
IF OBJECT_ID('dbo.CourseFeedback', 'U') IS NULL
BEGIN
CREATE TABLE dbo.CourseFeedback (
    CourseFeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID         INT NOT NULL,
    StudentID        INT NOT NULL,
    Rating           TINYINT NOT NULL,
    FeedbackText     NVARCHAR(1000) NOT NULL,
    CreatedDate      DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT chk_course_feedback_rating CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT fk_course_feedback_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE,
    CONSTRAINT fk_course_feedback_student FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    CONSTRAINT uq_course_feedback UNIQUE (CourseID, StudentID)
);
END
GO
IF OBJECT_ID('dbo.TopicProgress', 'U') IS NULL
BEGIN
CREATE TABLE dbo.TopicProgress (

    ProgressID INT IDENTITY(1,1) PRIMARY KEY,
    TopicID         INT NOT NULL,
    StudentID       INT NOT NULL,
    CompletedDate   DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT fk_progress_topic FOREIGN KEY (TopicID) REFERENCES LearningPathTopics(TopicID) ON DELETE CASCADE,
    CONSTRAINT fk_progress_student FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    CONSTRAINT uq_progress UNIQUE (TopicID, StudentID)
);
END
GO
IF OBJECT_ID('dbo.Quizzes', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Quizzes (

    QuizID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID        INT NOT NULL,
    Title           VARCHAR(150) NOT NULL,
    CONSTRAINT fk_quiz_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);
END
GO
IF OBJECT_ID('dbo.QuizQuestions', 'U') IS NULL
BEGIN
CREATE TABLE dbo.QuizQuestions (

    QuestionID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID          INT NOT NULL,
    QuestionText    VARCHAR(500) NOT NULL,
    OptionA         VARCHAR(255) NOT NULL,
    OptionB         VARCHAR(255) NOT NULL,
    OptionC         VARCHAR(255) NOT NULL,
    OptionD         VARCHAR(255) NOT NULL,
    CorrectOption   CHAR(1) NOT NULL,
    CONSTRAINT chk_question_correct_option CHECK (CorrectOption IN ('A','B','C','D')),
    CONSTRAINT fk_question_quiz FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID) ON DELETE CASCADE
);
END
GO
IF OBJECT_ID('dbo.QuizAttempts', 'U') IS NULL
BEGIN
CREATE TABLE dbo.QuizAttempts (

    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    QuizID          INT NOT NULL,
    StudentID       INT NOT NULL,
    Score           INT NOT NULL,
    TotalQuestions  INT NOT NULL,
    CONSTRAINT chk_quiz_attempt_score CHECK (Score >= 0 AND TotalQuestions >= 1 AND Score <= TotalQuestions),
    AttemptDate     DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT fk_attempt_quiz FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID) ON DELETE CASCADE,
    CONSTRAINT fk_attempt_student FOREIGN KEY (StudentID) REFERENCES Users(UserID)
);
END
GO
IF OBJECT_ID('dbo.Assignments', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Assignments (

    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID        INT NOT NULL,
    Title           VARCHAR(150) NOT NULL,
    Description     NVARCHAR(MAX),
    DueDate         DATE NOT NULL,
    CONSTRAINT fk_assignment_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);
END
GO
IF OBJECT_ID('dbo.AssignmentSubmissions', 'U') IS NULL
BEGIN
CREATE TABLE dbo.AssignmentSubmissions (

    SubmissionID INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentID    INT NOT NULL,
    StudentID       INT NOT NULL,
    SubmissionText  NVARCHAR(MAX) NOT NULL,
    Grade           DECIMAL(5,2) NULL,
    Feedback        NVARCHAR(MAX) NULL,
    SubmittedDate   DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT chk_submission_grade CHECK (Grade IS NULL OR Grade BETWEEN 0 AND 100),
    CONSTRAINT fk_submission_assignment FOREIGN KEY (AssignmentID) REFERENCES Assignments(AssignmentID) ON DELETE CASCADE,
    CONSTRAINT fk_submission_student FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    CONSTRAINT uq_submission UNIQUE (AssignmentID, StudentID)
);
END
GO
IF OBJECT_ID('dbo.PeerReviews', 'U') IS NULL
BEGIN
CREATE TABLE dbo.PeerReviews (

    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    SubmissionID    INT NOT NULL,
    ReviewerID      INT NOT NULL,
    Feedback        NVARCHAR(MAX) NOT NULL,
    Rating          INT NOT NULL,
    CONSTRAINT chk_peer_review_rating CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate      DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT fk_review_submission FOREIGN KEY (SubmissionID) REFERENCES AssignmentSubmissions(SubmissionID) ON DELETE CASCADE,
    CONSTRAINT fk_review_reviewer FOREIGN KEY (ReviewerID) REFERENCES Users(UserID),
    CONSTRAINT uq_peer_review UNIQUE (SubmissionID, ReviewerID)
);
END
GO
IF OBJECT_ID('dbo.StudySessions', 'U') IS NULL
BEGIN
CREATE TABLE dbo.StudySessions (

    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    CreatedBy       INT NOT NULL,
    Title           VARCHAR(150) NOT NULL,
    SessionDate     DATE NOT NULL,
    SessionTime     TIME NOT NULL,
    Description     VARCHAR(500),
    CONSTRAINT fk_session_creator FOREIGN KEY (CreatedBy) REFERENCES Users(UserID) ON DELETE CASCADE
);
END
GO
IF OBJECT_ID('dbo.StudySessionParticipants', 'U') IS NULL
BEGIN
CREATE TABLE dbo.StudySessionParticipants (

    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    SessionID       INT NOT NULL,
    StudentID       INT NOT NULL,
    CONSTRAINT fk_participant_session FOREIGN KEY (SessionID) REFERENCES StudySessions(SessionID) ON DELETE CASCADE,
    CONSTRAINT fk_participant_student FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    CONSTRAINT uq_participant UNIQUE (SessionID, StudentID)
);
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_courses_catalog' AND object_id = OBJECT_ID('dbo.Courses'))
    CREATE INDEX idx_courses_catalog ON dbo.Courses (Category, Level);
GO
-- SEED DATA (for testing / demo). Seed accounts all use Password123.
-- Each block checks natural keys so rerunning the setup does not duplicate
-- records or overwrite changes made to existing records.
-- =========================================================
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT 'System Admin', 'admin@edunest.com', 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Admin'
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'admin@edunest.com');
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT 'Santosh Shah', 'lecturer@edunest.com', 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'lecturer@edunest.com');
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT 'Amit Ghimire', 'student@edunest.com', 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Student'
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'student@edunest.com');

INSERT INTO Courses (Title, Description, LecturerID)
SELECT seed.Title, seed.Description, lecturer.UserID
FROM (SELECT 'Web Application Development' AS Title, 'Learn to design and build database-driven websites.' AS Description
      UNION ALL SELECT 'Database Systems', 'Fundamentals of relational database design and SQL.') seed
JOIN Users lecturer ON lecturer.Email = 'lecturer@edunest.com' AND lecturer.Role = 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Courses c WHERE c.Title = seed.Title AND c.LecturerID = lecturer.UserID);

-- Put the starter courses in catalog subjects with matching artwork and filters.
UPDATE Courses SET Category = 'Web Development'
WHERE Title = 'Web Application Development' AND Category = 'Technology';
UPDATE Courses SET Category = 'Data & Analytics'
WHERE Title = 'Database Systems' AND Category = 'Technology';

-- Additional demo lecturers used by the expanded course catalog.
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT seed.FullName, seed.Email, 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Lecturer'
FROM (VALUES
    ('Prakriti Joshi', 'prakriti.joshi@edunest.com'),
    ('Nabin Shrestha', 'nabin.shrestha@edunest.com'),
    ('Asha Rai', 'asha.rai@edunest.com')
) AS seed(FullName, Email)
WHERE NOT EXISTS (SELECT 1 FROM Users u WHERE u.Email = seed.Email);

-- Expanded technology catalog. Categories map to the bundled course artwork
-- in App_Code/CourseVisualHelper.cs and Images/Courses/.
INSERT INTO Courses (Title, Description, Category, Level, EstimatedHours, LecturerID)
SELECT seed.Title, seed.Description, seed.Category, seed.Level, seed.EstimatedHours, lecturer.UserID
FROM (VALUES
    ('Full-Stack Web Engineering with React & ASP.NET', 'Build modern web products with accessible React interfaces, REST APIs, ASP.NET, authentication, testing, and relational data.', 'Web Development', 'Intermediate', 32, 'lecturer@edunest.com'),
    ('Applied Generative AI & LLM Applications', 'Create responsible AI features with prompt design, retrieval-augmented generation, evaluation, and secure API integration.', 'AI & Machine Learning', 'Advanced', 24, 'prakriti.joshi@edunest.com'),
    ('Python Data Science & Analytics', 'Turn raw data into clear insights using Python, pandas, visualization, statistics, and practical machine-learning workflows.', 'Data & Analytics', 'Intermediate', 28, 'prakriti.joshi@edunest.com'),
    ('Cloud-Native Engineering with AWS & Docker', 'Package services, design resilient cloud infrastructure, automate deployments, and monitor production workloads.', 'Cloud & DevOps', 'Intermediate', 30, 'nabin.shrestha@edunest.com'),
    ('Cybersecurity & Ethical Hacking Essentials', 'Practice threat modeling, secure configuration, web security testing, incident response, and responsible disclosure.', 'Cybersecurity', 'Beginner', 24, 'nabin.shrestha@edunest.com'),
    ('Cross-Platform App Development with Flutter', 'Design and ship responsive Android and iOS apps with Flutter, Dart, state management, APIs, and device testing.', 'Mobile Development', 'Intermediate', 26, 'asha.rai@edunest.com'),
    ('DevOps Automation & CI/CD', 'Build reliable delivery pipelines with Git, automated tests, containers, deployment strategies, and observability.', 'Cloud & DevOps', 'Advanced', 22, 'nabin.shrestha@edunest.com'),
    ('UI/UX & Digital Product Design with Figma', 'Research user needs, map journeys, prototype accessible interfaces, test usability, and hand off a consistent design system.', 'Product Design', 'Beginner', 18, 'asha.rai@edunest.com'),
    ('Blockchain dApp Development with Solidity', 'Understand EVM networks, write and test smart contracts, connect wallets, and assess common contract risks.', 'Web3 & Blockchain', 'Advanced', 24, 'asha.rai@edunest.com'),
    ('Modern Database Engineering with MySQL & Redis', 'Model reliable relational data, tune queries and indexes, add caching, and plan safe schema changes.', 'Data & Analytics', 'Intermediate', 20, 'prakriti.joshi@edunest.com'),
    ('Computer Networking & Infrastructure Foundations', 'Learn how networks move data, configure addressing and routing, diagnose connectivity, and secure modern infrastructure.', 'Networking & Infrastructure', 'Beginner', 20, 'nabin.shrestha@edunest.com'),
    ('Front-End Interface Engineering with Vue & TypeScript', 'Build maintainable interfaces with typed components, accessible interactions, reusable design patterns, and practical browser testing.', 'Web Development', 'Intermediate', 26, 'lecturer@edunest.com'),
    ('Machine Learning for Predictive Analytics', 'Prepare datasets, compare supervised learning methods, evaluate model performance, and explain prediction limits.', 'AI & Machine Learning', 'Advanced', 28, 'prakriti.joshi@edunest.com'),
    ('Business Intelligence with SQL Server & Power BI', 'Shape relational data, write analytical SQL, build clear dashboards, and communicate business findings responsibly.', 'Data & Analytics', 'Intermediate', 24, 'prakriti.joshi@edunest.com'),
    ('Azure Cloud Administration & Infrastructure', 'Configure cloud resources, identity, virtual networks, storage, monitoring, and cost controls for reliable services.', 'Cloud & DevOps', 'Intermediate', 26, 'nabin.shrestha@edunest.com'),
    ('Digital Forensics & Incident Response', 'Practice evidence handling, incident triage, log analysis, recovery planning, and clear security reporting.', 'Cybersecurity', 'Advanced', 22, 'nabin.shrestha@edunest.com'),
    ('Native Android Development with Kotlin', 'Create Android screens, manage app state, consume APIs, persist local data, and test across device configurations.', 'Mobile Development', 'Intermediate', 24, 'asha.rai@edunest.com'),
    ('UX Research & Inclusive Accessibility', 'Plan user interviews, test prototypes, identify accessibility barriers, and turn research findings into design improvements.', 'Product Design', 'Beginner', 16, 'asha.rai@edunest.com'),
    ('Smart Contract Auditing & Web3 Security', 'Review Solidity contracts for access-control, reentrancy, and business-logic risks, then document safe mitigations.', 'Web3 & Blockchain', 'Advanced', 20, 'asha.rai@edunest.com'),
    ('Network Security & Cloud Connectivity', 'Secure network boundaries, configure private cloud connectivity, inspect traffic flows, and troubleshoot access safely.', 'Networking & Infrastructure', 'Intermediate', 22, 'nabin.shrestha@edunest.com')
) AS seed(Title, Description, Category, Level, EstimatedHours, LecturerEmail)
JOIN Users lecturer ON lecturer.Email = seed.LecturerEmail AND lecturer.Role = 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Courses c WHERE c.Title = seed.Title);

-- Every catalog course gets a short, ordered learning path if it has none yet.
INSERT INTO LearningPathTopics (CourseID, Title, Content, SequenceOrder)
SELECT c.CourseID, topic.TopicTitle, topic.TopicContent, topic.SequenceOrder
FROM Courses c
JOIN (VALUES
    ('Web Development', 1, 'Build accessible interfaces', 'Structure pages with semantic markup and responsive layouts. Practice keyboard access, form labels, and clear navigation.'),
    ('Web Development', 2, 'Connect application logic and APIs', 'Separate interface code from server-side rules. Validate input, handle errors, and protect every sensitive operation.'),
    ('Web Development', 3, 'Test and ship a web product', 'Check important user flows, fix accessibility issues, and prepare a reliable release.'),
    ('AI & Machine Learning', 1, 'Understand data, models, and responsible use', 'Review training data, model limits, privacy, and where human judgment is required.'),
    ('AI & Machine Learning', 2, 'Build and evaluate a model feature', 'Prepare representative examples, compare model outputs, and measure quality against a clear baseline.'),
    ('AI & Machine Learning', 3, 'Deploy a reliable AI feature', 'Ground outputs in trusted sources where appropriate, handle failures safely, and monitor real use.'),
    ('Data & Analytics', 1, 'Prepare and model data', 'Check data quality, define relationships, and record assumptions before analysis.'),
    ('Data & Analytics', 2, 'Query, analyze, and visualize', 'Use clear queries and suitable summaries or charts to investigate a practical question.'),
    ('Data & Analytics', 3, 'Communicate data insights', 'Explain findings with context, limitations, and useful next steps for an audience.'),
    ('Cloud & DevOps', 1, 'Design cloud architecture and identity', 'Choose service boundaries and apply least-privilege identity, network, and storage settings.'),
    ('Cloud & DevOps', 2, 'Automate build and delivery', 'Package an application, validate changes automatically, and make deployments repeatable.'),
    ('Cloud & DevOps', 3, 'Monitor, recover, and control costs', 'Use health checks, logs, and alerts; plan recovery and review resource costs.'),
    ('Cybersecurity', 1, 'Model threats and define safe scope', 'Identify assets, likely threats, and authorized boundaries before testing a system.'),
    ('Cybersecurity', 2, 'Protect identities and applications', 'Apply secure configuration, access control, secret handling, and web security basics.'),
    ('Cybersecurity', 3, 'Investigate and respond to incidents', 'Preserve evidence, prioritize containment, document impact, and report findings responsibly.'),
    ('Mobile Development', 1, 'Build screens, navigation, and state', 'Compose clear mobile interfaces and keep navigation and local state predictable.'),
    ('Mobile Development', 2, 'Connect data and handle offline use', 'Load remote data, persist useful local state, and give people clear recovery options.'),
    ('Mobile Development', 3, 'Test accessibility and device behavior', 'Check screen sizes, accessibility settings, performance, and release readiness.'),
    ('Product Design', 1, 'Research user needs', 'Plan interviews or observation, identify user goals, and frame the design problem.'),
    ('Product Design', 2, 'Prototype inclusive workflows', 'Create understandable flows and reusable components with accessible labels and contrast.'),
    ('Product Design', 3, 'Test usability and iterate', 'Observe people using a prototype, record friction, and prioritize improvements.'),
    ('Web3 & Blockchain', 1, 'Understand contracts and transactions', 'Learn how on-chain state, transactions, permissions, and gas affect an application.'),
    ('Web3 & Blockchain', 2, 'Implement and test contract logic', 'Write focused contract functions and test expected behavior and edge cases.'),
    ('Web3 & Blockchain', 3, 'Review risks and connect a dApp', 'Check access controls and common contract risks; present wallet actions clearly.'),
    ('Networking & Infrastructure', 1, 'Trace addressing and packet flow', 'Practice IP addressing, DNS, gateways, and how traffic travels between networks.'),
    ('Networking & Infrastructure', 2, 'Configure routes and troubleshoot', 'Inspect connectivity systematically and isolate routing, name-resolution, or service issues.'),
    ('Networking & Infrastructure', 3, 'Secure network and cloud boundaries', 'Use segmentation, firewall rules, and secure remote links to reduce exposure.')
) AS topic(Category, SequenceOrder, TopicTitle, TopicContent) ON topic.Category = c.Category
WHERE NOT EXISTS (
    SELECT 1 FROM LearningPathTopics existing
    WHERE existing.CourseID = c.CourseID AND existing.SequenceOrder = topic.SequenceOrder
) AND c.Title <> 'Web Application Development';

INSERT INTO LearningPathTopics (CourseID, Title, Content, SequenceOrder)
SELECT c.CourseID, seed.Title, seed.Content, seed.SequenceOrder
FROM (SELECT 'Introduction to HTML5' AS Title, 'Basics of HTML5 structure and semantic elements.' AS Content, 1 AS SequenceOrder
      UNION ALL SELECT 'CSS Styling Fundamentals', 'Internal, external and inline CSS.', 2
      UNION ALL SELECT 'Introduction to ASP.NET Web Forms', 'Server controls and page lifecycle.', 3) seed
JOIN Courses c ON c.Title = 'Web Application Development'
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Email = 'lecturer@edunest.com'
WHERE NOT EXISTS (SELECT 1 FROM LearningPathTopics t WHERE t.CourseID = c.CourseID AND t.Title = seed.Title);

-- Replace starter summaries with real lesson notes and attach one authoritative
-- reading to each. Existing resource links mark lessons maintained by teachers.
DECLARE @LearningResourceSeed TABLE (
    Category VARCHAR(60) NOT NULL,
    SequenceOrder INT NOT NULL,
    TopicTitle VARCHAR(150) NOT NULL,
    LegacyContent NVARCHAR(500) NOT NULL,
    LessonContent NVARCHAR(MAX) NOT NULL,
    ResourceTitle NVARCHAR(200) NOT NULL,
    ResourceUrl NVARCHAR(500) NOT NULL
);
INSERT INTO @LearningResourceSeed VALUES
('Web Development',1,'Build accessible interfaces','Structure pages with semantic markup and responsive layouts. Practice keyboard access, form labels, and clear navigation.',N'LEARNING NOTES
Start with a meaningful document structure. Use headings in order, landmarks such as header, nav, main, and footer, and elements that describe their purpose. Semantic markup gives browsers and assistive technology useful information without extra scripting.

Apply the idea to this course by sketching the page sections before styling them. Add descriptive labels to form controls, useful alternative text to informative images, and visible focus styles. Test the page with a keyboard and narrow viewport.

PRACTICE
Create a one-page outline for the course project. Check that every section has a heading and that each control can be reached and understood without a mouse.','MDN: HTML structure and semantics','https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content'),
('Web Development',2,'Style responsive pages and connect interactions','Separate interface code from server-side rules. Validate input, handle errors, and protect every sensitive operation.',N'LEARNING NOTES
Keep content, presentation, and behavior understandable. CSS controls layout, spacing, color, and responsive changes; JavaScript or server code handles user actions and data. Reusable classes and components reduce duplication, while clear names make later changes safer.

For this course, build a small screen first, then add breakpoints only when the content needs them. Forms should explain errors beside the related field. Send data to the server for validation and permission checks; browser checks improve convenience but cannot enforce security.

PRACTICE
Style the outline from Lesson 1 for mobile and desktop. Add one validated form and write down which rules must be checked again on the server.','MDN: CSS styling basics','https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics'),
('Web Development',3,'Build, test, and ship a web feature','Check important user flows, fix accessibility issues, and prepare a reliable release.',N'LEARNING NOTES
Turn a feature into a sequence: gather input, validate it, apply application rules, save or retrieve data, and show a clear result. In Web Forms, controls post values to server events; the page lifecycle determines when state is restored and handlers run.

Before release, test the complete path, including invalid input, missing records, and users with the wrong role. Keep database commands parameterized. A useful error message helps the learner recover while technical details stay in server logs.

PRACTICE
Trace one feature from its page control to its SQL command and back to the result message. Test both a valid submission and a rejected one.','Microsoft Learn: What is ASP.NET Web Forms?','https://learn.microsoft.com/en-us/aspnet/web-forms/what-is-web-forms'),
('AI & Machine Learning',1,'Prepare data and frame an AI task','Review training data, model limits, privacy, and where human judgment is required.',N'LEARNING NOTES
Start with the decision the system should support. Define the expected input, output, and failure cases before choosing a model. Inspect data for missing values, duplicates, bias, sensitive information, and whether the examples reflect real use.

For this course, write a small dataset card: where examples came from, who may be underrepresented, what must not be sent to a hosted service, and how a person will review uncertain output. Separate a model prediction from a confirmed fact.

PRACTICE
Create five representative examples and three edge cases. For each one, record what a safe and useful response should look like.','Microsoft Learn: Responsible AI for generative models','https://learn.microsoft.com/en-us/azure/foundry/responsible-ai/openai/overview'),
('AI & Machine Learning',2,'Build prompts and ground answers in sources','Prepare representative examples, compare model outputs, and measure quality against a clear baseline.',N'LEARNING NOTES
An instruction should state the task, audience, constraints, and output format. For knowledge questions, retrieve relevant trusted passages first and ask the model to answer from that evidence. Show citations or source names so a reader can verify important claims.

Retrieval quality and answer quality are separate. A correct model cannot use a document it never retrieved. Inspect retrieved passages, remove irrelevant chunks, and test questions that have no answer in the collection. In that case, the system should say it does not know.

PRACTICE
Write three questions over a short set of course notes. Check the retrieved text and compare the final answer with the source before accepting it.','Microsoft Learn: Evaluate retrieval-augmented generation','https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/rag-evaluators'),
('AI & Machine Learning',3,'Evaluate safety and monitor model quality','Use health checks, logs, and alerts; plan recovery and review resource costs.',N'LEARNING NOTES
Evaluate an AI feature with a fixed set of realistic examples before changing prompts or models. Track task success, factual grounding, harmful output, latency, and cost. Compare results with a baseline and inspect failures, not only the average score.

After release, monitor drift, feedback, and unusual failures while minimizing stored personal data. Provide a fallback path when a service is unavailable or confidence is low. Keep a human review step for high-impact decisions and make it clear when content is generated.

PRACTICE
Build a small evaluation table with expected answers, safety checks, and pass criteria. Run it after each change and investigate every regression.','Microsoft Learn: Generative AI evaluation and observability','https://learn.microsoft.com/en-us/azure/foundry/concepts/observability'),
('Data & Analytics',1,'Model and prepare reliable data','Check data quality, define relationships, and record assumptions before analysis.',N'LEARNING NOTES
Begin by identifying what one row represents. Choose keys that identify records, separate facts from descriptive attributes, and define how tables relate. Consistent types and constraints prevent dates, identifiers, and numeric values from silently mixing.

Before analysis, profile missing values, duplicates, ranges, and category spelling. Record every cleaning rule so another analyst can reproduce it. For tabular Python work, a DataFrame gives labeled columns that can be selected, combined, summarized, and checked.

PRACTICE
Take a small dataset and write down its row meaning, primary key, expected relationships, and three quality checks before calculating anything.','pandas: Getting started tutorials','https://pandas.pydata.org/docs/getting_started/intro_tutorials/index.html'),
('Data & Analytics',2,'Query, transform, and visualize information','Use clear queries and suitable summaries or charts to investigate a practical question.',N'LEARNING NOTES
Turn a question into a query plan: select the needed fields, filter the correct rows, join related records using keys, then aggregate at the level the question asks about. Verify row counts after joins so duplicate relationships do not inflate totals.

Choose a chart that fits the comparison: bars for categories, lines for change over time, and scatter plots for relationships. Label units, date ranges, and filters. A chart should make the evidence easier to inspect rather than hide uncertainty behind decoration.

PRACTICE
Write a question about your dataset, calculate the answer with SQL or pandas, then create one labeled chart and explain its main limitation.','Microsoft Learn: Get started with Power BI','https://learn.microsoft.com/en-us/power-bi/fundamentals/'),
('Data & Analytics',3,'Evaluate findings and explain their limits','Explain findings with context, limitations, and useful next steps for an audience.',N'LEARNING NOTES
Separate what the data directly shows from what you infer. Compare groups with appropriate denominators, check whether the sample covers the population, and avoid treating correlation as proof of cause. State uncertainty and note missing or delayed data.

For predictive work, keep training and test data separate. Compare a simple baseline with the model and select metrics that match the cost of different errors. Communicate the result in plain language, including who should act and what extra evidence could change the conclusion.

PRACTICE
Write a short report with one result, its denominator, one limitation, and one recommended next check.','scikit-learn: Model evaluation guide','https://scikit-learn.org/stable/modules/model_evaluation.html'),
('Cloud & DevOps',1,'Design cloud systems for security and reliability','Choose service boundaries and apply least-privilege identity, network, and storage settings.',N'LEARNING NOTES
Map the system before creating resources. Identify entry points, data stores, dependencies, and failure boundaries. Give each service only the permissions it needs, keep credentials out of code, and choose network exposure deliberately.

Reliability begins with explicit expectations: what must remain available, how much data loss is acceptable, and how the service recovers. Use managed backups, health checks, and documented ownership. Compare architecture decisions against security, reliability, performance, and cost needs.

PRACTICE
Draw a simple deployment diagram for this course project. Mark public entry points, private services, secrets, backups, and one likely failure.','AWS: Well-Architected Framework','https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html'),
('Cloud & DevOps',2,'Package software and automate delivery','Package an application, validate changes automatically, and make deployments repeatable.',N'LEARNING NOTES
An image packages an application and its runtime dependencies; a running container is an isolated process created from that image. Keep configuration and secrets outside the image. Use small, reproducible build steps so another machine can create the same artifact.

In a delivery pipeline, restore dependencies, compile, run checks, and publish a versioned artifact. Deploy the same artifact through environments instead of rebuilding it by hand. A rollback plan should identify the last known-good version and the data changes that need special care.

PRACTICE
Write down the build, test, and deploy steps for one service. Identify which step should stop a release when it fails.','Docker: Get started','https://docs.docker.com/get-started/'),
('Cloud & DevOps',3,'Operate services with observability and cost controls','Use health checks, logs, and alerts; plan recovery and review resource costs.',N'LEARNING NOTES
Logs describe events, metrics summarize measurements over time, and traces connect work across service boundaries. Use request identifiers to follow a transaction without exposing secrets or unnecessary personal data. Alert on user-visible symptoms such as error rate and latency.

Practice recovery, not just backup creation: restore a copy and measure the time required. Track resource usage and set budgets so unused capacity and unexpected growth are visible. After an incident, record contributing conditions and concrete prevention work.

PRACTICE
Choose two service health metrics, one alert threshold, and a recovery exercise. Explain who responds and how the service is verified afterward.','AWS: Reliability pillar','https://docs.aws.amazon.com/wellarchitected/latest/framework/reliability.html'),
('Cybersecurity',1,'Model threats and define authorized scope','Identify assets, likely threats, and authorized boundaries before testing a system.',N'LEARNING NOTES
Threat modeling makes security assumptions visible. List valuable data and actions, identify who might misuse them, and map where trust changes as requests move through browsers, servers, and databases. Rank threats by likelihood and impact so the team can address the most important risks first.

Security testing must have clear written authorization, targets, timing, and limits. Use a safe test environment and synthetic data. Never scan or exploit systems outside the agreed scope.

PRACTICE
Draw the data flow for one feature, mark each trust boundary, and write one threat plus one mitigation for every boundary.','OWASP Top 10: Web application risks','https://top10.owasp.org/2025/'),
('Cybersecurity',2,'Protect identities, applications, and sensitive data','Apply secure configuration, access control, secret handling, and web security basics.',N'LEARNING NOTES
Authentication answers who is signed in; authorization checks whether that identity may perform this action on this record. Enforce both on the server for every protected request. Use least privilege, multi-factor authentication where available, and short-lived credentials.

Treat user input and third-party output as untrusted. Parameterize database commands, encode displayed text, validate uploads, and keep secrets in a secret store. Apply updates and secure defaults, and avoid returning stack traces or private data to users.

PRACTICE
Review a form submission from browser to database. Mark every input check, authorization check, parameterized query, and safe output encoding point.','OWASP Top 10: Web application risks','https://top10.owasp.org/2025/'),
('Cybersecurity',3,'Respond to incidents and improve defenses','Preserve evidence, prioritize containment, document impact, and report findings responsibly.',N'LEARNING NOTES
An incident process should tell responders how to identify, contain, investigate, recover, and communicate. Preserve relevant logs and timestamps before making changes that could destroy evidence. Record actions and decisions so another responder can reconstruct what happened.

Containment reduces ongoing harm, but should be balanced against preserving evidence and maintaining essential services. After recovery, identify the root conditions, rotate exposed credentials, verify fixes, and update monitoring and response procedures.

PRACTICE
Draft a one-page response checklist for a compromised account: who is notified, what evidence is preserved, how access is contained, and how recovery is confirmed.','OWASP: Web security guidance','https://owasp.org/www-project-top-ten/'),
('Mobile Development',1,'Build mobile screens, navigation, and state','Compose clear mobile interfaces and keep navigation and local state predictable.',N'LEARNING NOTES
Mobile interfaces have limited space and different input methods. Group related actions, make touch targets easy to use, and design layouts that adapt to small and large displays. Keep screen state separate from long-lived data so navigation and refreshes behave predictably.

In Flutter, compose screens from widgets; in native Android, organize UI around activities or modern Compose screens. In either approach, give each screen one clear purpose and make loading, empty, and error states visible.

PRACTICE
Sketch a three-screen flow for the course app. Label the primary action on each screen and show how a learner returns or recovers from an error.','Flutter documentation','https://docs.flutter.dev/'),
('Mobile Development',2,'Connect mobile apps to services and local data','Load remote data, persist useful local state, and give people clear recovery options.',N'LEARNING NOTES
Network requests can be slow, interrupted, or rejected. Show progress while waiting, explain failures, and offer a safe retry. Validate server responses before using them and avoid assuming the device is always online.

Store only the local information the feature needs. Protect sensitive values with platform storage, provide clear synchronization rules, and handle duplicate requests safely. Separate API, storage, and screen responsibilities so each can be changed and checked independently.

PRACTICE
Describe the screen shown when a request succeeds, is still loading, fails, or returns no items. Decide which state can be safely cached offline.','Android Developers: App architecture','https://developer.android.com/topic/architecture'),
('Mobile Development',3,'Test accessibility and behavior across devices','Check screen sizes, accessibility settings, performance, and release readiness.',N'LEARNING NOTES
Test with different display sizes, text scaling, keyboard or switch navigation, and screen readers. Do not rely on color alone to communicate status. Controls need meaningful labels and focus order, while important actions should remain usable when text grows.

Use unit tests for rules, widget or UI tests for screen behavior, and device testing for integrations such as camera or network access. Check crash reports and performance on realistic devices before a release.

PRACTICE
Run a test pass with large text and a screen reader. Record one issue, how to reproduce it, and the change that would resolve it.','Android Developers: Accessibility','https://developer.android.com/guide/topics/ui/accessibility'),
('Product Design',1,'Research user needs and frame the problem','Plan interviews or observation, identify user goals, and frame the design problem.',N'LEARNING NOTES
Start by learning what people are trying to do, what blocks them, and what context shapes their choices. Ask open questions and observe real tasks instead of asking participants to approve a proposed solution. Separate direct evidence from assumptions made by the team.

Group repeated observations into needs and write a problem statement that names the audience, goal, and obstacle. Use that statement to judge whether a design idea addresses the actual problem.

PRACTICE
Write five neutral interview questions for a learner using this course product. Summarize one likely need without proposing a feature yet.','Figma: What is UX design?','https://www.figma.com/resource-library/what-is-ux-design/'),
('Product Design',2,'Map flows and prototype inclusive interfaces','Create understandable flows and reusable components with accessible labels and contrast.',N'LEARNING NOTES
Information architecture groups content so people can predict where to find it. A user flow shows the steps and decisions required to complete a task. Sketch the simplest successful path and include empty, error, and recovery states before polishing the screen.

Use components and shared styles to keep repeated interface patterns consistent. Build a low-fidelity prototype first, then add detail where a test needs it. Check contrast, keyboard access, readable labels, and whether meaning remains clear without color.

PRACTICE
Map the path to enroll in a course. Prototype the happy path plus one error state and ask another person to try it.','W3C WAI: Accessibility principles','https://www.w3.org/WAI/fundamentals/accessibility-principles/'),
('Product Design',3,'Test usability and iterate from evidence','Observe people using a prototype, record friction, and prioritize improvements.',N'LEARNING NOTES
Give a participant a realistic goal and let them try the prototype without coaching. Observe where they hesitate, what they expect, and whether they can recover. Ask what they thought was happening instead of asking whether they liked the design.

Sort findings by impact and frequency. Fix blockers before visual refinements, then test again. Keep a short decision log connecting each change to observed evidence so the design does not drift toward the loudest opinion.

PRACTICE
Run a five-minute task test with one learner. Record the task, observed friction, likely cause, and one change you will test next.','Figma: What is prototyping?','https://www.figma.com/resource-library/what-is-prototyping/'),
('Web3 & Blockchain',1,'Understand blockchain state and transactions','Learn how on-chain state, transactions, permissions, and gas affect an application.',N'LEARNING NOTES
A blockchain is a replicated ledger maintained by a network. A transaction proposes a state change; users sign it, nodes execute or verify it, and the network records the result. Public visibility, fees, and confirmation delays affect the user experience.

Separate data that must be trustlessly shared from ordinary application data. A contract cannot safely assume that private information stays hidden on a public chain. Explain transaction effects and expected costs before asking a user to approve them.

PRACTICE
Draw the steps from a user action to a confirmed transaction. Mark which data is public, who pays a fee, and what happens if the transaction fails.','Ethereum.org: Smart contracts','https://ethereum.org/developers/docs/smart-contracts/'),
('Web3 & Blockchain',2,'Write and test smart contract logic','Write focused contract functions and test expected behavior and edge cases.',N'LEARNING NOTES
Smart contracts store state and expose functions that can change it. Define who may call each function, what conditions must hold, and how balances or ownership change. Prefer clear invariants that can be checked before and after every operation.

Write automated tests for normal use, invalid callers, boundary values, and repeated calls. Simulate failures and verify state remains consistent. Test on a local development chain before any public deployment; deployed code can be difficult or impossible to replace.

PRACTICE
Write a small contract outline with one state variable, one permission rule, and three tests: valid action, unauthorized action, and an edge case.','Solidity documentation','https://docs.soliditylang.org/en/latest/'),
('Web3 & Blockchain',3,'Review contract security and dApp behavior','Check access controls and common contract risks; present wallet actions clearly.',N'LEARNING NOTES
Review permissions, external calls, arithmetic assumptions, and the order in which state changes happen. Reentrancy can occur when a contract calls out before its own state is safely updated. Limit trust in external data and document administrator powers.

On the application side, show the network, requested action, and likely fee before wallet approval. Never ask users to reveal private keys or seed phrases. Treat a reverted or pending transaction as a distinct state and let users verify it safely.

PRACTICE
Review a sample contract for an unauthorized state change and an unsafe external call. Then sketch the confirmation screen for one transaction.','Ethereum.org: Smart contract security','https://ethereum.org/en/developers/docs/smart-contracts/security/'),
('Networking & Infrastructure',1,'Trace network addressing and packet flow','Practice IP addressing, DNS, gateways, and how traffic travels between networks.',N'LEARNING NOTES
An IP address identifies an interface on a network. A subnet groups addresses that can communicate locally, while a default gateway forwards traffic beyond that subnet. DNS maps human-readable names to addresses; ports identify services on a host.

When a connection fails, check in layers: local link, assigned address, gateway reachability, name resolution, and application service. Change one variable at a time and keep notes so the diagnosis can be repeated.

PRACTICE
Trace what happens when a browser opens a domain. Label the DNS lookup, destination IP, gateway, transport port, and the first application response.','Microsoft Learn: Fundamentals of computer networking','https://learn.microsoft.com/en-us/training/modules/network-fundamentals'),
('Networking & Infrastructure',2,'Configure routes and troubleshoot connectivity','Inspect connectivity systematically and isolate routing, name-resolution, or service issues.',N'LEARNING NOTES
Routing chooses the next hop for traffic based on destination prefixes. A route table, subnet boundary, firewall rule, and DNS configuration can each change whether a service is reachable. In cloud networks, virtual networks and subnets create isolation boundaries for related resources.

Use a repeatable sequence of checks and collect evidence before changing settings. Compare a working path with a failing path, confirm address ranges do not overlap, and verify that return traffic is allowed as well as outbound traffic.

PRACTICE
Draw two subnets and a gateway route. Predict which destinations are reachable, then list the commands or console checks you would use to validate each prediction.','Microsoft Learn: Azure virtual networks and subnets','https://learn.microsoft.com/en-us/azure/networking/design-guide/vnets-subnets'),
('Networking & Infrastructure',3,'Secure network boundaries and remote access','Use segmentation, firewall rules, and secure remote links to reduce exposure.',N'LEARNING NOTES
Network segmentation limits which systems can communicate and reduces how far an intruder can move. Permit only required source, destination, protocol, and port combinations. Log meaningful policy decisions and review rules that no longer have an owner or purpose.

Remote connections should authenticate users and devices, protect traffic in transit, and avoid exposing management services to the whole internet. Combine network controls with identity checks; being on a private network does not automatically make a request trustworthy.

PRACTICE
Create a small access matrix for a web app, database, and administrator workstation. Allow only the flows each role requires and explain one denied flow.','Microsoft Learn: Azure Virtual Network documentation','https://learn.microsoft.com/en-us/azure/virtual-network/');

INSERT INTO @LearningResourceSeed VALUES
('Technology',1,'Relational data and database design','Learn how relational tables represent people, things, and the relationships between them.',N'LEARNING NOTES
A relational database stores facts in tables. Each table represents one kind of thing, each row is one record, and each column stores one attribute. A primary key identifies a row. A foreign key links a row to a related row and lets the database enforce valid relationships.

Start from the information your application must keep. Separate different entities into their own tables, identify stable keys, and describe one-to-many or many-to-many relationships before writing queries. Normalization helps prevent the same fact from being copied and updated inconsistently.

PRACTICE
Sketch Users, Courses, and Enrollments tables for a learning platform. Mark the primary key in each and show how an enrollment connects one student to one course.','Microsoft Learn: Database tables and relationships','https://learn.microsoft.com/en-us/sql/relational-databases/tables/tables?view=sql-server-ver17'),
('Technology',2,'Write queries to retrieve and combine data','Use SELECT, filters, sorting, and joins to answer questions from related tables.',N'LEARNING NOTES
SQL retrieves information from relational tables. SELECT names the columns, FROM identifies the source, WHERE filters rows, and ORDER BY makes the result predictable. A join combines rows using a relationship such as a foreign key.

Be deliberate about which rows a query should include. Use parameters for values supplied by a user, qualify columns when tables share a name, and test joins on small examples so accidental duplicate rows are visible. Aggregate functions such as COUNT and AVG summarize a set of records.

PRACTICE
Write a query that lists each course title and its enrolled student count. Include courses with zero enrollments by using an outer join, then sort by title.','Microsoft Learn: SELECT queries in Transact-SQL','https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql?view=sql-server-ver17'),
('Technology',3,'Protect data with constraints and transactions','Use database rules and transactions to keep related changes valid and consistent.',N'LEARNING NOTES
Constraints make invalid data harder to store. NOT NULL requires a value, UNIQUE prevents duplicates, CHECK enforces a rule, and foreign keys keep references connected to existing rows. Choose constraints from the real rules of the domain rather than relying only on page validation.

A transaction groups changes so they succeed together or are rolled back together. This matters when one user action updates several related records. Indexes can speed up common lookups, but they also add storage and make writes more expensive, so measure before adding them.

PRACTICE
Define a uniqueness rule that prevents the same student enrolling in one course twice. Describe which two-column index could support a course enrollment lookup and what write cost it adds.','Microsoft Learn: Primary and foreign key constraints','https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints?view=sql-server-ver17');

INSERT INTO dbo.LearningPathTopics (CourseID, Title, Content, SequenceOrder)
SELECT c.CourseID, seed.TopicTitle, seed.LegacyContent, seed.SequenceOrder
FROM dbo.Courses c
JOIN @LearningResourceSeed seed ON seed.Category = c.Category
WHERE c.Title = 'Database Systems'
  AND NOT EXISTS (SELECT 1 FROM dbo.LearningPathTopics t WHERE t.CourseID = c.CourseID AND t.SequenceOrder = seed.SequenceOrder);

UPDATE t
SET t.Title = seed.TopicTitle,
    t.Content = seed.LessonContent,
    t.ResourceTitle = seed.ResourceTitle,
    t.ResourceUrl = seed.ResourceUrl
FROM dbo.LearningPathTopics t
JOIN dbo.Courses c ON c.CourseID = t.CourseID
JOIN @LearningResourceSeed seed ON seed.Category = c.Category AND seed.SequenceOrder = t.SequenceOrder
WHERE t.ResourceUrl IS NULL AND t.SequenceOrder BETWEEN 1 AND 3
  AND c.Title <> 'Web Application Development';

UPDATE t
SET t.Title = seed.TopicTitle,
    t.Content = seed.LessonContent,
    t.ResourceTitle = seed.ResourceTitle,
    t.ResourceUrl = seed.ResourceUrl
FROM dbo.LearningPathTopics t
JOIN dbo.Courses c ON c.CourseID = t.CourseID
JOIN @LearningResourceSeed seed ON seed.Category = 'Web Development' AND seed.SequenceOrder = t.SequenceOrder
WHERE c.Title = 'Web Application Development'
  AND t.ResourceUrl IS NULL AND t.SequenceOrder BETWEEN 1 AND 3
  AND ((t.SequenceOrder = 1 AND t.Content = 'Basics of HTML5 structure and semantic elements.')
    OR (t.SequenceOrder = 2 AND t.Content = 'Internal, external and inline CSS.')
    OR (t.SequenceOrder = 3 AND t.Content = 'Server controls and page lifecycle.'));

-- Specialize shared resources for the actual stack used by selected courses.
UPDATE t SET ResourceTitle = 'Flutter documentation', ResourceUrl = 'https://docs.flutter.dev/'
FROM dbo.LearningPathTopics t JOIN dbo.Courses c ON c.CourseID = t.CourseID
WHERE c.Title LIKE '%Flutter%' AND t.ResourceUrl LIKE 'https://developer.android.com/%';
UPDATE t SET ResourceTitle = 'Android Basics with Compose', ResourceUrl = 'https://developer.android.com/courses/android-basics-compose/course'
FROM dbo.LearningPathTopics t JOIN dbo.Courses c ON c.CourseID = t.CourseID
WHERE (c.Title LIKE '%Android%' OR c.Title LIKE '%Kotlin%') AND t.ResourceUrl LIKE 'https://docs.flutter.dev/%';
UPDATE t SET ResourceTitle = 'Microsoft Learn: Azure networking', ResourceUrl = 'https://learn.microsoft.com/en-us/azure/virtual-network/'
FROM dbo.LearningPathTopics t JOIN dbo.Courses c ON c.CourseID = t.CourseID
WHERE c.Title LIKE '%Azure%' AND t.ResourceUrl LIKE 'https://docs.aws.amazon.com/%';
GO

INSERT INTO Enrollments (CourseID, StudentID)
SELECT c.CourseID, student.UserID FROM Courses c
JOIN Users student ON student.Email = 'student@edunest.com'
WHERE c.Title = 'Web Application Development'
  AND NOT EXISTS (SELECT 1 FROM Enrollments e WHERE e.CourseID = c.CourseID AND e.StudentID = student.UserID);

INSERT INTO Quizzes (CourseID, Title)
SELECT c.CourseID, 'HTML & CSS Basics Quiz' FROM Courses c
WHERE c.Title = 'Web Application Development'
  AND NOT EXISTS (SELECT 1 FROM Quizzes q WHERE q.CourseID = c.CourseID AND q.Title = 'HTML & CSS Basics Quiz');

INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption)
SELECT q.QuizID, seed.QuestionText, seed.OptionA, seed.OptionB, seed.OptionC, seed.OptionD, seed.CorrectOption
FROM (SELECT 'Which tag is used to define an internal style sheet?' AS QuestionText, '<css>' AS OptionA, '<script>' AS OptionB, '<style>' AS OptionC, '<link>' AS OptionD, 'C' AS CorrectOption
      UNION ALL SELECT 'Which attribute is used to link an external CSS file?', 'src', 'href', 'link', 'rel', 'B') seed
JOIN Quizzes q ON q.Title = 'HTML & CSS Basics Quiz'
JOIN Courses c ON c.CourseID = q.CourseID AND c.Title = 'Web Application Development'
WHERE NOT EXISTS (SELECT 1 FROM QuizQuestions qq WHERE qq.QuizID = q.QuizID AND qq.QuestionText = seed.QuestionText);

-- Give every course an enrolled-student-accessible knowledge check. Courses
-- that already have a quiz keep those quizzes and also receive this baseline.
INSERT INTO Quizzes (CourseID, Title)
SELECT c.CourseID, 'Course Knowledge Check'
FROM Courses c
WHERE NOT EXISTS (SELECT 1 FROM Quizzes q WHERE q.CourseID = c.CourseID AND q.Title = 'Course Knowledge Check');

INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption)
SELECT q.QuizID, bank.QuestionText, bank.OptionA, bank.OptionB, bank.OptionC, bank.OptionD, bank.CorrectOption
FROM Courses c
JOIN Quizzes q ON q.CourseID = c.CourseID AND q.Title = 'Course Knowledge Check'
JOIN (VALUES
    ('Web Development', 'Which markup practice improves page structure and accessibility?', 'Semantic HTML elements', 'Unlabeled controls', 'Layout made only with images', 'Removing headings', 'A'),
    ('Web Development', 'Where should authorization for protected actions be enforced?', 'Only in client-side code', 'On the server for each request', 'In a CSS rule', 'In a page title', 'B'),
    ('Web Development', 'What is a key benefit of automated application tests?', 'They replace input validation', 'They guarantee no bugs forever', 'They catch regressions in important flows', 'They remove the need for review', 'C'),
    ('AI & Machine Learning', 'What does retrieval-augmented generation use to ground responses?', 'Retrieved trusted source material', 'A larger screen resolution', 'A CSS stylesheet', 'A database identity column', 'A'),
    ('AI & Machine Learning', 'How should model quality be evaluated?', 'Only by inspecting one favorable example', 'Against representative cases and a defined baseline', 'By hiding uncertain results', 'Without checking the output', 'B'),
    ('AI & Machine Learning', 'How should an application handle sensitive input sent to an AI service?', 'Send all data without review', 'Store it in a public log', 'Minimize and protect it according to policy', 'Use it as an authorization rule', 'C'),
    ('Data & Analytics', 'What is the purpose of a relational primary key?', 'Uniquely identify each row', 'Choose a chart color', 'Compress an image', 'Start a web server', 'A'),
    ('Data & Analytics', 'What is a common tradeoff of adding an index?', 'It removes the need for backups', 'It can speed reads but add storage and write cost', 'It encrypts all columns', 'It automatically fixes incorrect data', 'B'),
    ('Data & Analytics', 'What makes a chart easier to interpret?', 'Omitting units', 'Using decorative effects instead of labels', 'Clear labels and context for the data', 'Hiding the source', 'C'),
    ('Cloud & DevOps', 'What does least-privilege cloud access mean?', 'Grant only the permissions needed for a task', 'Share one administrator account', 'Make every resource public', 'Put credentials in source code', 'A'),
    ('Cloud & DevOps', 'What is a container image used for?', 'A packaged application environment', 'A network password', 'A database query result', 'A chart legend', 'B'),
    ('Cloud & DevOps', 'Which practice helps detect service health problems?', 'Disable all logs', 'Ignore failed requests', 'Use health checks, metrics, and alerts', 'Remove recovery plans', 'C'),
    ('Cybersecurity', 'What is a useful first step in threat modeling?', 'Identify assets and possible threats', 'Publish access credentials', 'Disable authentication', 'Test systems without permission', 'A'),
    ('Cybersecurity', 'What does multi-factor authentication add?', 'A second page layout', 'An independent verification factor', 'A database index', 'A public network route', 'B'),
    ('Cybersecurity', 'What is an appropriate incident response practice?', 'Delete relevant logs immediately', 'Share evidence publicly', 'Preserve evidence and follow the response process', 'Ignore affected users', 'C'),
    ('Mobile Development', 'How should a mobile app respond when a network request fails?', 'Show a useful recovery state', 'Freeze without explanation', 'Expose a stack trace to everyone', 'Delete user data', 'A'),
    ('Mobile Development', 'Which feature supports accessible mobile navigation?', 'Tiny unlabeled controls', 'Clear labels and screen-reader semantics', 'Color as the only signal', 'Hidden focus state', 'B'),
    ('Mobile Development', 'Why test a mobile app on different screen sizes?', 'To remove all offline behavior', 'To skip accessibility checks', 'To catch layout and device-specific problems', 'To avoid release checks', 'C'),
    ('Product Design', 'What is user research used for?', 'Understand user needs and context', 'Choose a database password', 'Replace product testing', 'Hide design assumptions', 'A'),
    ('Product Design', 'Which design choice helps keyboard users?', 'Remove focus indicators', 'Keep controls labeled and operable by keyboard', 'Use color alone for meaning', 'Disable tab navigation', 'B'),
    ('Product Design', 'What should a designer do after usability testing?', 'Ignore observed friction', 'Keep every first draft unchanged', 'Use findings to prioritize improvements', 'Remove the user flow', 'C'),
    ('Web3 & Blockchain', 'What is a smart contract?', 'Program logic deployed to a blockchain', 'A private browser cookie', 'A CSS component', 'A spreadsheet formula', 'A'),
    ('Web3 & Blockchain', 'Why is access control important in a smart contract?', 'It improves image loading', 'It limits who can call sensitive functions', 'It hides public transactions', 'It guarantees zero transaction cost', 'B'),
    ('Web3 & Blockchain', 'What is a reentrancy risk?', 'Repeated external calls before state is safely updated', 'A missing image alt attribute', 'A slow CSS animation', 'A network DNS lookup', 'C'),
    ('Networking & Infrastructure', 'Which service resolves a domain name to an IP address?', 'DNS', 'DHCP', 'NTP', 'SMTP', 'A'),
    ('Networking & Infrastructure', 'What does a default gateway normally do?', 'Assign a course grade', 'Forward traffic to another network', 'Store a web image', 'Create a database table', 'B'),
    ('Networking & Infrastructure', 'Why segment a network?', 'To remove all monitoring', 'To make every device publicly reachable', 'To limit exposure and lateral movement', 'To disable routing everywhere', 'C')
) AS bank(Category, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption)
    ON bank.Category = c.Category
WHERE NOT EXISTS (
    SELECT 1 FROM QuizQuestions existing
    WHERE existing.QuizID = q.QuizID AND existing.QuestionText = bank.QuestionText
);

INSERT INTO Assignments (CourseID, Title, Description, DueDate)
SELECT c.CourseID, 'Build a Personal Portfolio Page', 'Create a single HTML/CSS page showcasing your work.', '2026-12-15'
FROM Courses c WHERE c.Title = 'Web Application Development'
  AND NOT EXISTS (SELECT 1 FROM Assignments a WHERE a.CourseID = c.CourseID AND a.Title = 'Build a Personal Portfolio Page');

INSERT INTO StudySessions (CreatedBy, Title, SessionDate, SessionTime, Description)
SELECT student.UserID, 'WAPP Group Revision', '2026-12-01', '18:00:00', 'Revising CSS layout techniques before the quiz.'
FROM Users student WHERE student.Email = 'student@edunest.com'
  AND NOT EXISTS (SELECT 1 FROM StudySessions s WHERE s.CreatedBy = student.UserID AND s.Title = 'WAPP Group Revision');

-- Verification: this result should be empty. If names appear, review any SQL
-- errors above before running the website.
SELECT expected.TableName AS MissingTable
FROM (VALUES ('Users'), ('Courses'), ('LearningPathTopics'), ('Enrollments'), ('CourseFeedback'),
             ('TopicProgress'), ('Quizzes'), ('QuizQuestions'), ('QuizAttempts'),
             ('Assignments'), ('AssignmentSubmissions'), ('PeerReviews'),
             ('StudySessions'), ('StudySessionParticipants')) AS expected(TableName)
WHERE OBJECT_ID(N'dbo.' + expected.TableName, N'U') IS NULL;

