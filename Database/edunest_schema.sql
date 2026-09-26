-- =========================================================
-- EduNest - A Smart Campus Learning Hub
-- Database Schema and idempotent demo seed (MySQL 8.0+)
-- Safe to run repeatedly: this script never drops databases or tables.
-- =========================================================
CREATE DATABASE IF NOT EXISTS edunest_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
USE edunest_db;

CREATE TABLE IF NOT EXISTS Users (
    UserID          INT AUTO_INCREMENT PRIMARY KEY,
    FullName        VARCHAR(100)  NOT NULL,
    Email           VARCHAR(150)  NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255)  NOT NULL,
    PasswordSalt    VARCHAR(100)  NOT NULL,
    Role            ENUM('Student','Lecturer','Admin') NOT NULL DEFAULT 'Student',
    IsActive        TINYINT(1)    NOT NULL DEFAULT 1,
    CreatedDate     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Courses (
    CourseID        INT AUTO_INCREMENT PRIMARY KEY,
    Title           VARCHAR(150)  NOT NULL,
    Description     TEXT,
    Category        VARCHAR(60)   NOT NULL DEFAULT 'Technology',
    Level           ENUM('Beginner','Intermediate','Advanced') NOT NULL DEFAULT 'Beginner',
    EstimatedHours  SMALLINT UNSIGNED NOT NULL DEFAULT 8,
    LecturerID      INT           NOT NULL,
    CreatedDate     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_course_estimated_hours CHECK (EstimatedHours >= 1),
    KEY idx_courses_catalog (Category, Level),
    CONSTRAINT fk_course_lecturer FOREIGN KEY (LecturerID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS LearningPathTopics (
    TopicID         INT AUTO_INCREMENT PRIMARY KEY,
    CourseID        INT           NOT NULL,
    Title           VARCHAR(150)  NOT NULL,
    Content         TEXT,
    SequenceOrder   INT           NOT NULL DEFAULT 1,
    CONSTRAINT chk_topic_sequence CHECK (SequenceOrder >= 1),
    CONSTRAINT fk_topic_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Enrollments (
    EnrollmentID    INT AUTO_INCREMENT PRIMARY KEY,
    CourseID        INT NOT NULL,
    StudentID       INT NOT NULL,
    EnrolledDate    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_enroll_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE,
    CONSTRAINT fk_enroll_student FOREIGN KEY (StudentID) REFERENCES Users(UserID) ON DELETE CASCADE,
    UNIQUE KEY uq_enrollment (CourseID, StudentID)
);

CREATE TABLE IF NOT EXISTS TopicProgress (
    ProgressID      INT AUTO_INCREMENT PRIMARY KEY,
    TopicID         INT NOT NULL,
    StudentID       INT NOT NULL,
    CompletedDate   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_progress_topic FOREIGN KEY (TopicID) REFERENCES LearningPathTopics(TopicID) ON DELETE CASCADE,
    CONSTRAINT fk_progress_student FOREIGN KEY (StudentID) REFERENCES Users(UserID) ON DELETE CASCADE,
    UNIQUE KEY uq_progress (TopicID, StudentID)
);

CREATE TABLE IF NOT EXISTS Quizzes (
    QuizID          INT AUTO_INCREMENT PRIMARY KEY,
    CourseID        INT NOT NULL,
    Title           VARCHAR(150) NOT NULL,
    CONSTRAINT fk_quiz_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS QuizQuestions (
    QuestionID      INT AUTO_INCREMENT PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS QuizAttempts (
    AttemptID       INT AUTO_INCREMENT PRIMARY KEY,
    QuizID          INT NOT NULL,
    StudentID       INT NOT NULL,
    Score           INT NOT NULL,
    TotalQuestions  INT NOT NULL,
    CONSTRAINT chk_quiz_attempt_score CHECK (Score >= 0 AND TotalQuestions >= 1 AND Score <= TotalQuestions),
    AttemptDate     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attempt_quiz FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID) ON DELETE CASCADE,
    CONSTRAINT fk_attempt_student FOREIGN KEY (StudentID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Assignments (
    AssignmentID    INT AUTO_INCREMENT PRIMARY KEY,
    CourseID        INT NOT NULL,
    Title           VARCHAR(150) NOT NULL,
    Description     TEXT,
    DueDate         DATE NOT NULL,
    CONSTRAINT fk_assignment_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS AssignmentSubmissions (
    SubmissionID    INT AUTO_INCREMENT PRIMARY KEY,
    AssignmentID    INT NOT NULL,
    StudentID       INT NOT NULL,
    SubmissionText  TEXT NOT NULL,
    Grade           DECIMAL(5,2) NULL,
    Feedback        TEXT NULL,
    SubmittedDate   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_submission_grade CHECK (Grade IS NULL OR Grade BETWEEN 0 AND 100),
    CONSTRAINT fk_submission_assignment FOREIGN KEY (AssignmentID) REFERENCES Assignments(AssignmentID) ON DELETE CASCADE,
    CONSTRAINT fk_submission_student FOREIGN KEY (StudentID) REFERENCES Users(UserID) ON DELETE CASCADE,
    UNIQUE KEY uq_submission (AssignmentID, StudentID)
);

CREATE TABLE IF NOT EXISTS PeerReviews (
    ReviewID        INT AUTO_INCREMENT PRIMARY KEY,
    SubmissionID    INT NOT NULL,
    ReviewerID      INT NOT NULL,
    Feedback        TEXT NOT NULL,
    Rating          INT NOT NULL,
    CONSTRAINT chk_peer_review_rating CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_submission FOREIGN KEY (SubmissionID) REFERENCES AssignmentSubmissions(SubmissionID) ON DELETE CASCADE,
    CONSTRAINT fk_review_reviewer FOREIGN KEY (ReviewerID) REFERENCES Users(UserID) ON DELETE CASCADE,
    UNIQUE KEY uq_peer_review (SubmissionID, ReviewerID)
);

CREATE TABLE IF NOT EXISTS StudySessions (
    SessionID       INT AUTO_INCREMENT PRIMARY KEY,
    CreatedBy       INT NOT NULL,
    Title           VARCHAR(150) NOT NULL,
    SessionDate     DATE NOT NULL,
    SessionTime     TIME NOT NULL,
    Description     VARCHAR(500),
    CONSTRAINT fk_session_creator FOREIGN KEY (CreatedBy) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS StudySessionParticipants (
    ParticipantID   INT AUTO_INCREMENT PRIMARY KEY,
    SessionID       INT NOT NULL,
    StudentID       INT NOT NULL,
    CONSTRAINT fk_participant_session FOREIGN KEY (SessionID) REFERENCES StudySessions(SessionID) ON DELETE CASCADE,
    CONSTRAINT fk_participant_student FOREIGN KEY (StudentID) REFERENCES Users(UserID) ON DELETE CASCADE,
    UNIQUE KEY uq_participant (SessionID, StudentID)
);

-- =========================================================
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

INSERT INTO LearningPathTopics (CourseID, Title, Content, SequenceOrder)
SELECT c.CourseID, seed.Title, seed.Content, seed.SequenceOrder
FROM (SELECT 'Introduction to HTML5' AS Title, 'Basics of HTML5 structure and semantic elements.' AS Content, 1 AS SequenceOrder
      UNION ALL SELECT 'CSS Styling Fundamentals', 'Internal, external and inline CSS.', 2
      UNION ALL SELECT 'Introduction to ASP.NET Web Forms', 'Server controls and page lifecycle.', 3) seed
JOIN Courses c ON c.Title = 'Web Application Development'
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Email = 'lecturer@edunest.com'
WHERE NOT EXISTS (SELECT 1 FROM LearningPathTopics t WHERE t.CourseID = c.CourseID AND t.Title = seed.Title);

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

INSERT INTO Assignments (CourseID, Title, Description, DueDate)
SELECT c.CourseID, 'Build a Personal Portfolio Page', 'Create a single HTML/CSS page showcasing your work.', '2026-12-15'
FROM Courses c WHERE c.Title = 'Web Application Development'
  AND NOT EXISTS (SELECT 1 FROM Assignments a WHERE a.CourseID = c.CourseID AND a.Title = 'Build a Personal Portfolio Page');

INSERT INTO StudySessions (CreatedBy, Title, SessionDate, SessionTime, Description)
SELECT student.UserID, 'WAPP Group Revision', '2026-12-01', '18:00:00', 'Revising CSS layout techniques before the quiz.'
FROM Users student WHERE student.Email = 'student@edunest.com'
  AND NOT EXISTS (SELECT 1 FROM StudySessions s WHERE s.CreatedBy = student.UserID AND s.Title = 'WAPP Group Revision');
