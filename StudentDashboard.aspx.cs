using System;
using System.Data.SqlClient;
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
            LoadQuizRating();
            LoadQuizScores();
            LoadRecentActivity();
            LoadUpcomingAssignments();
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

        var dt = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
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
            new SqlParameter("@StudentID", studentId)).ToString();
        litCompletedCount.Text = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM TopicProgress WHERE StudentID=@StudentID",
            new SqlParameter("@StudentID", studentId)).ToString();
        litAttemptCount.Text = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM QuizAttempts WHERE StudentID=@StudentID",
            new SqlParameter("@StudentID", studentId)).ToString();
    }

    private void LoadQuizScores()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT TOP 10 q.Title AS QuizTitle, a.Score, a.TotalQuestions, a.AttemptDate
                        FROM QuizAttempts a JOIN Quizzes q ON a.QuizID = q.QuizID
                        WHERE a.StudentID = @StudentID
                        ORDER BY a.AttemptDate DESC";
        gvQuizScores.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
        gvQuizScores.DataBind();
    }

    private void LoadQuizRating()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        var result = DBHelper.ExecuteQuery(
            @"SELECT COUNT(*) AS AttemptCount,
                     AVG(Score * 100.0 / NULLIF(TotalQuestions, 0)) AS AveragePercent
              FROM QuizAttempts WHERE StudentID = @StudentID",
            new SqlParameter("@StudentID", studentId));

        int attempts = Convert.ToInt32(result.Rows[0]["AttemptCount"]);
        if (attempts == 0)
        {
            litQuizRating.Text = "<svg class='rating-placeholder-icon' aria-label='No rating yet' role='img' viewBox='0 0 24 24'><use href='#icon-star' /></svg>";
            litQuizRatingDetail.Text = "Take a quiz to earn a rating";
            litAchievementEmoji.Text = TrophyIcon("#7c8796");
            litAchievementTitle.Text = "Your trophy is waiting";
            litAchievementDetail.Text = "Quiz achievements are earned through consistent attempts and strong scores.";
            litAchievementNext.Text = "Complete 6 quiz attempts to earn Bronze.";
            return;
        }

        double averagePercent = Convert.ToDouble(result.Rows[0]["AveragePercent"]);
        double rating = Math.Round(averagePercent / 20.0, 1, MidpointRounding.AwayFromZero);
        litQuizRating.Text = rating.ToString("0.0") + "/5";
        litQuizRatingDetail.Text = averagePercent.ToString("0") + "% average across " + attempts + (attempts == 1 ? " attempt" : " attempts");

        string tier;
        string iconColor;
        if (attempts > 30 && averagePercent >= 90) { tier = "Diamond"; iconColor = "#087e8b"; }
        else if (attempts > 20 && averagePercent >= 75) { tier = "Gold"; iconColor = "#ad7200"; }
        else if (attempts > 10 && averagePercent >= 60) { tier = "Silver"; iconColor = "#68788d"; }
        else if (attempts > 5) { tier = "Bronze"; iconColor = "#a75a24"; }
        else { tier = "Trophy in progress"; iconColor = "#7c8796"; }

        achievementMedal.Attributes["class"] = "achievement-medal" + (tier == "Trophy in progress" ? " is-locked" : " tier-" + tier.ToLowerInvariant());
        litAchievementEmoji.Text = TrophyIcon(iconColor);
        litAchievementTitle.Text = tier;
        litAchievementDetail.Text = attempts.ToString() + (attempts == 1 ? " quiz attempt" : " quiz attempts") + " · " + averagePercent.ToString("0") + "% average score";
        if (tier == "Diamond") litAchievementNext.Text = "Highest achievement unlocked!";
        else if (tier == "Gold") litAchievementNext.Text = "Diamond: 31+ attempts and 90% average.";
        else if (tier == "Silver") litAchievementNext.Text = "Gold: 21+ attempts and 75% average.";
        else if (tier == "Bronze") litAchievementNext.Text = "Silver: 11+ attempts and 60% average.";
        else if (attempts <= 5) litAchievementNext.Text = (6 - attempts).ToString() + (6 - attempts == 1 ? " more attempt" : " more attempts") + " to unlock Bronze.";
        else litAchievementNext.Text = "Reach 11 attempts and a 60% average to unlock Silver.";
    }

    private string TrophyIcon(string color)
    {
        return "<svg viewBox='0 0 48 48' aria-hidden='true' focusable='false' xmlns='http://www.w3.org/2000/svg'><path d='M15 7h18v7h7v5c0 7-4 11-11 12a10 10 0 0 1-3 4v5h8v4H14v-4h8v-5a10 10 0 0 1-3-4C12 30 8 26 8 19v-5h7V7Zm0 11h-3v1c0 4 2 6 5 7a20 20 0 0 1-2-8Zm18 0a20 20 0 0 1-2 8c3-1 5-3 5-7v-1h-3Z' fill='" + color + "'/><path d='m21 20 3 3 6-7' fill='none' stroke='white' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'/></svg>";
    }

    private void LoadRecentActivity()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT TOP 10 Activity, CourseTitle, ActivityDate FROM (
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
                       ) activity_log ORDER BY ActivityDate DESC";
        gvActivity.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
        gvActivity.DataBind();
    }

    private void LoadUpcomingAssignments()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT TOP 5 a.AssignmentID, a.Title, a.DueDate, c.Title AS CourseTitle,
                              CASE WHEN EXISTS(SELECT 1 FROM AssignmentSubmissions s
                                  WHERE s.AssignmentID = a.AssignmentID AND s.StudentID = @StudentID) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS HasSubmitted
                       FROM Assignments a
                       JOIN Courses c ON c.CourseID = a.CourseID
                       JOIN Enrollments e ON e.CourseID = c.CourseID AND e.StudentID = @StudentID
                       WHERE a.DueDate >= CAST(GETDATE() AS DATE)
                       ORDER BY a.DueDate, a.Title";
        var assignments = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
        rptUpcomingAssignments.DataSource = assignments;
        rptUpcomingAssignments.DataBind();
        pnlNoUpcomingAssignments.Visible = assignments.Rows.Count == 0;
    }
}
