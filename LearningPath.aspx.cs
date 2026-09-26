using System;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
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
        if (!IsPostBack) LoadPath();
    }

    private void LoadPath()
    {
        string role = Session["Role"] as string;
        if (role == "Student")
        {
            canViewContent = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Enrollments WHERE CourseID = @CourseID AND StudentID = @UserID",
                new MySqlParameter("@CourseID", CourseID), new MySqlParameter("@UserID", AuthHelper.CurrentUserId(this)))) > 0;
        }
        else if (role == "Admin") canViewContent = true;
        else if (role == "Lecturer")
        {
            canViewContent = Convert.ToInt32(DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Courses WHERE CourseID = @CourseID AND LecturerID = @UserID",
                new MySqlParameter("@CourseID", CourseID), new MySqlParameter("@UserID", AuthHelper.CurrentUserId(this)))) > 0;
        }
        object title = DBHelper.ExecuteScalar("SELECT Title FROM Courses WHERE CourseID = @CourseID",
            new MySqlParameter("@CourseID", CourseID));
        litCourseTitle.Text = title != null ? Server.HtmlEncode(title.ToString()) : "Course";

        bool isStudent = Session["Role"] as string == "Student";
        int studentId = isStudent ? AuthHelper.CurrentUserId(this) : 0;

        string sql = @"SELECT t.TopicID, t.Title, t.Content, t.SequenceOrder,
                        EXISTS(SELECT 1 FROM TopicProgress p WHERE p.TopicID = t.TopicID AND p.StudentID = @StudentID) AS IsCompleted
                        FROM LearningPathTopics t
                        WHERE t.CourseID = @CourseID
                        ORDER BY t.SequenceOrder";

        lvTopics.DataSource = DBHelper.ExecuteQuery(sql,
            new MySqlParameter("@StudentID", studentId),
            new MySqlParameter("@CourseID", CourseID));
        lvTopics.DataBind();
    }

    protected bool CanViewContent() { return canViewContent; }

    protected bool ShowCompleteButton(object isCompletedObj)
    {
        bool isCompleted = Convert.ToBoolean(isCompletedObj);
        return canViewContent && (Session["Role"] as string) == "Student" && !isCompleted;
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
            new MySqlParameter("@StudentID", studentId),
            new MySqlParameter("@TopicID", topicId),
            new MySqlParameter("@CourseID", CourseID));
        if (Convert.ToInt32(allowed) == 0) return;

        DBHelper.ExecuteNonQuery(
            "INSERT IGNORE INTO TopicProgress (TopicID, StudentID) VALUES (@TopicID, @StudentID)",
            new MySqlParameter("@TopicID", topicId),
            new MySqlParameter("@StudentID", studentId));

        LoadPath();
    }
}
