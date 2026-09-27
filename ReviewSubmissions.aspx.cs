using System;
using System.Globalization;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class ReviewSubmissions : System.Web.UI.Page
{
    private int SelectedCourseId
    {
        get
        {
            int courseId;
            return Int32.TryParse(ddlCourse.SelectedValue, out courseId) ? courseId : 0;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        if (!IsPostBack)
        {
            LoadCourses();
            BindGrid();
        }
    }

    private void LoadCourses()
    {
        string role = Session["Role"] as string;
        var courses = role == "Admin"
            ? DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses ORDER BY Title")
            : DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses WHERE LecturerID=@LecturerID ORDER BY Title",
                new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListItem("All my courses", "0"));
        ddlCourse.AppendDataBoundItems = true;
        ddlCourse.DataSource = courses;
        ddlCourse.DataTextField = "Title";
        ddlCourse.DataValueField = "CourseID";
        ddlCourse.DataBind();
    }

    protected void ddlCourse_Changed(object sender, EventArgs e)
    {
        gvSubmissions.PageIndex = 0;
        BindGrid();
    }

    private void BindGrid()
    {
        int lecturerId = AuthHelper.CurrentUserId(this);
        bool isAdmin = Session["Role"] as string == "Admin";
        string sql = @"SELECT s.SubmissionID, c.Title AS CourseTitle, a.Title AS AssignmentTitle,
                              student.FullName AS StudentName, s.SubmissionText, s.Grade, s.Feedback, s.SubmittedDate
                       FROM AssignmentSubmissions s
                       JOIN Assignments a ON a.AssignmentID = s.AssignmentID
                       JOIN Courses c ON c.CourseID = a.CourseID
                       JOIN Users student ON student.UserID = s.StudentID
                       WHERE (@IsAdmin = 1 OR c.LecturerID = @LecturerID)
                         AND (@CourseID = 0 OR c.CourseID = @CourseID)
                       ORDER BY CASE WHEN s.Grade IS NULL THEN 1 ELSE 0 END DESC, s.SubmittedDate DESC";
        gvSubmissions.DataSource = DBHelper.ExecuteQuery(sql,
            new SqlParameter("@IsAdmin", isAdmin),
            new SqlParameter("@LecturerID", lecturerId),
            new SqlParameter("@CourseID", SelectedCourseId));
        gvSubmissions.DataBind();
    }

    protected void gvSubmissions_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvSubmissions.PageIndex = e.NewPageIndex;
        BindGrid();
    }

    protected void gvSubmissions_RowEditing(object sender, GridViewEditEventArgs e)
    {
        gvSubmissions.EditIndex = e.NewEditIndex;
        BindGrid();
    }

    protected void gvSubmissions_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvSubmissions.EditIndex = -1;
        BindGrid();
    }

    protected void gvSubmissions_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int submissionId = Convert.ToInt32(gvSubmissions.DataKeys[e.RowIndex].Value);
        int lecturerId = AuthHelper.CurrentUserId(this);
        bool isAdmin = Session["Role"] as string == "Admin";
        object allowed = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM AssignmentSubmissions s
              JOIN Assignments a ON a.AssignmentID = s.AssignmentID
              JOIN Courses c ON c.CourseID = a.CourseID
              WHERE s.SubmissionID=@SubmissionID AND (@IsAdmin=1 OR c.LecturerID=@LecturerID)",
            new SqlParameter("@SubmissionID", submissionId),
            new SqlParameter("@IsAdmin", isAdmin),
            new SqlParameter("@LecturerID", lecturerId));
        if (Convert.ToInt32(allowed) == 0)
        {
            gvSubmissions.EditIndex = -1;
            ShowMessage("That submission is not in a course you can review.");
            BindGrid();
            return;
        }

        GridViewRow row = gvSubmissions.Rows[e.RowIndex];
        string gradeText = ((TextBox)row.FindControl("txtEditGrade")).Text.Trim();
        string feedback = ((TextBox)row.FindControl("txtEditFeedback")).Text.Trim();
        object gradeValue = DBNull.Value;
        if (gradeText.Length > 0)
        {
            decimal grade;
            if (!Decimal.TryParse(gradeText, NumberStyles.Number, CultureInfo.CurrentCulture, out grade) &&
                !Decimal.TryParse(gradeText, NumberStyles.Number, CultureInfo.InvariantCulture, out grade))
            {
                ShowMessage("Enter a grade from 0 to 100, or leave it blank.");
                return;
            }
            if (grade < 0 || grade > 100 || Decimal.Round(grade, 2) != grade)
            {
                ShowMessage("Grades must be from 0 to 100 with at most two decimal places.");
                return;
            }
            gradeValue = grade;
        }

        DBHelper.ExecuteNonQuery(
            "UPDATE AssignmentSubmissions SET Grade=@Grade, Feedback=@Feedback WHERE SubmissionID=@SubmissionID",
            new SqlParameter("@Grade", gradeValue),
            new SqlParameter("@Feedback", feedback.Length == 0 ? (object)DBNull.Value : feedback),
            new SqlParameter("@SubmissionID", submissionId));

        gvSubmissions.EditIndex = -1;
        ShowMessage("Review saved. The student can now see the grade and feedback.");
        BindGrid();
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
