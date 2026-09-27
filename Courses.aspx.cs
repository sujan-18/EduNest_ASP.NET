using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class Courses : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) LoadCourses();
    }

    private void LoadCourses()
    {
        int studentId = IsStudent() ? AuthHelper.CurrentUserId(this) : 0;
        string sql = @"SELECT c.CourseID, c.Title, c.Description, c.Category, c.Level, c.EstimatedHours,
                              u.FullName AS LecturerName,
                              CASE WHEN EXISTS(SELECT 1 FROM Enrollments e WHERE e.CourseID = c.CourseID AND e.StudentID = @StudentID) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsEnrolled
                        FROM Courses c JOIN Users u ON c.LecturerID = u.UserID
                        ORDER BY c.Category, c.Title";
        DataTable courses = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
        courses.Columns.Add("ImagePath", typeof(string));
        foreach (DataRow course in courses.Rows)
            course["ImagePath"] = ResolveUrl(CourseVisualHelper.GetImagePath(course["Category"].ToString()));
        rptCourses.DataSource = courses;
        rptCourses.DataBind();
    }

    protected bool IsStudent()
    {
        return Session["Role"] as string == "Student";
    }

    protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName != "Enroll") return;

        if (Session["Role"] as string != "Student")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        int courseId = Convert.ToInt32(e.CommandArgument);
        int studentId = AuthHelper.CurrentUserId(this);

        // Avoid duplicate enrollments using the unique (CourseID, StudentID) key.
        DBHelper.ExecuteNonQuery(
            @"IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE CourseID = @CourseID AND StudentID = @StudentID)
              INSERT INTO Enrollments (CourseID, StudentID) VALUES (@CourseID, @StudentID)",
            new SqlParameter("@CourseID", courseId),
            new SqlParameter("@StudentID", studentId));

        Response.Redirect("StudentDashboard.aspx");
    }
}
