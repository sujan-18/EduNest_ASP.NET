# EduNest — A Smart Campus Learning Hub
### CT050-3-2-WAPP Group Assignment (ASP.NET Web Forms + MySQL)

This is the full source code for EduNest, built to satisfy the assignment's
requirements: interlinked pages, HTML5, CSS (external/internal/inline),
CRUD for the main academic modules, registration, three login levels
(Student / Lecturer / Admin), server-side checks with ASP.NET client
validation controls on validated forms, and clean file organization.

## 1. Prerequisites

- **Visual Studio 2019/2022** with the "ASP.NET and web development" workload
- **MySQL Server 8.0.16+** (MySQL Workbench is a recommended client; XAMPP is also an option)
- **MySQL Connector/NET** — tracked in `packages.config`; the required runtime
  assemblies are included in `bin/` for the Web Site project.

## 2. Set up the database

1. Open MySQL Workbench (or phpMyAdmin if you're using XAMPP).
2. Open `Database/edunest_schema.sql` and run the whole script. It safely creates
   the `edunest_db` database and all 13 tables, then adds missing demo records.
   It is repeatable and does not drop or overwrite existing application data.
3. Run `Database/upgrade_platform_features.sql` to add catalog metadata and
   assignment grading fields to existing installations. This migration is safe
   to run again.
4. Run `Database/upgrade_data_constraints.sql` to add database-level validation
   checks. This migration is safe to run again.
5. Run `Database/seed_modern_courses.sql` to add eleven technology courses with
   learning topics, quizzes, questions, and practical assignments. It can be
   rerun without duplicating the catalog.
6. For app connections, use `Database/create_app_user.sql`: replace its password
   placeholder and run it as a MySQL administrator. Put the same password in
   `Web.ConnectionStrings.config`. The site needs CRUD access to `edunest_db`, not server admin.

### Demo accounts (all use the password `Password123`)

The course seed creates three additional lecturer accounts and assigns courses across the instructor team.

| Role      | Email                  |
|-----------|------------------------|
| Admin     | admin@edunest.com      |
| Lecturer — Santosh Shah | lecturer@edunest.com |
| Lecturer — Prakriti Joshi | prakriti.joshi@edunest.com |
| Lecturer — Nabin Shrestha | nabin.shrestha@edunest.com |
| Lecturer — Asha Rai | asha.rai@edunest.com |
| Student   | student@edunest.com    |

## 3. Open the project in Visual Studio

1. File → Open → Web Site... → select the `EduNest` folder (this is a **Web Site**
   project, not a Web Application project, so no `.sln`/`.csproj` is needed —
   Visual Studio will treat every `.aspx`/`.aspx.cs` pair automatically).
2. If Visual Studio prompts to restore NuGet packages, accept the restore.
   The project includes `packages.config` and the matching .NET Framework 4.8
   runtime assemblies in `bin/`.
3. Copy `Web.ConnectionStrings.example.config` to `Web.ConnectionStrings.config`
   (the latter is ignored by Git), then set its connection string to match your local
   MySQL credentials:
   ```xml
   <add name="EduNestDB"
        connectionString="Server=127.0.0.1;Port=3306;Database=edunest_db;Uid=edunest_app;Pwd=YOUR_APP_PASSWORD;"
        providerName="MySql.Data.MySqlClient" />
   ```
   Use the same password you set in `Database/create_app_user.sql`. Keep the
   local credentials file private. `Web.config` loads it automatically.
4. Press **F5** (or Ctrl+F5) to run. Visual Studio will launch it in IIS
   Express at a `localhost` URL.

## 4. Project structure

```
EduNest/
├── App_Code/              # Shared C# helper classes
│   ├── DBHelper.cs         (all ADO.NET / MySQL access goes through here)
│   ├── PasswordHelper.cs    (PBKDF2 password hashing with legacy hash upgrade)
│   └── AuthHelper.cs        (session-based role guard used on every protected page)
├── Content/
│   └── site.css            (external stylesheet)
├── Images/                 (local student photo and learning illustration)
├── Scripts/
│   └── validation.js
├── Database/
│   ├── edunest_schema.sql
│   ├── upgrade_data_constraints.sql
│   ├── upgrade_platform_features.sql
│   ├── seed_modern_courses.sql
│   └── create_app_user.sql
├── Web.ConnectionStrings.example.config
├── Web.config
├── Site.master / .cs       # Shared layout + role-aware navigation
├── Default.aspx            # Public homepage
├── Register.aspx           # New member registration
├── Login.aspx / Logout.aspx
├── Courses.aspx            # Public course browsing + student enrollment
├── Scripts/course-catalog.js # Catalog search, filters, sorting
├── ManageCourses.aspx      # Lecturer/Admin CRUD on courses
├── LearningPath.aspx       # Student view + "mark complete" progress tracking
├── ManageLearningPath.aspx # Lecturer CRUD on learning-path topics
├── StudentDashboard.aspx   # Academic Progress Dashboard
├── LecturerDashboard.aspx
├── AdminDashboard.aspx
├── ManageUsers.aspx        # Admin CRUD on user accounts
├── Quizzes.aspx / TakeQuiz.aspx      # Student: browse + auto-graded attempt
├── ManageQuizzes.aspx                # Lecturer CRUD on quizzes + questions
├── Assignments.aspx / SubmitAssignment.aspx
├── ManageAssignments.aspx  # Lecturer CRUD on assignments
├── ReviewSubmissions.aspx  # Lecturer/admin grading and feedback
├── PeerReview.aspx         # Rubric-based peer feedback module
└── StudyScheduler.aspx     # Create / join / leave / cancel study sessions
```

## 5. Proposal coverage

The public landing page follows the supplied EduNest design reference with a
cream canvas, deep blue and amber palette, serif display headings, feature and
journey sections, course cards, and a dark call-to-action. Signed-in screens
use a role-aware left sidebar and top workspace bar. The homepage uses a local
student photo so the image loads without a remote request.

| Requirement                              | Where |
|-------------------------------------------|-------|
| Interlinked webpages                       | Every page links via `Site.master` nav + in-page links |
| HTML5 elements                             | Semantic markup across all `.aspx` pages (`<header>`, `<main>`, `<footer>`, `<nav>`) |
| External / internal / inline CSS           | `Content/site.css` (external); inline `style=""` used sparingly on a few elements |
| Database connectivity (Insert/Display/Update/Delete) | `ManageCourses.aspx`, `ManageLearningPath.aspx`, `ManageUsers.aspx`, `ManageQuizzes.aspx`, `ManageAssignments.aspx`, `StudyScheduler.aspx` |
| Modern technology courses | Eleven seeded tracks with learning paths, quizzes, and assignments; searchable and filterable catalog |
| Student quiz center and performance rating | `MyQuizzes.aspx` filters enrolled-course quizzes; dashboard computes an average-attempt rating from 0 to 5 |
| Student reviews | `PeerReview.aspx` lets students review eligible classmates' assignment submissions with written feedback and a 1–5 rating |
| Separate role dashboards | Login redirects Student, Lecturer/Teacher, and Admin accounts to their own dashboard; role guards and navigation keep their workspaces separate |
| Assignment review | Lecturers/admins grade submissions and return written feedback to students |
| Registration page                          | `Register.aspx` |
| Registered member modules                  | `StudentDashboard.aspx`, `LecturerDashboard.aspx`, plus all Manage* pages for lecturers |
| Administrator module                       | `AdminDashboard.aspx`, `ManageUsers.aspx` |
| Form validation                            | ASP.NET validation controls on registration and core create/submit forms; server-side checks protect sensitive actions |
| Navigation                                 | `Site.master` role-aware nav bar |
| File organization / naming convention      | PascalCase `.aspx` file names matching their purpose; helpers isolated in `App_Code/` |
| Academic progress and activity history     | `StudentDashboard.aspx` shows course completion, quiz scores, and latest topic/quiz/submission activity |
| Secure account access                      | Public signup only creates Student accounts; admins provision staff. New passwords use PBKDF2; legacy demo hashes are upgraded after successful login |
| Learning-path access                       | Visitors see topic order; enrolled students and authorized staff see content. Students must enroll and complete topics in sequence |
| Assignment and quiz access                 | Students must be enrolled in the course to submit assignments or attempt quizzes; assignment submissions close after the due date |

## 6. Known limitations / things you may want to extend for the final report

- Password reset / "forgot password" flow isn't implemented (out of scope
  per your proposal).
- File uploads for assignment submissions aren't included — submissions are
  plain text. If you want file upload, ASP.NET's `FileUpload` control plus
  saving to an `~/Uploads/` folder is the standard approach — ask if you'd
  like this added.
- The Study Room Scheduler is a booking/RSVP system rather than a live video
  meeting tool (matches your proposal's in-scope description).
- The local MySQL schema and database-backed public pages have been exercised
  in this workspace. Configure the connection string and run both SQL setup
  scripts on any other computer before presenting the live demo.
- Styling is intentionally clean/functional; feel free to reskin `site.css` to
  make it visually distinctive for your presentation/demo.

## 7. Suggested screenshots for your Final Report

Once running, capture: Homepage, Register, Login, Student Dashboard (with
progress bars), Learning Path with a completed topic, Take Quiz + result
screen, Peer Review, Study Scheduler, Admin → Manage Users (showing
edit/delete in action), Lecturer → Manage Courses (showing insert/update/delete).
