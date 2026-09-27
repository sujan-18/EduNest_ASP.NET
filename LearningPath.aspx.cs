using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class LearningPath : System.Web.UI.Page
{
    private bool canViewContent;
    private int CourseID
    {
        get { return Convert.ToInt32(Request.QueryString["CourseID"]); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        int courseId;
        if (!int.TryParse(Request.QueryString["CourseID"], out courseId) || courseId <= 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }
        DBHelper.EnsureLearningPathResourceColumns();
        if (!IsPostBack)
        {
            LoadPath();
            LoadCourseFeedback();
        }
    }

    private void LoadPath()
    {
        string role = Session["Role"] as string;
        if (role == "Student")
        {
            canViewContent = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Enrollments WHERE CourseID = @CourseID AND StudentID = @UserID",
                new SqlParameter("@CourseID", CourseID), new SqlParameter("@UserID", AuthHelper.CurrentUserId(this)))) > 0;
        }
        else if (role == "Admin") canViewContent = true;
        else if (role == "Lecturer")
        {
            canViewContent = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Courses WHERE CourseID = @CourseID AND LecturerID = @UserID",
                new SqlParameter("@CourseID", CourseID), new SqlParameter("@UserID", AuthHelper.CurrentUserId(this)))) > 0;
        }
        DataTable course = DBHelper.ExecuteQuery("SELECT Title, Description FROM Courses WHERE CourseID = @CourseID",
            new SqlParameter("@CourseID", CourseID));
        if (course.Rows.Count == 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }
        litCourseTitle.Text = Server.HtmlEncode(Convert.ToString(course.Rows[0]["Title"]));
        litCourseDescription.Text = Server.HtmlEncode(Convert.ToString(course.Rows[0]["Description"]));

        bool isStudent = Session["Role"] as string == "Student";
        int studentId = isStudent ? AuthHelper.CurrentUserId(this) : 0;
        pnlCourseFeedback.Visible = isStudent && canViewContent;
        hlCourseQuizzes.Visible = isStudent && canViewContent;
        hlCourseQuizzes.NavigateUrl = "Quizzes.aspx?CourseID=" + CourseID;

        string sql = @"SELECT t.TopicID, t.Title, t.Content, t.ResourceTitle, t.ResourceUrl, t.SequenceOrder,
                        CASE WHEN EXISTS(SELECT 1 FROM TopicProgress p WHERE p.TopicID = t.TopicID AND p.StudentID = @StudentID) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsCompleted
                        FROM LearningPathTopics t
                        WHERE t.CourseID = @CourseID
                        ORDER BY t.SequenceOrder";

        DataTable topics = DBHelper.ExecuteQuery(sql,
            new SqlParameter("@StudentID", studentId),
            new SqlParameter("@CourseID", CourseID));
        topics.Columns.Add("CanComplete", typeof(bool));
        bool earlierLessonsComplete = true;
        int completedCount = 0;
        foreach (DataRow topic in topics.Rows)
        {
            bool isCompleted = Convert.ToBoolean(topic["IsCompleted"]);
            if (isCompleted) completedCount++;
            topic["CanComplete"] = isStudent && canViewContent && !isCompleted && earlierLessonsComplete;
            if (!isCompleted) earlierLessonsComplete = false;
        }

        if (topics.Rows.Count == 0)
        {
            litCourseProgress.Text = "No lessons have been added to this course yet.";
            pnlCourseComplete.Visible = false;
        }
        else if (isStudent && canViewContent && completedCount == topics.Rows.Count)
        {
            litCourseProgress.Text = "All " + topics.Rows.Count + " lessons completed.";
            pnlCourseComplete.Visible = true;
        }
        else
        {
            litCourseProgress.Text = completedCount + " of " + topics.Rows.Count + " lessons completed. Read each lesson in order; its completion button unlocks when you reach the end of the notes.";
            pnlCourseComplete.Visible = false;
        }

        lvTopics.DataSource = topics;
        lvTopics.DataBind();
    }

    private void LoadCourseFeedback()
    {
        DataTable feedback = DBHelper.ExecuteQuery(
            @"SELECT f.Rating, f.FeedbackText, u.FullName AS StudentName, f.CreatedDate
              FROM CourseFeedback f JOIN Users u ON u.UserID = f.StudentID
              WHERE f.CourseID = @CourseID
              ORDER BY f.CreatedDate DESC",
            new SqlParameter("@CourseID", CourseID));
        rptCourseFeedback.DataSource = feedback;
        rptCourseFeedback.DataBind();
        pnlNoCourseFeedback.Visible = feedback.Rows.Count == 0;

        DataTable summary = DBHelper.ExecuteQuery(
            @"SELECT COUNT(*) AS FeedbackCount,
                     AVG(CAST(Rating AS DECIMAL(4,2))) AS AverageRating
              FROM CourseFeedback WHERE CourseID = @CourseID",
            new SqlParameter("@CourseID", CourseID));
        int count = Convert.ToInt32(summary.Rows[0]["FeedbackCount"]);
        litFeedbackSummary.Text = count == 0
            ? "No course feedback yet."
            : Convert.ToDecimal(summary.Rows[0]["AverageRating"]).ToString("0.0") + " / 5 from " + count + (count == 1 ? " student" : " students");

        if (Session["Role"] as string == "Student")
        {
            DataTable mine = DBHelper.ExecuteQuery(
                "SELECT Rating, FeedbackText FROM CourseFeedback WHERE CourseID = @CourseID AND StudentID = @StudentID",
                new SqlParameter("@CourseID", CourseID),
                new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
            if (mine.Rows.Count > 0)
            {
                ddlCourseRating.SelectedValue = mine.Rows[0]["Rating"].ToString();
                txtCourseFeedback.Text = mine.Rows[0]["FeedbackText"].ToString();
                litFeedbackFormHeading.Text = "Update your course feedback";
            }
        }
    }

    protected void btnSubmitCourseFeedback_Click(object sender, EventArgs e)
    {
        if (Session["Role"] as string != "Student")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        int studentId = AuthHelper.CurrentUserId(this);
        object enrolled = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Enrollments WHERE CourseID = @CourseID AND StudentID = @StudentID",
            new SqlParameter("@CourseID", CourseID),
            new SqlParameter("@StudentID", studentId));
        if (Convert.ToInt32(enrolled) == 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }

        int rating;
        string feedback = txtCourseFeedback.Text.Trim();
        if (!Int32.TryParse(ddlCourseRating.SelectedValue, out rating) || rating < 1 || rating > 5 || feedback.Length == 0 || feedback.Length > 1000)
        {
            litFeedbackMessage.Text = "Choose a rating and enter feedback of up to 1,000 characters.";
            return;
        }

        DBHelper.ExecuteNonQuery(
            @"IF EXISTS (SELECT 1 FROM CourseFeedback WHERE CourseID = @CourseID AND StudentID = @StudentID)
                  UPDATE CourseFeedback SET Rating = @Rating, FeedbackText = @FeedbackText, CreatedDate = GETDATE()
                  WHERE CourseID = @CourseID AND StudentID = @StudentID
              ELSE
                  INSERT INTO CourseFeedback (CourseID, StudentID, Rating, FeedbackText)
                  VALUES (@CourseID, @StudentID, @Rating, @FeedbackText)",
            new SqlParameter("@CourseID", CourseID),
            new SqlParameter("@StudentID", studentId),
            new SqlParameter("@Rating", rating),
            new SqlParameter("@FeedbackText", feedback));

        litFeedbackMessage.Text = "Your feedback has been saved.";
        LoadCourseFeedback();
    }

    protected bool CanViewContent() { return canViewContent; }

    protected bool HasResource(object resourceUrl)
    {
        return resourceUrl != null && resourceUrl != DBNull.Value && !String.IsNullOrWhiteSpace(Convert.ToString(resourceUrl));
    }

    protected void lvTopics_ItemCommand(object source, ListViewCommandEventArgs e)
    {
        if (e.CommandName != "Complete") return;
        if (Session["Role"] as string != "Student")
        {
            Response.Redirect("Login.aspx");
            return;
        }

        int topicId = Convert.ToInt32(e.CommandArgument);
        int studentId = AuthHelper.CurrentUserId(this);

        // A student must be enrolled and complete the path in sequence.
        object allowed = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM LearningPathTopics t
              JOIN Enrollments e ON e.CourseID = t.CourseID AND e.StudentID = @StudentID
              WHERE t.TopicID = @TopicID AND t.CourseID = @CourseID
                AND NOT EXISTS (SELECT 1 FROM LearningPathTopics prev
                    WHERE prev.CourseID = t.CourseID AND prev.SequenceOrder < t.SequenceOrder
                      AND NOT EXISTS (SELECT 1 FROM TopicProgress p
                          WHERE p.TopicID = prev.TopicID AND p.StudentID = @StudentID))",
            new SqlParameter("@StudentID", studentId),
            new SqlParameter("@TopicID", topicId),
            new SqlParameter("@CourseID", CourseID));
        if (Convert.ToInt32(allowed) == 0) return;

        DBHelper.ExecuteNonQuery(
            @"IF NOT EXISTS (SELECT 1 FROM TopicProgress WHERE TopicID = @TopicID AND StudentID = @StudentID)
              INSERT INTO TopicProgress (TopicID, StudentID) VALUES (@TopicID, @StudentID)",
            new SqlParameter("@TopicID", topicId),
            new SqlParameter("@StudentID", studentId));

        LoadPath();
    }
}
