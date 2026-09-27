# EduNest — A Smart Campus Learning Hub
### CT050-3-2-WAPP Group Assignment (ASP.NET Web Forms + SQL Server LocalDB)

This is the full source code for EduNest, built to satisfy the assignment's
requirements: interlinked pages, HTML5, CSS (external/internal/inline),
CRUD for the main academic modules, registration, three login levels
(Student / Lecturer / Admin), server-side checks with ASP.NET client
validation controls on validated forms, and clean file organization.
Students can enroll in courses, follow ordered lessons, track completion, take
course quizzes, and submit or update a course rating and feedback.

## 1. Prerequisites

- **Visual Studio 2019/2022** with the "ASP.NET and web development" workload
- **SQL Server Express LocalDB**, installed with Visual Studio 2022.

## 2. Set up the database

1. In Visual Studio, open **View → SQL Server Object Explorer**.
2. Expand **SQL Server → (localdb)\MSSQLLocalDB**. Right-click it and choose
   **New Query**.
3. Open `Database/edunest_sqlserver.sql`, copy its contents into the query window,
   then click **Execute**. This creates `EduNestDb`, its tables, demo accounts, and
   an expanded catalog of 22 distinct courses with subject-specific illustrations.

### Demo accounts (all use the password `Password123`)

The SQL Server setup script creates these demo accounts.

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
3. `Web.ConnectionStrings.config` connects to `(localdb)\MSSQLLocalDB` and
   `EduNestDb` using Windows authentication. `Web.config` loads it automatically.
4. Press **F5** (or Ctrl+F5) to run. Visual Studio will launch it in IIS
   Express at a `localhost` URL.

## 4. Project structure

```
EduNest/
├── App_Code/              # Shared C# helper classes
│   ├── DBHelper.cs         (all ADO.NET / SQL Server access goes through here)
│   ├── PasswordHelper.cs    (PBKDF2 password hashing with legacy hash upgrade)
│   └── AuthHelper.cs        (session-based role guard used on every protected page)
├── Content/
│   └── site.css            (external stylesheet)
├── Images/                 (local student photo and learning illustration)
├── Scripts/
│   └── validation.js
├── Database/
│   └── edunest_sqlserver.sql # LocalDB schema and demo data
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
- The SQL Server LocalDB schema is in `Database/edunest_sqlserver.sql`
  in this workspace. Configure the connection string and run both SQL setup
  scripts on any other computer before presenting the live demo.
- Styling is intentionally clean/functional; feel free to reskin `site.css` to
  make it visually distinctive for your presentation/demo.

## 7. Suggested screenshots for your Final Report

Once running, capture: Homepage, Register, Login, Student Dashboard (with
progress bars), Learning Path with a completed topic, Take Quiz + result
screen, Peer Review, Study Scheduler, Admin → Manage Users (showing
edit/delete in action), Lecturer → Manage Courses (showing insert/update/delete).
