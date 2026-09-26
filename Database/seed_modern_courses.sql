-- Add a modern technology catalog and sample learning content.
-- Safe to rerun: rows are matched on the owning course plus their natural title.
-- Run after edunest_schema.sql and upgrade_platform_features.sql.
USE edunest_db;

-- Add demo lecturers used to distribute course ownership. Their password is
-- the same Password123 demo hash as lecturer@edunest.com.
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT 'Prakriti Joshi', 'prakriti.joshi@edunest.com', 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'prakriti.joshi@edunest.com');
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT 'Nabin Shrestha', 'nabin.shrestha@edunest.com', 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'nabin.shrestha@edunest.com');
INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
SELECT 'Asha Rai', 'asha.rai@edunest.com', 'Ke3X5//FlBieE4tzLe54qmxfJX6dvUXz0dqzH1Ne71g=', 'demoSalt123', 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'asha.rai@edunest.com');

CREATE TEMPORARY TABLE EduNestCourseSeed (
    CourseTitle VARCHAR(150) NOT NULL,
    CourseDescription TEXT NOT NULL,
    Category VARCHAR(60) NOT NULL,
    CourseLevel ENUM('Beginner','Intermediate','Advanced') NOT NULL,
    EstimatedHours SMALLINT UNSIGNED NOT NULL,
    LecturerEmail VARCHAR(150) NOT NULL
);

INSERT INTO EduNestCourseSeed VALUES
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
('Computer Networking & Infrastructure Foundations', 'Learn how networks move data, configure addressing and routing, diagnose connectivity, and secure modern infrastructure.', 'Networking & Infrastructure', 'Beginner', 20, 'nabin.shrestha@edunest.com');

INSERT INTO Courses (Title, Description, Category, Level, EstimatedHours, LecturerID)
SELECT s.CourseTitle, s.CourseDescription, s.Category, s.CourseLevel, s.EstimatedHours, lecturer.UserID
FROM EduNestCourseSeed s
JOIN Users lecturer ON lecturer.Email = s.LecturerEmail AND lecturer.Role = 'Lecturer'
WHERE NOT EXISTS (
    SELECT 1 FROM Courses c
    WHERE c.Title = s.CourseTitle
);

-- Move courses from the original single demo lecturer to the named course
-- owners once; keep later manual ownership changes intact on future reruns.
UPDATE Courses c
JOIN EduNestCourseSeed s ON s.CourseTitle = c.Title
JOIN Users originalLecturer ON originalLecturer.Email = 'lecturer@edunest.com'
JOIN Users assignedLecturer ON assignedLecturer.Email = s.LecturerEmail
SET c.LecturerID = assignedLecturer.UserID
WHERE c.LecturerID = originalLecturer.UserID OR c.LecturerID = assignedLecturer.UserID;

CREATE TEMPORARY TABLE EduNestTopicSeed (
    CourseTitle VARCHAR(150) NOT NULL,
    SequenceOrder INT NOT NULL,
    TopicTitle VARCHAR(150) NOT NULL,
    TopicContent TEXT NOT NULL
);

INSERT INTO EduNestTopicSeed VALUES
('Full-Stack Web Engineering with React & ASP.NET',1,'Product architecture and accessible HTML','Plan a user-centered product, semantic page structure, accessibility, and a maintainable front-end project.'),
('Full-Stack Web Engineering with React & ASP.NET',2,'React components and state','Compose reusable components, manage state, validate forms, and build responsive interactions.'),
('Full-Stack Web Engineering with React & ASP.NET',3,'REST APIs and ASP.NET services','Design versionable REST endpoints, validate requests, handle errors, and protect service routes.'),
('Full-Stack Web Engineering with React & ASP.NET',4,'Authentication, testing, and deployment','Connect persistent data, secure user sessions, test critical flows, and deploy a production-ready app.'),
('Applied Generative AI & LLM Applications',1,'LLMs, tokens, and responsible use','Understand language-model behavior, context limits, privacy risks, and human review requirements.'),
('Applied Generative AI & LLM Applications',2,'Prompt design and structured outputs','Write reliable instructions, constrain responses, and validate structured model output.'),
('Applied Generative AI & LLM Applications',3,'Embeddings and retrieval-augmented generation','Index trusted material, retrieve relevant passages, and ground generated answers in source content.'),
('Applied Generative AI & LLM Applications',4,'Evaluation, safety, and deployment','Measure quality and hallucinations, test safety boundaries, and monitor a production AI feature.'),
('Python Data Science & Analytics',1,'Python, notebooks, and reproducibility','Use Python environments and notebooks to document a repeatable analysis workflow.'),
('Python Data Science & Analytics',2,'Data cleaning with pandas','Inspect, transform, join, and validate tabular data while recording assumptions.'),
('Python Data Science & Analytics',3,'Statistics and clear visualizations','Choose appropriate summaries and charts, explain uncertainty, and avoid misleading visuals.'),
('Python Data Science & Analytics',4,'Modeling and communicating insights','Build a baseline model, evaluate it on held-out data, and present practical recommendations.'),
('Cloud-Native Engineering with AWS & Docker',1,'Cloud concepts and service boundaries','Choose managed services, define trust boundaries, and design for failure and recovery.'),
('Cloud-Native Engineering with AWS & Docker',2,'Containers and Docker images','Package a service, manage image layers, and configure secrets and runtime settings safely.'),
('Cloud-Native Engineering with AWS & Docker',3,'Networking, identity, and storage','Configure least-privilege access, service networking, durable storage, and backups.'),
('Cloud-Native Engineering with AWS & Docker',4,'Resilience, costs, and observability','Add health checks, logs, metrics, scaling policies, and cost controls.'),
('Cybersecurity & Ethical Hacking Essentials',1,'Threat modeling and security ethics','Identify assets and threats, define testing authorization, and document a safe scope.'),
('Cybersecurity & Ethical Hacking Essentials',2,'Web application security basics','Recognize common injection, access-control, and cross-site scripting risks.'),
('Cybersecurity & Ethical Hacking Essentials',3,'Identity, secrets, and secure configuration','Apply multi-factor authentication, least privilege, secret handling, and secure defaults.'),
('Cybersecurity & Ethical Hacking Essentials',4,'Incident response and responsible reporting','Preserve evidence, triage incidents, communicate impact, and report vulnerabilities responsibly.'),
('Cross-Platform App Development with Flutter',1,'Dart and Flutter widget foundations','Build a responsive interface from composable widgets and understand the Dart language basics.'),
('Cross-Platform App Development with Flutter',2,'Navigation and state management','Structure app screens, manage local state, and keep navigation predictable.'),
('Cross-Platform App Development with Flutter',3,'APIs, storage, and offline behavior','Load remote data, handle failures, and persist user-friendly offline state.'),
('Cross-Platform App Development with Flutter',4,'Accessibility, testing, and release','Check mobile accessibility, test on different screen sizes, and prepare app releases.'),
('DevOps Automation & CI/CD',1,'Version control and delivery workflows','Use branching and review practices that make changes traceable and reversible.'),
('DevOps Automation & CI/CD',2,'Continuous integration and automated tests','Run fast validation on every change and publish clear build results.'),
('DevOps Automation & CI/CD',3,'Deployment strategies and infrastructure','Automate repeatable deployments, configuration, rollback, and environment promotion.'),
('DevOps Automation & CI/CD',4,'Observability and reliability practices','Use service-level indicators, alerts, logs, and post-incident learning.'),
('UI/UX & Digital Product Design with Figma',1,'User research and problem framing','Plan interviews, synthesize findings, and define a clear design problem.'),
('UI/UX & Digital Product Design with Figma',2,'Information architecture and user flows','Organize content and map common journeys before drawing detailed screens.'),
('UI/UX & Digital Product Design with Figma',3,'Accessible interface and design systems','Create responsive components, consistent tokens, and inclusive interface patterns.'),
('UI/UX & Digital Product Design with Figma',4,'Prototyping and usability testing','Build an interactive prototype, observe users, and prioritize changes from evidence.'),
('Blockchain dApp Development with Solidity',1,'Smart contracts and EVM fundamentals','Understand transactions, state, gas, and the difference between on-chain and off-chain data.'),
('Blockchain dApp Development with Solidity',2,'Solidity types and contract design','Write clear contract functions and define ownership and permission boundaries.'),
('Blockchain dApp Development with Solidity',3,'Testing and common contract risks','Test edge cases and recognize reentrancy, unsafe assumptions, and access-control errors.'),
('Blockchain dApp Development with Solidity',4,'Wallet connections and dApp experience','Connect a wallet safely, explain transaction costs, and design clear user confirmation flows.'),
('Modern Database Engineering with MySQL & Redis',1,'Relational modeling and normalization','Translate product requirements into keys, relationships, and consistent relational tables.'),
('Modern Database Engineering with MySQL & Redis',2,'SQL queries, indexes, and explain plans','Write efficient joins, inspect query plans, and add indexes based on measured access patterns.'),
('Modern Database Engineering with MySQL & Redis',3,'Transactions, concurrency, and caching','Protect updates with transactions, understand contention, and use cache invalidation deliberately.'),
('Modern Database Engineering with MySQL & Redis',4,'Migrations, backups, and recovery','Plan reversible schema changes, verify backups, and practice a recovery procedure.'),
('Computer Networking & Infrastructure Foundations',1,'Network models and packet flow','Trace how application data moves through network layers, switches, routers, and services.'),
('Computer Networking & Infrastructure Foundations',2,'IP addressing and subnetting','Plan IPv4 subnets, gateways, DNS settings, and practical address ranges.'),
('Computer Networking & Infrastructure Foundations',3,'Routing, switching, and troubleshooting','Inspect routes, isolate common connectivity faults, and verify fixes with network tools.'),
('Computer Networking & Infrastructure Foundations',4,'Network security and cloud connectivity','Apply segmentation, secure remote access, firewall rules, and cloud network fundamentals.');

INSERT INTO LearningPathTopics (CourseID, Title, Content, SequenceOrder)
SELECT c.CourseID, s.TopicTitle, s.TopicContent, s.SequenceOrder
FROM EduNestTopicSeed s
JOIN Courses c ON c.Title = s.CourseTitle
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Role = 'Lecturer'
WHERE NOT EXISTS (
    SELECT 1 FROM LearningPathTopics t
    WHERE t.CourseID = c.CourseID AND t.Title = s.TopicTitle
);

CREATE TEMPORARY TABLE EduNestQuizSeed (
    CourseTitle VARCHAR(150) NOT NULL,
    QuizTitle VARCHAR(150) NOT NULL
);
INSERT INTO EduNestQuizSeed VALUES
('Full-Stack Web Engineering with React & ASP.NET','Full-Stack Web Engineering - Practical Check'),
('Applied Generative AI & LLM Applications','Generative AI Applications - Practical Check'),
('Python Data Science & Analytics','Python Data Science - Practical Check'),
('Cloud-Native Engineering with AWS & Docker','Cloud-Native Engineering - Practical Check'),
('Cybersecurity & Ethical Hacking Essentials','Cybersecurity Essentials - Practical Check'),
('Cross-Platform App Development with Flutter','Flutter App Development - Practical Check'),
('DevOps Automation & CI/CD','DevOps Automation - Practical Check'),
('UI/UX & Digital Product Design with Figma','UI/UX Product Design - Practical Check'),
('Blockchain dApp Development with Solidity','Blockchain dApp Development - Practical Check'),
('Modern Database Engineering with MySQL & Redis','Modern Database Engineering - Practical Check'),
('Computer Networking & Infrastructure Foundations','Networking Fundamentals - Practical Check');

INSERT INTO Quizzes (CourseID, Title)
SELECT c.CourseID, s.QuizTitle FROM EduNestQuizSeed s
JOIN Courses c ON c.Title = s.CourseTitle
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Role = 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Quizzes q WHERE q.CourseID = c.CourseID AND q.Title = s.QuizTitle);

CREATE TEMPORARY TABLE EduNestQuestionSeed (
    CourseTitle VARCHAR(150) NOT NULL,
    QuizTitle VARCHAR(150) NOT NULL,
    QuestionText VARCHAR(500) NOT NULL,
    OptionA VARCHAR(255) NOT NULL,
    OptionB VARCHAR(255) NOT NULL,
    OptionC VARCHAR(255) NOT NULL,
    OptionD VARCHAR(255) NOT NULL,
    CorrectOption CHAR(1) NOT NULL
);
INSERT INTO EduNestQuestionSeed VALUES
('Full-Stack Web Engineering with React & ASP.NET','Full-Stack Web Engineering - Practical Check','Which HTTP method is conventionally used to replace a resource?', 'GET','POST','PUT','TRACE','C'),
('Full-Stack Web Engineering with React & ASP.NET','Full-Stack Web Engineering - Practical Check','Where should authorization for a protected API operation be enforced?', 'Only in the browser','On the server for every request','In a CSS class','In a URL fragment','B'),
('Full-Stack Web Engineering with React & ASP.NET','Full-Stack Web Engineering - Practical Check','What is a useful purpose of an automated integration test?', 'Check that connected services work together','Choose a color palette','Replace input validation','Store a production password','A'),
('Applied Generative AI & LLM Applications','Generative AI Applications - Practical Check','What is the main purpose of retrieval-augmented generation?', 'Increase model parameter count','Ground answers in retrieved source material','Remove the need to evaluate output','Train a model in the browser','B'),
('Applied Generative AI & LLM Applications','Generative AI Applications - Practical Check','What should an application do with untrusted model output?', 'Execute it immediately','Validate and safely handle it','Treat it as a database query','Use it as an authorization rule','B'),
('Applied Generative AI & LLM Applications','Generative AI Applications - Practical Check','Which practice helps measure whether an AI change is an improvement?', 'Evaluate it against representative test cases','Only inspect one favorable example','Hide failure cases','Skip human review in every situation','A'),
('Python Data Science & Analytics','Python Data Science - Practical Check','Which pandas structure represents labeled two-dimensional tabular data?', 'Series','DataFrame','Tuple','Generator','B'),
('Python Data Science & Analytics','Python Data Science - Practical Check','Why keep a final test set separate from model training?', 'To estimate performance on unseen data','To increase duplicate rows','To choose chart colors','To remove all missing values automatically','A'),
('Python Data Science & Analytics','Python Data Science - Practical Check','What makes a chart more trustworthy?', 'A clear scale, labels, and relevant context','A truncated axis with no note','Decorative effects over readable values','Omitting the data source','A'),
('Cloud-Native Engineering with AWS & Docker','Cloud-Native Engineering - Practical Check','What does horizontal scaling usually add?', 'More instances working in parallel','A longer password','A new database column','A larger source-code file','A'),
('Cloud-Native Engineering with AWS & Docker','Cloud-Native Engineering - Practical Check','Where should cloud credentials be stored?', 'In a public repository','In managed secrets or an identity service','In a container image layer','In a client-side script','B'),
('Cloud-Native Engineering with AWS & Docker','Cloud-Native Engineering - Practical Check','What is a container image?', 'A packaged filesystem and metadata for running software','A live database backup only','A virtual network route','A password manager','A'),
('Cybersecurity & Ethical Hacking Essentials','Cybersecurity Essentials - Practical Check','What should be agreed before security testing begins?', 'A written scope and authorization','A public announcement of passwords','An unbounded target list','A production data export','A'),
('Cybersecurity & Ethical Hacking Essentials','Cybersecurity Essentials - Practical Check','What does multi-factor authentication add?', 'An additional independent verification factor','A longer page title','A database index','An extra network port','A'),
('Cybersecurity & Ethical Hacking Essentials','Cybersecurity Essentials - Practical Check','Which response is appropriate after finding a vulnerability?', 'Report it through the authorized disclosure process','Exploit unrelated systems','Publish secrets immediately','Delete all evidence','A'),
('Cross-Platform App Development with Flutter','Flutter App Development - Practical Check','What is the primary building block of a Flutter interface?', 'Widget','Stored procedure','Container image','CSS selector','A'),
('Cross-Platform App Development with Flutter','Flutter App Development - Practical Check','What should an app do when an API request fails?', 'Show a useful recoverable state','Freeze without feedback','Display a stack trace to all users','Delete local settings','A'),
('Cross-Platform App Development with Flutter','Flutter App Development - Practical Check','Why test on multiple screen sizes?', 'To catch layout and usability issues across devices','To increase app permissions','To skip accessibility checks','To avoid automated tests','A'),
('DevOps Automation & CI/CD','DevOps Automation - Practical Check','What is a goal of continuous integration?', 'Validate changes frequently with automated checks','Deploy unknown changes without review','Store credentials in commit history','Remove all monitoring','A'),
('DevOps Automation & CI/CD','DevOps Automation - Practical Check','What does a rollback strategy provide?', 'A planned way to restore a known-good release','A guarantee that bugs cannot happen','A replacement for backups','An access-control bypass','A'),
('DevOps Automation & CI/CD','DevOps Automation - Practical Check','Which signal is most directly useful for alerting on service latency?', 'A measured latency metric against a threshold','The number of design files','A branch name','An icon size','A'),
('UI/UX & Digital Product Design with Figma','UI/UX Product Design - Practical Check','What is the main goal of a usability test?', 'Observe users completing realistic tasks','Prove the first design is perfect','Measure server disk space','Replace accessibility review','A'),
('UI/UX & Digital Product Design with Figma','UI/UX Product Design - Practical Check','What does a design system help teams maintain?', 'Reusable, consistent interface patterns','Private API passwords','Database transaction locks','Cloud region settings','A'),
('UI/UX & Digital Product Design with Figma','UI/UX Product Design - Practical Check','Which practice improves interface accessibility?', 'Use clear labels and keyboard-operable controls','Rely on color alone','Remove focus indicators','Use text embedded only in images','A'),
('Blockchain dApp Development with Solidity','Blockchain dApp Development - Practical Check','Which language is commonly used to write EVM smart contracts?', 'Solidity','Dart','SQL','CSS','A'),
('Blockchain dApp Development with Solidity','Blockchain dApp Development - Practical Check','Why test access control in a smart contract?', 'Unauthorized calls can change valuable on-chain state','It improves font rendering','It reduces all transaction costs to zero','It hides public blockchain data','A'),
('Blockchain dApp Development with Solidity','Blockchain dApp Development - Practical Check','What should a dApp explain before a wallet transaction?', 'The requested action and likely network cost','The users private key','An unrelated notification','A guarantee of profit','A'),
('Modern Database Engineering with MySQL & Redis','Modern Database Engineering - Practical Check','What is a database transaction useful for?', 'Grouping related changes atomically','Styling a web form','Compiling JavaScript','Creating a cloud region','A'),
('Modern Database Engineering with MySQL & Redis','Modern Database Engineering - Practical Check','When should an index generally be added?', 'When measured query patterns justify it','For every column automatically','Only to store passwords','Whenever a table is empty','A'),
('Modern Database Engineering with MySQL & Redis','Modern Database Engineering - Practical Check','What is an important part of a safe schema migration?', 'A tested plan for applying and recovering the change','Editing production tables without a backup','Removing all constraints','Changing data types without checking existing values','A'),
('Computer Networking & Infrastructure Foundations','Networking Fundamentals - Practical Check','Which service translates a domain name into an IP address?', 'DNS','DHCP','SSH','NTP','A'),
('Computer Networking & Infrastructure Foundations','Networking Fundamentals - Practical Check','What is the default gateway used for?', 'Sending traffic to networks outside the local subnet','Assigning a username','Encrypting a local file','Naming a database','A'),
('Computer Networking & Infrastructure Foundations','Networking Fundamentals - Practical Check','What is a safe first step when diagnosing a connection issue?', 'Check link status, address configuration, and reachability','Disable every firewall permanently','Share administrator passwords','Replace all network equipment','A');

INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption)
SELECT q.QuizID, s.QuestionText, s.OptionA, s.OptionB, s.OptionC, s.OptionD, s.CorrectOption
FROM EduNestQuestionSeed s
JOIN EduNestQuizSeed qs ON qs.CourseTitle = s.CourseTitle AND qs.QuizTitle = s.QuizTitle
JOIN Courses c ON c.Title = s.CourseTitle
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Role = 'Lecturer'
JOIN Quizzes q ON q.CourseID = c.CourseID AND q.Title = qs.QuizTitle
WHERE NOT EXISTS (SELECT 1 FROM QuizQuestions qq WHERE qq.QuizID = q.QuizID AND qq.QuestionText = s.QuestionText);

CREATE TEMPORARY TABLE EduNestAssignmentSeed (
    CourseTitle VARCHAR(150) NOT NULL,
    AssignmentTitle VARCHAR(150) NOT NULL,
    AssignmentDescription TEXT NOT NULL,
    DueDate DATE NOT NULL
);
INSERT INTO EduNestAssignmentSeed VALUES
('Full-Stack Web Engineering with React & ASP.NET','Ship a Full-Stack Learning App','Design, build, test, and document a small accessible application with a React client and secure ASP.NET API.','2026-12-15'),
('Applied Generative AI & LLM Applications','Build a Grounded AI Study Assistant','Create a study assistant that answers from trusted course material and includes an evaluation and safety plan.','2026-12-15'),
('Python Data Science & Analytics','Explore and Explain a Real Dataset','Submit a reproducible notebook with data checks, useful visuals, a baseline model, and evidence-based recommendations.','2026-12-15'),
('Cloud-Native Engineering with AWS & Docker','Deploy a Resilient Containerized Service','Containerize a small service and document its identity, networking, health checks, monitoring, and rollback plan.','2026-12-15'),
('Cybersecurity & Ethical Hacking Essentials','Write a Web Security Assessment','Assess a deliberately scoped sample application and submit prioritized findings with safe remediation guidance.','2026-12-15'),
('Cross-Platform App Development with Flutter','Prototype and Test a Mobile App','Build a responsive Flutter app with API states, accessible navigation, and tests across multiple screen sizes.','2026-12-15'),
('DevOps Automation & CI/CD','Create a Continuous Delivery Pipeline','Automate validation and deployment for a sample service, including secrets handling, observability, and rollback.','2026-12-15'),
('UI/UX & Digital Product Design with Figma','Design and Validate a Digital Product Flow','Submit research notes, a user flow, an accessible prototype, usability findings, and prioritized design improvements.','2026-12-15'),
('Blockchain dApp Development with Solidity','Test a Secure Smart Contract dApp','Implement a small contract with automated tests, threat notes, safe wallet interaction, and clear transaction UX.','2026-12-15'),
('Modern Database Engineering with MySQL & Redis','Model, Tune, and Migrate an App Database','Deliver a relational model, measured query improvements, a safe migration plan, and a verified backup/recovery walkthrough.','2026-12-15'),
('Computer Networking & Infrastructure Foundations','Plan and Troubleshoot a Secure Small Network','Design an addressed network diagram, document routing and DNS choices, troubleshoot sample failures, and propose practical security controls.','2026-12-15');

INSERT INTO Assignments (CourseID, Title, Description, DueDate)
SELECT c.CourseID, s.AssignmentTitle, s.AssignmentDescription, s.DueDate
FROM EduNestAssignmentSeed s
JOIN Courses c ON c.Title = s.CourseTitle
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Role = 'Lecturer'
WHERE NOT EXISTS (SELECT 1 FROM Assignments a WHERE a.CourseID = c.CourseID AND a.Title = s.AssignmentTitle);

-- Enroll the demo student so dashboards and course activities have a complete
-- sample journey. New students can still choose their own courses.
INSERT INTO Enrollments (CourseID, StudentID)
SELECT c.CourseID, student.UserID FROM EduNestCourseSeed s
JOIN Courses c ON c.Title = s.CourseTitle
JOIN Users lecturer ON lecturer.UserID = c.LecturerID AND lecturer.Role = 'Lecturer'
JOIN Users student ON student.Email = 'student@edunest.com' AND student.Role = 'Student'
WHERE NOT EXISTS (SELECT 1 FROM Enrollments e WHERE e.CourseID = c.CourseID AND e.StudentID = student.UserID);

DROP TEMPORARY TABLE EduNestAssignmentSeed;
DROP TEMPORARY TABLE EduNestQuestionSeed;
DROP TEMPORARY TABLE EduNestQuizSeed;
DROP TEMPORARY TABLE EduNestTopicSeed;
DROP TEMPORARY TABLE EduNestCourseSeed;
