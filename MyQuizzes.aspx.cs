using System;
using EduNest.App_Code;
using System.Data.SqlClient;

public partial class MyQuizzes : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (IsPostBack) return;

        string sql = @"SELECT q.QuizID, q.Title, c.Title AS CourseTitle, c.Category,
                              COUNT(DISTINCT qq.QuestionID) AS QuestionCount,
                              COUNT(DISTINCT qa.AttemptID) AS AttemptCount,
                              (SELECT TOP 1 CONCAT(a.Score, '/', a.TotalQuestions)
                               FROM QuizAttempts a
                               WHERE a.QuizID = q.QuizID AND a.StudentID = @StudentID
                               ORDER BY a.AttemptDate DESC, a.AttemptID DESC) AS LatestScore
                       FROM Enrollments e
                       JOIN Courses c ON c.CourseID = e.CourseID
                       JOIN Quizzes q ON q.CourseID = c.CourseID
                       LEFT JOIN QuizQuestions qq ON qq.QuizID = q.QuizID
                       LEFT JOIN QuizAttempts qa ON qa.QuizID = q.QuizID AND qa.StudentID = @StudentID
                       WHERE e.StudentID = @StudentID
                       GROUP BY q.QuizID, q.Title, c.Title, c.Category
                       ORDER BY c.Title, q.Title";
        rptQuizzes.DataSource = DBHelper.ExecuteQuery(sql,
            new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
        rptQuizzes.DataBind();
        pnlNoQuizzes.Visible = rptQuizzes.Items.Count == 0;
    }
}
