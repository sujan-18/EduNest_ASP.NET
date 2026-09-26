using System;
using MySql.Data.MySqlClient;
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
            new MySqlParameter("@CourseID", courseId), new MySqlParameter("@StudentID", studentId))) == 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }

        if (!IsPostBack)
        {
            string sql = @"SELECT a.AssignmentID, a.Title, a.Description, a.DueDate,
                            EXISTS(SELECT 1 FROM AssignmentSubmissions s WHERE s.AssignmentID = a.AssignmentID AND s.StudentID = @StudentID) AS HasSubmitted
                            FROM Assignments a WHERE a.CourseID = @CourseID ORDER BY a.DueDate";
            rptAssignments.DataSource = DBHelper.ExecuteQuery(sql,
                new MySqlParameter("@StudentID", studentId),
                new MySqlParameter("@CourseID", courseId));
            rptAssignments.DataBind();
        }
    }
}
