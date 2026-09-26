# EduNest Project Guide

This guide describes the EduNest source files, required software, database setup, and how to run the site in Visual Studio 2022.

## What EduNest is

EduNest is an ASP.NET Web Forms website using C#, .NET Framework 4.8, MySQL, and CSS. It provides public course browsing and registration, student learning and progress pages, lecturer course content management, and administrator user and content management.

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
- `Web.config` — .NET Framework settings, session behavior, ASP.NET configuration, and the `EduNestDB` MySQL connection string.
- `packages.config` — NuGet package names and versions used by the .NET Framework 4.8 site.
- `bin/` — runtime assemblies that the Web Site loads, including MySql.Data and its dependencies.

### Shared C# helpers

- `App_Code/DBHelper.cs` — central MySQL access methods (`ExecuteQuery`, `ExecuteNonQuery`, `ExecuteScalar`, and insert-with-ID). Pages use parameters for values passed to SQL.
- `App_Code/AuthHelper.cs` — shared session and role checks for protected pages.
- `App_Code/PasswordHelper.cs` — password hashing and verification routines.

### Public account and course pages

- `Register.aspx` and `Register.aspx.cs` — student registration and validation.
- `Login.aspx` and `Login.aspx.cs` — login and session creation.
- `Logout.aspx` and `Logout.aspx.cs` — clears the signed-in session.
- `Courses.aspx` and `Courses.aspx.cs` — course catalog and student enrollment action.
- `LearningPath.aspx` and `LearningPath.aspx.cs` — course topic path and student progress actions.

### Student pages

- `StudentDashboard.aspx` and `.aspx.cs` — enrolled course progress and student activity.
- `Quizzes.aspx` and `.aspx.cs` — quizzes available for an enrolled course.
- `TakeQuiz.aspx` and `.aspx.cs` — quiz questions, answer submission, and result handling.
- `Assignments.aspx` and `.aspx.cs` — assignments for an enrolled course.
- `SubmitAssignment.aspx` and `.aspx.cs` — assignment submission form/action.
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
- `Scripts/validation.js` — client-side validation support.
- `Scripts/navigation.js` — responsive hamburger menus for the public header and signed-in workspace navigation.
- `Database/edunest_schema.sql` — safely creates all database tables and inserts demo accounts/sample content. It is repeatable and does not drop existing data.
- `Database/upgrade_data_constraints.sql` — adds database validation constraints to an existing installation; safe to run again.
- `Database/create_app_user.sql` — template for creating an application-only MySQL account with CRUD permissions limited to `edunest_db`.

Each `.aspx` file contains page markup; its matching `.aspx.cs` file contains that page's C# server-side behavior. The shared master page provides the common navigation and responsive layout.

## Run it in Visual Studio 2022

### 1. Start MySQL and create the sample database

1. Start the MySQL Server service.
2. Open MySQL Workbench and connect to the local server.
3. Open `Database/edunest_schema.sql` from this project and execute the full script.
4. Open `Database/upgrade_data_constraints.sql` and execute it. This adds missing validation checks to the existing database without clearing rows.
5. For a least-privilege app login, open `Database/create_app_user.sql`, replace both copies of `REPLACE_WITH_A_LONG_RANDOM_PASSWORD` with the same strong password, then execute it as a MySQL administrator. The account can read and change rows in `edunest_db` but cannot administer the MySQL server.
6. Confirm that the `edunest_db` schema and its 13 tables appear in Workbench.

The schema script can be safely rerun: it uses `CREATE ... IF NOT EXISTS` and only inserts demo records when their email/title keys are absent. It does not overwrite edited demo records or delete application data. The separate `upgrade_data_constraints.sql` file adds check constraints once and can also be rerun.

### 2. Set the connection string

Open `Web.config` and edit the `EduNestDB` connection string so the server, port, username, and password match the database account you created. The local workspace is configured with an `edunest_app` account; on a new computer use the password you placed in `create_app_user.sql`:

```xml
<add name="EduNestDB"
     connectionString="Server=127.0.0.1;Port=3306;Database=edunest_db;Uid=edunest_app;Pwd=YOUR_APP_PASSWORD;"
     providerName="MySql.Data.MySqlClient" />
```

Replace `YOUR_APP_PASSWORD` with the same password used in `create_app_user.sql`. Save `Web.config` after editing it. Do not share a real database password in screenshots or source control. If you use a different MySQL account, grant it `SELECT`, `INSERT`, `UPDATE`, and `DELETE` privileges on `edunest_db`.

### 3. Open the site folder in Visual Studio

1. Launch Visual Studio 2022.
2. Select **File > Open > Web Site...**.
3. Choose the `EduNest` project folder (the folder containing `Web.config`, `Site.master`, and `Default.aspx`).
4. If asked to restore NuGet packages, allow Visual Studio to restore them.
5. In Solution Explorer, right-click `Default.aspx` and choose **Set as Start Page** if Visual Studio does not select the home page automatically.

Do not use **Open > Project/Solution** for this folder; it has no `.sln` or `.csproj` because it is a Web Site project.

### 4. Run and stop

Select **IIS Express** in the Visual Studio run target, then press **F5** to run with debugging or **Ctrl+F5** to run without debugging. Visual Studio opens the site at a local `http://localhost:<port>/` address. The chosen port may differ between runs. Use the URL shown by Visual Studio, then navigate from the home page.

To stop the site, select **Debug > Stop Debugging** or press **Shift+F5**. Keep MySQL Server running while using pages that read or write database data.

## Demo sign-in accounts

The SQL setup script inserts sample accounts with the password `Password123`:

| Role | Email |
| --- | --- |
| Admin | `admin@edunest.com` |
| Lecturer | `lecturer@edunest.com` |
| Student | `student@edunest.com` |

New public registrations create student accounts. Staff roles are intended to be assigned by an administrator.

## Troubleshooting

- **Cannot connect to MySQL / connection refused:** make sure the MySQL Server service is running and that `Server`, `Port`, `Uid`, and `Pwd` in `Web.config` match it.
- **Database permissions error:** confirm `edunest_app` was created and granted `SELECT`, `INSERT`, `UPDATE`, and `DELETE` rights on `edunest_db`, and that the password matches `Web.config`. The application does not need database administrator privileges after setup.
- **Unknown database `edunest_db`:** create the schema by executing `Database/edunest_schema.sql`.
- **Access denied for MySQL user:** correct the username/password or grant that MySQL account access to `edunest_db`.
- **Provider or MySql.Data assembly error:** restore packages from `packages.config` and confirm the project `bin/` folder contains `MySql.Data.dll` and its provider dependencies.
- **Targeting pack or reference assemblies error:** modify the Visual Studio installation and add the .NET Framework 4.8 development tools/targeting pack.
- **Visual Studio doesn't show a run target:** confirm the **ASP.NET and web development** workload and **IIS Express** are installed, then reopen the folder using **File > Open > Web Site...**.
- **A protected page returns to Login:** sign in with an account of the required role. Student quiz and assignment pages also require enrollment in the selected course.
- **A server error occurs:** use the exact local URL opened by Visual Studio and inspect the first ASP.NET exception details in Visual Studio's Output/Error List. Confirm the database and connection string first; different launch ports are normal.
