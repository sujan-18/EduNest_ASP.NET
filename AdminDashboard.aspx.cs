using System;
using EduNest.App_Code;

public partial class AdminDashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Admin")) return;
        if (!IsPostBack)
        {
            litUserCount.Text = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Users").ToString();
            litCourseCount.Text = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Courses").ToString();
            litEnrollmentCount.Text = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Enrollments").ToString();
            litQuizAttempts.Text = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM QuizAttempts").ToString();
            litPendingReviews.Text = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM AssignmentSubmissions WHERE Grade IS NULL AND (Feedback IS NULL OR LTRIM(RTRIM(Feedback)) = '')").ToString();
        }
    }
}
