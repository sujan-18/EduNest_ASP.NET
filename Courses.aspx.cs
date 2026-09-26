using System;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
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
                              EXISTS(SELECT 1 FROM Enrollments e WHERE e.CourseID = c.CourseID AND e.StudentID = @StudentID) AS IsEnrolled
                        FROM Courses c JOIN Users u ON c.LecturerID = u.UserID
                        ORDER BY c.Category, c.Title";
        DataTable courses = DBHelper.ExecuteQuery(sql, new MySqlParameter("@StudentID", studentId));
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

        // INSERT IGNORE relies on the UNIQUE KEY (CourseID, StudentID) to avoid duplicate enrollment
        DBHelper.ExecuteNonQuery(
            "INSERT IGNORE INTO Enrollments (CourseID, StudentID) VALUES (@CourseID, @StudentID)",
            new MySqlParameter("@CourseID", courseId),
            new MySqlParameter("@StudentID", studentId));

        Response.Redirect("StudentDashboard.aspx");
    }
}
