using System;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class Assignments : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        int courseId;
        if (!int.TryParse(Request.QueryString["CourseID"], out courseId) || courseId <= 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }
        int studentId = AuthHelper.CurrentUserId(this);
        if (Convert.ToInt32(DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Enrollments WHERE CourseID = @CourseID AND StudentID = @StudentID",
            new SqlParameter("@CourseID", courseId), new SqlParameter("@StudentID", studentId))) == 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }

        if (!IsPostBack)
        {
            string sql = @"SELECT a.AssignmentID, a.Title, a.Description, a.DueDate,
                            CASE WHEN EXISTS(SELECT 1 FROM AssignmentSubmissions s WHERE s.AssignmentID = a.AssignmentID AND s.StudentID = @StudentID) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS HasSubmitted
                            FROM Assignments a WHERE a.CourseID = @CourseID ORDER BY a.DueDate";
            rptAssignments.DataSource = DBHelper.ExecuteQuery(sql,
                new SqlParameter("@StudentID", studentId),
                new SqlParameter("@CourseID", courseId));
            rptAssignments.DataBind();
        }
    }
}
