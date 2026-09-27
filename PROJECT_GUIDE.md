# EduNest: run with Visual Studio 2022 and SQL Server LocalDB

EduNest is an ASP.NET Web Forms site targeting .NET Framework 4.8. It uses the SQL Server LocalDB instance installed with Visual Studio. The app connection is configured in `Web.ConnectionStrings.config`, which `Web.config` loads.

## First run

1. In Visual Studio, open the EduNest folder using **File → Open → Web Site**.
2. In **View → SQL Server Object Explorer**, expand **SQL Server → (localdb)\MSSQLLocalDB**.
3. Right-click `(localdb)\MSSQLLocalDB` and choose **New Query**.
4. Open `Database/edunest_sqlserver.sql`, copy all its contents into the query window, and click **Execute**. The script creates or updates the `EduNestDb` tables and adds the demo course and lesson data. It is safe to run again; it fills in missing lesson resources while keeping lessons that already have a resource link.
5. In Solution Explorer, right-click `Default.aspx` and choose **Set as Start Page** if needed. Press **F5** to run the website in IIS Express.

The checked-in example connection file uses Windows authentication with this LocalDB instance and database. The project-local `Web.ConnectionStrings.config` is ignored by Git and already contains that connection for this machine. No MySQL server, Workbench, username, or password is needed.

## Notes

- SQL Server LocalDB is different from MySQL. Use `Database/edunest_sqlserver.sql`; the other `Database/*.sql` files are MySQL scripts and do not apply to LocalDB.
- Visual Studio runs the website; SQL Server Object Explorer executes the database setup script.
- Demo accounts use `Password123`. See `README.md` for the account list.
- Student course pages show the course description, ordered lesson notes, a practice activity, and a link to a trusted learning resource. Students complete lessons in order; each completion button unlocks after they reach the end of that lesson, and the course is shown as complete after every lesson is finished. To apply these lesson updates to an existing LocalDB database, rerun `Database/edunest_sqlserver.sql` in SQL Server Object Explorer, then refresh the site.
- Teachers and admins can edit lesson notes and add or update the resource title and URL in **Manage Learning Path**.

## Troubleshooting

- If `(localdb)\MSSQLLocalDB` is missing, open Visual Studio Installer and add the **SQL Server Express LocalDB** individual component, then restart Visual Studio.
- If the site reports that a table is missing, execute the SQL Server setup script against `(localdb)\MSSQLLocalDB` again.
- If Visual Studio uses a different LocalDB instance name, update `Data Source` in `Web.ConnectionStrings.config` to match the instance shown in SQL Server Object Explorer.
