using System;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class LecturerDashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer")) return;
        if (!IsPostBack)
        {
            litName.Text = Server.HtmlEncode(Session["FullName"] as string);
            LoadStats();
            LoadCourses();
        }
    }

    private void LoadStats()
    {
        int lecturerId = AuthHelper.CurrentUserId(this);

        litCourseCount.Text = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Courses WHERE LecturerID = @LecturerID",
            new MySqlParameter("@LecturerID", lecturerId)).ToString();

        litStudentCount.Text = DBHelper.ExecuteScalar(
            @"SELECT COUNT(DISTINCT e.StudentID) FROM Enrollments e
              JOIN Courses c ON e.CourseID = c.CourseID WHERE c.LecturerID = @LecturerID",
            new MySqlParameter("@LecturerID", lecturerId)).ToString();

        litSubmissionCount.Text = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM AssignmentSubmissions s
              JOIN Assignments a ON s.AssignmentID = a.AssignmentID
              JOIN Courses c ON a.CourseID = c.CourseID WHERE c.LecturerID = @LecturerID",
            new MySqlParameter("@LecturerID", lecturerId)).ToString();

        litPendingReviewCount.Text = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM AssignmentSubmissions s
              JOIN Assignments a ON a.AssignmentID = s.AssignmentID
              JOIN Courses c ON c.CourseID = a.CourseID
              WHERE c.LecturerID = @LecturerID
                AND s.Grade IS NULL AND (s.Feedback IS NULL OR TRIM(s.Feedback) = '')",
            new MySqlParameter("@LecturerID", lecturerId)).ToString();
    }

    private void LoadCourses()
    {
        int lecturerId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT c.Title,
                        (SELECT COUNT(*) FROM Enrollments e WHERE e.CourseID = c.CourseID) AS StudentCount,
                        (SELECT COUNT(*) FROM LearningPathTopics t WHERE t.CourseID = c.CourseID) AS TopicCount
                        FROM Courses c WHERE c.LecturerID = @LecturerID";
        gvCourses.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@LecturerID", lecturerId));
        gvCourses.DataBind();
    }
}
