using System;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class StudentDashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (!IsPostBack)
        {
            litName.Text = Server.HtmlEncode(Session["FullName"] as string);
            LoadProgress();
            LoadSummary();
            LoadQuizScores();
            LoadRecentActivity();
        }
    }

    private void LoadProgress()
    {
        int studentId = AuthHelper.CurrentUserId(this);

        string sql = @"SELECT c.CourseID, c.Title,
                        (SELECT COUNT(*) FROM LearningPathTopics t WHERE t.CourseID = c.CourseID) AS TotalTopics,
                        (SELECT COUNT(*) FROM TopicProgress p
                            JOIN LearningPathTopics t2 ON p.TopicID = t2.TopicID
                            WHERE t2.CourseID = c.CourseID AND p.StudentID = @StudentID) AS CompletedTopics,
                        ROUND(
                            (SELECT COUNT(*) FROM TopicProgress p
                                JOIN LearningPathTopics t2 ON p.TopicID = t2.TopicID
                                WHERE t2.CourseID = c.CourseID AND p.StudentID = @StudentID) * 100.0 /
                            NULLIF((SELECT COUNT(*) FROM LearningPathTopics t WHERE t.CourseID = c.CourseID), 0)
                        , 0) AS PercentComplete
                        FROM Courses c
                        JOIN Enrollments e ON c.CourseID = e.CourseID
                        WHERE e.StudentID = @StudentID";

        var dt = DBHelper.ExecuteQuery(sql, new MySqlParameter("@StudentID", studentId));
        // Guard against NULL percent when a course has zero topics yet
        foreach (System.Data.DataRow row in dt.Rows)
        {
            if (row["PercentComplete"] == DBNull.Value) row["PercentComplete"] = 0;
        }
        rptCourses.DataSource = dt;
        rptCourses.DataBind();
        pnlNoCourses.Visible = dt.Rows.Count == 0;
    }

    private void LoadSummary()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        litEnrolledCount.Text = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Enrollments WHERE StudentID=@StudentID",
            new MySqlParameter("@StudentID", studentId)).ToString();
        litCompletedCount.Text = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM TopicProgress WHERE StudentID=@StudentID",
            new MySqlParameter("@StudentID", studentId)).ToString();
        litAttemptCount.Text = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM QuizAttempts WHERE StudentID=@StudentID",
            new MySqlParameter("@StudentID", studentId)).ToString();
    }

    private void LoadQuizScores()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT q.Title AS QuizTitle, a.Score, a.TotalQuestions, a.AttemptDate
                        FROM QuizAttempts a JOIN Quizzes q ON a.QuizID = q.QuizID
                        WHERE a.StudentID = @StudentID
                        ORDER BY a.AttemptDate DESC LIMIT 10";
        gvQuizScores.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@StudentID", studentId));
        gvQuizScores.DataBind();
    }

    private void LoadRecentActivity()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT Activity, CourseTitle, ActivityDate FROM (
                         SELECT CONCAT('Completed: ', t.Title) AS Activity, c.Title AS CourseTitle, p.CompletedDate AS ActivityDate
                         FROM TopicProgress p JOIN LearningPathTopics t ON t.TopicID = p.TopicID
                         JOIN Courses c ON c.CourseID = t.CourseID WHERE p.StudentID = @StudentID
                         UNION ALL
                         SELECT CONCAT('Quiz attempt: ', q.Title), c.Title, a.AttemptDate
                         FROM QuizAttempts a JOIN Quizzes q ON q.QuizID = a.QuizID
                         JOIN Courses c ON c.CourseID = q.CourseID WHERE a.StudentID = @StudentID
                         UNION ALL
                         SELECT CONCAT('Submitted: ', a.Title), c.Title, s.SubmittedDate
                         FROM AssignmentSubmissions s JOIN Assignments a ON a.AssignmentID = s.AssignmentID
                         JOIN Courses c ON c.CourseID = a.CourseID WHERE s.StudentID = @StudentID
                       ) activity_log ORDER BY ActivityDate DESC LIMIT 10";
        gvActivity.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@StudentID", studentId));
        gvActivity.DataBind();
    }
}
