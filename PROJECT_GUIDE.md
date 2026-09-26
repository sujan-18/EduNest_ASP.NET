# EduNest Project Guide

This guide describes the EduNest source files, required software, database setup, and how to run the site in Visual Studio 2022.

## What EduNest is

EduNest is an ASP.NET Web Forms website using C#, .NET Framework 4.8, MySQL, and CSS. It provides a searchable technology course catalog, enrollment, learning paths, quizzes, assignments with lecturer grading and feedback, peer reviews, study sessions, and role-based student, lecturer, and administrator workspaces.

This is an **ASP.NET Web Site** project. It intentionally has no `.sln` or `.csproj` file. Visual Studio opens the folder as a Web Site and compiles its `.aspx` pages and code-behind files when the site runs.

## Software to install

Install these items on the computer where you will run the project:

1. **Visual Studio 2022**. In Visual Studio Installer, select the **ASP.NET and web development** workload. Ensure the **.NET Framework 4.8 development tools/targeting pack** and **IIS Express** components are selected. The .NET Framework 4.8 Developer Pack provides the reference assemblies needed to target this project.
2. **MySQL Server 8.0.16 or later** to store application data and enforce the schema's `CHECK` constraints. During setup, note the server port, username, and password. The default configuration expects `localhost`, port `3306`, and database `edunest_db`.
3. **MySQL Workbench** is recommended for loading and inspecting the database. It is a database GUI, not a replacement for MySQL Server. XAMPP can be used instead if its MySQL service is configured and running.
4. A modern web browser such as Edge or Chrome.

The project uses the **MySql.Data / Connector/NET** ADO.NET provider. Its package versions are listed in `packages.config`, and runtime assemblies are already in `bin/`. If NuGet prompts to restore packages when opening the site, allow the restore. No Node.js, npm, or separate frontend build is required.

## Project files and what they do

### Startup and shared layout

- `Default.aspx` and `Default.aspx.cs` — public home page and its server-side course count/featured course loading.
- `Site.master` and `Site.master.cs` — shared page shell, public navigation, authenticated role navigation, top bar, footer, and user/session display.
- `Web.config` — .NET Framework settings, session behavior, ASP.NET configuration, and a reference to the local connection-string file.
- `Web.ConnectionStrings.config` — machine-local MySQL credentials; ignored by Git so the app password is not included in source control.
- `Web.ConnectionStrings.example.config` — safe template to copy when setting up the project on another computer.
- `packages.config` — NuGet package names and versions used by the .NET Framework 4.8 site.
- `bin/` — runtime assemblies that the Web Site loads, including MySql.Data and its dependencies.

### Shared C# helpers

- `App_Code/DBHelper.cs` — central MySQL access methods (`ExecuteQuery`, `ExecuteNonQuery`, `ExecuteScalar`, and insert-with-ID). Pages use parameters for values passed to SQL.
- `App_Code/AuthHelper.cs` — shared session and role checks for protected pages.
- `App_Code/PasswordHelper.cs` — password hashing and verification routines.
- `App_Code/CourseVisualHelper.cs` — selects a bundled local illustration for each course subject category.

### Public account and course pages

- `Register.aspx` and `Register.aspx.cs` — student registration and validation.
- `Login.aspx` and `Login.aspx.cs` — login and session creation.
- `Logout.aspx` and `Logout.aspx.cs` — clears the signed-in session.
- `Courses.aspx` and `Courses.aspx.cs` — course catalog and student enrollment action.
- `Scripts/course-catalog.js` — live catalog search, category/level filters, sorting, and result count.
- `LearningPath.aspx` and `LearningPath.aspx.cs` — course topic path and student progress actions.

### Student pages

- `StudentDashboard.aspx` and `.aspx.cs` — enrolled course progress and student activity.
- `Quizzes.aspx` and `.aspx.cs` — quizzes available for an enrolled course.
- `MyQuizzes.aspx` and `.aspx.cs` — student quiz center across enrolled courses, showing question counts, attempt counts, and latest scores.
- `TakeQuiz.aspx` and `.aspx.cs` — quiz questions, answer submission, and result handling.
- `Assignments.aspx` and `.aspx.cs` — assignments for an enrolled course.
- `SubmitAssignment.aspx` and `.aspx.cs` — assignment submission form/action.
- `ReviewSubmissions.aspx` and `.aspx.cs` — lecturer/admin submission review, grading, and written feedback. Students can see the review on their submission page.
- `PeerReview.aspx` and `.aspx.cs` — peer feedback features.
- `StudyScheduler.aspx` and `.aspx.cs` — create, join, leave, and cancel study sessions.

### Lecturer and administrator pages

- `LecturerDashboard.aspx` and `.aspx.cs` — lecturer overview.
- `AdminDashboard.aspx` and `.aspx.cs` — administrator overview.
- `ManageCourses.aspx` and `.aspx.cs` — course management.
- `ManageLearningPath.aspx` and `.aspx.cs` — learning topic management.
- `ManageQuizzes.aspx` and `.aspx.cs` — quiz and question management.
- `ManageAssignments.aspx` and `.aspx.cs` — assignment management.
- `ManageUsers.aspx` and `.aspx.cs` — administrator user management.

### Static assets and database

- `Content/site.css` — global layout, component styling, and responsive rules for desktop, tablet, and mobile screens.
- `Images/` — local image assets used by the pages; these load from the project rather than an external image service.
- `Images/Courses/` — local SVG course illustrations for AI, networking, data science, cloud, cybersecurity, mobile, design, blockchain, and web development.
- `Scripts/page-motion.js` — homepage reveal and page transition effects, with reduced-motion support.
- `Scripts/validation.js` — client-side validation support.
- `Scripts/navigation.js` — responsive hamburger menus for the public header and signed-in workspace navigation.
- `Database/edunest_schema.sql` — safely creates all database tables and inserts demo accounts/sample content. It is repeatable and does not drop existing data.
- `Database/upgrade_platform_features.sql` — safely adds course category, level, estimated hours, and assignment grading fields to an existing database.
- `Database/upgrade_data_constraints.sql` — adds database validation constraints to an existing installation; safe to run again.
- `Database/seed_modern_courses.sql` — repeatably adds eleven modern technology courses, each with an ordered four-topic learning path, quiz questions, and a practical assignment.
- `Database/create_app_user.sql` — template for creating an application-only MySQL account with CRUD permissions limited to `edunest_db`.

Each `.aspx` file contains page markup; its matching `.aspx.cs` file contains that page's C# server-side behavior. The shared master page provides the common navigation and responsive layout.

## Run it in Visual Studio 2022

Follow these steps on every computer where you want to run EduNest. MySQL stores the data; Visual Studio runs the website and connects to MySQL using the connection-string file. Visual Studio does not create or migrate this database automatically.

### 1. Start MySQL and initialize the database

1. Start the MySQL Server 8 service. In Windows, you can check **Services** for a running service named `MySQL80` (the exact name may differ by installation).
2. Open MySQL Workbench and connect as the MySQL administrator account created during MySQL installation. The default server settings in this guide are `127.0.0.1`, port `3306`.
3. In Workbench, use **File > Open SQL Script** to open each script from this project, then click the lightning-bolt execute button. Run them in this order:
   1. `Database/edunest_schema.sql`
   2. `Database/upgrade_platform_features.sql`
   3. `Database/upgrade_data_constraints.sql`
   4. `Database/create_app_user.sql` (first replace both password placeholders with one strong password)
   5. `Database/seed_modern_courses.sql`
4. In Workbench's Schemas panel, click refresh and confirm `edunest_db` appears. Expand **Tables** to see the 13 tables.
5. Optional connection check in Workbench: create a new connection using host `127.0.0.1`, port `3306`, username `edunest_app`, and the password you chose. Connect and run `SELECT COUNT(*) FROM edunest_db.Courses;`. A fresh sample database should return 12.

The schema script creates missing tables and original sample records; it does not drop tables or delete rows. The two upgrade scripts add fields and validation constraints to existing installations. The modern course seed can be rerun without duplicating its catalog; rerun it in Workbench on an existing database to add newly added course tracks such as Networking & Infrastructure. These SQL scripts are the project's database setup/migration process; there is no Entity Framework migration command and no migration button in Visual Studio. Run the scripts in Workbench when setting up or upgrading the MySQL database, not every time you press F5.

The catalog includes eleven additional technology tracks: full-stack engineering, generative AI, data science, networking, cloud, cybersecurity, Flutter, DevOps, UI/UX, blockchain, and database engineering. With the two original sample courses, a fresh demo database contains 13 courses. Each modern course includes four topics, a quiz with knowledge-check questions, and a project assignment. Course cards use local subject-specific SVG illustrations rather than generic text-only covers or remote image links. Students can search, filter by subject or level, sort by title or workload, enroll, and continue a course. In **My Quizzes**, students can filter by subject (such as AI, networking, or data science) and by a specific enrolled course. It shows question counts, attempts, and latest scores. Quizzes use multiple-choice questions, automatic scoring, saved attempts, and retakes. The student dashboard displays a quiz performance rating calculated as the average percentage across all of that student's quiz attempts, divided by 20 to give a 0–5 rating. It also shows a trophy badge: no attempts display a grayscale trophy; Bronze requires more than 5 attempts; Silver requires more than 10 attempts and at least 60% average; Gold requires more than 20 attempts and at least 75%; Diamond requires more than 30 attempts and at least 90%. The next milestone is shown on the dashboard. Lecturers can manage course content and quizzes, review submissions, and return grades and feedback. Student dashboards show upcoming assignment deadlines and recent quiz results.

### 2. Configure the website's database connection

1. In File Explorer, open the project folder (the folder containing `Web.config`). Copy `Web.ConnectionStrings.example.config` and rename the copy to exactly `Web.ConnectionStrings.config`. Keep both files in this same folder. If Windows hides file extensions, ensure the new name is not accidentally `Web.ConnectionStrings.config.config`.
2. Open `Web.ConnectionStrings.config` in Visual Studio or Notepad. Set the server, port, database, username, and password to match your MySQL setup. For the supplied app account, leave the first four values as shown and replace only `YOUR_APP_PASSWORD` with the password used when running `create_app_user.sql`:

```xml
<add name="EduNestDB"
     connectionString="Server=127.0.0.1;Port=3306;Database=edunest_db;Uid=edunest_app;Pwd=YOUR_APP_PASSWORD;"
     providerName="MySql.Data.MySqlClient" />
```

3. Save the file. Do not paste the password into `Web.config`; `Web.config` loads the separate connection-string file. The local file is ignored by Git so credentials are not committed. If you choose another MySQL account, grant it `SELECT`, `INSERT`, `UPDATE`, and `DELETE` on `edunest_db`.

The application connects when a page first reads or writes database data. It does not require a separate database connector program to be launched from Visual Studio; the MySql.Data provider assemblies are included under `bin/`. MySQL Server must remain running while using the site.

### 3. Open the site folder in Visual Studio

1. Launch Visual Studio 2022.
2. Select **File > Open > Web Site...**.
3. Choose the `EduNest` project folder (the folder containing `Web.config`, `Site.master`, and `Default.aspx`).
4. If asked to restore NuGet packages, allow Visual Studio to restore them. The project also includes its runtime provider files in `bin/`.
5. In Solution Explorer, right-click `Default.aspx` and choose **Set as Start Page** if Visual Studio does not select the home page automatically.
6. Confirm `Web.ConnectionStrings.config` is in the project root beside `Web.config`. If it is not visible in Solution Explorer, use **Show All Files**; it still needs to exist on disk, but does not need to be included in the project file.

Do not use **Open > Project/Solution** for this folder; it has no `.sln` or `.csproj` because it is a Web Site project.

### 4. Run, connect, and sign in

Select **IIS Express** in the Visual Studio run target, then press **F5** to run with debugging or **Ctrl+F5** to run without debugging. Visual Studio opens the site at a local `http://localhost:<port>/` address. The chosen port may differ between runs. Use the URL shown by Visual Studio, then navigate from the home page. The home page loads its featured courses and course count through `App_Code/DBHelper.cs`, so if it displays those database-backed values without an error, the website has connected successfully.

Sign in with the Student demo account below and select **My Quizzes** in the left workspace navigation. Choose a subject (for example, Networking & Infrastructure) or a course from the filters, then choose **Start quiz**, answer the multiple-choice questions, and submit for an automatic score. Attempts, latest scores, and the average 0–5 performance rating appear in the quiz center/dashboard. Students must enroll in a course before its quizzes appear. Students can also give classmates written feedback and a 1–5 rating under **Peer Review**; only eligible submissions from courses both students share are listed, and students cannot review their own work or review the same submission twice. For a quick database write check, sign in as Lecturer and create a temporary course in **Manage Courses**; confirm it appears in the catalog, then remove it.

To stop the site, select **Debug > Stop Debugging** or press **Shift+F5**. Keep MySQL Server running while using pages that read or write database data.

## Demo sign-in accounts

The schema script inserts the Admin, original Lecturer, and Student sample accounts. Running `Database/seed_modern_courses.sql` also adds three named demo lecturers so courses can be distributed among instructors. All sample accounts use the password `Password123`:

| Role | Email |
| --- | --- |
| Admin | `admin@edunest.com` |
| Lecturer — Santosh Shah | `lecturer@edunest.com` |
| Lecturer — Prakriti Joshi | `prakriti.joshi@edunest.com` |
| Lecturer — Nabin Shrestha | `nabin.shrestha@edunest.com` |
| Lecturer — Asha Rai | `asha.rai@edunest.com` |
| Student | `student@edunest.com` |

New public registrations create student accounts. These are demo lecturer accounts for course ownership and role-workspace demos; other staff accounts should be assigned by an administrator.

### Separate dashboards and permissions

Use the demo role buttons on **Login.aspx** to fill a sample email and password, or enter an account manually. Click **Log In**; EduNest reads the role saved on that account and opens its dashboard:

- **Student** → `StudentDashboard.aspx`: own enrolled courses, topic progress, quizzes/achievements, assignment deadlines, and peer reviews.
- **Teacher (Lecturer)** → `LecturerDashboard.aspx`: only courses assigned to that lecturer, enrolled student counts, submissions, learning paths, quiz and assignment authoring, and grading.
- **Administrator** → `AdminDashboard.aspx`: platform-wide user, course, enrollment, quiz-attempt and pending-review totals, plus user/content management.

The sidebar also changes by role. A user who manually visits another role's protected dashboard is redirected to their own dashboard. Students can register publicly; lecturer and administrator roles must be assigned by an administrator (the extra lecturer accounts above are pre-seeded demos).

## Troubleshooting

- **Cannot connect to MySQL / connection refused:** make sure the MySQL Server service is running and that `Server`, `Port`, `Uid`, and `Pwd` in `Web.ConnectionStrings.config` match it.
- **Database permissions error:** confirm `edunest_app` was created and granted `SELECT`, `INSERT`, `UPDATE`, and `DELETE` rights on `edunest_db`, and that the password matches `Web.ConnectionStrings.config`. The application does not need database administrator privileges after setup.
- **Unknown database `edunest_db`:** create the schema by executing `Database/edunest_schema.sql`.
- **The home page loads but a database page shows a server error:** verify that MySQL Server is running, the schema and all scripts above ran successfully, and `Web.ConnectionStrings.config` is beside `Web.config`. Check the username/password using the optional Workbench app-account connection check. Restart IIS Express after changing the config, then reload the page. For the detailed ASP.NET error, run with F5 and inspect Visual Studio's **Output** window.
- **Catalog or grading columns are missing:** execute `Database/upgrade_platform_features.sql`, then `Database/upgrade_data_constraints.sql`.
- **Modern courses are not listed:** execute `Database/seed_modern_courses.sql` after the schema and feature upgrade scripts.
- **Missing connection-string configuration:** copy `Web.ConnectionStrings.example.config` to `Web.ConnectionStrings.config` in the same folder as `Web.config`; `Web.config` expects that file to exist.
- **Access denied for MySQL user:** correct the username/password or grant that MySQL account access to `edunest_db`.
- **Provider or MySql.Data assembly error:** restore packages from `packages.config` and confirm the project `bin/` folder contains `MySql.Data.dll` and its provider dependencies.
- **Targeting pack or reference assemblies error:** modify the Visual Studio installation and add the .NET Framework 4.8 development tools/targeting pack.
- **Visual Studio doesn't show a run target:** confirm the **ASP.NET and web development** workload and **IIS Express** are installed, then reopen the folder using **File > Open > Web Site...**.
- **A protected page returns to Login:** sign in with an account of the required role. Student quiz and assignment pages also require enrollment in the selected course.
- **A server error occurs:** use the exact local URL opened by Visual Studio and inspect the first ASP.NET exception details in Visual Studio's Output/Error List. Confirm the database and connection string first; different launch ports are normal.
