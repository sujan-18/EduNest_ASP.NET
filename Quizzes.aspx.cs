using System;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class Quizzes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (!IsPostBack)
        {
            int courseId;
            if (!int.TryParse(Request.QueryString["CourseID"], out courseId) || courseId <= 0)
            {
                Response.Redirect("Courses.aspx");
                return;
            }
            object enrolled = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Enrollments WHERE CourseID = @CourseID AND StudentID = @StudentID",
                new SqlParameter("@CourseID", courseId),
                new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
            if (Convert.ToInt32(enrolled) == 0)
            {
                Response.Redirect("Courses.aspx");
                return;
            }
            string sql = @"SELECT q.QuizID, q.Title, COUNT(qq.QuestionID) AS QuestionCount
                            FROM Quizzes q LEFT JOIN QuizQuestions qq ON q.QuizID = qq.QuizID
                            WHERE q.CourseID = @CourseID GROUP BY q.QuizID, q.Title";
            rptQuizzes.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@CourseID", courseId));
            rptQuizzes.DataBind();
        }
    }
}
