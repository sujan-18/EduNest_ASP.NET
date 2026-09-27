using System;
using System.Data;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class SubmitAssignment : System.Web.UI.Page
{
    private int AssignmentID
    {
        get
        {
            int assignmentId;
            return Int32.TryParse(Request.QueryString["AssignmentID"], out assignmentId) ? assignmentId : 0;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (AssignmentID <= 0) { Response.Redirect("Courses.aspx"); return; }
        if (!IsPostBack) LoadAssignment();
    }

    private void LoadAssignment()
    {
        DataTable assignments = DBHelper.ExecuteQuery(
            @"SELECT a.Title, a.Description, a.DueDate FROM Assignments a
              JOIN Enrollments e ON e.CourseID = a.CourseID
              WHERE a.AssignmentID = @AssignmentID AND e.StudentID = @StudentID",
            new SqlParameter("@AssignmentID", AssignmentID),
            new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
        if (assignments.Rows.Count == 0)
        {
            Response.Redirect("Assignments.aspx");
            return;
        }
        DataRow assignment = assignments.Rows[0];
        bool deadlinePassed = Convert.ToDateTime(assignment["DueDate"]).Date < DateTime.Today;

        litTitle.Text = Server.HtmlEncode(assignment["Title"].ToString());
        litDescription.Text = Server.HtmlEncode(assignment["Description"].ToString());

        DataTable existing = DBHelper.ExecuteQuery(
            "SELECT SubmissionText, Grade, Feedback FROM AssignmentSubmissions WHERE AssignmentID = @AssignmentID AND StudentID = @StudentID",
            new SqlParameter("@AssignmentID", AssignmentID),
            new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));

        if (existing.Rows.Count > 0)
        {
            DataRow submission = existing.Rows[0];
            txtSubmission.Text = submission["SubmissionText"].ToString();
            if (submission["Grade"] != DBNull.Value || submission["Feedback"] != DBNull.Value)
            {
                pnlReview.Visible = true;
                litGrade.Text = submission["Grade"] == DBNull.Value ? "Pending" : Server.HtmlEncode(Convert.ToDecimal(submission["Grade"]).ToString("0.##")) + " / 100";
                litFeedback.Text = submission["Feedback"] == DBNull.Value ? "No written feedback was added." : Server.HtmlEncode(submission["Feedback"].ToString()).Replace("\r\n", "<br />").Replace("\n", "<br />");
            }
        }
        else if (deadlinePassed)
        {
            Response.Redirect("Assignments.aspx");
            return;
        }

        if (deadlinePassed)
        {
            pnlSubmissionForm.Visible = false;
            pnlClosed.Visible = true;
            litClosed.Text = "The submission deadline has passed. You can still review your saved submission and lecturer feedback on this page.";
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int studentId = AuthHelper.CurrentUserId(this);

        object eligible = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM Assignments a JOIN Enrollments e ON e.CourseID = a.CourseID
              WHERE a.AssignmentID = @AssignmentID AND e.StudentID = @StudentID AND a.DueDate >= CAST(GETDATE() AS DATE)",
            new SqlParameter("@AssignmentID", AssignmentID), new SqlParameter("@StudentID", studentId));
        if (Convert.ToInt32(eligible) == 0) { Response.Redirect("Assignments.aspx"); return; }

        // Update an existing submission, or insert the first one.
        int updated = DBHelper.ExecuteNonQuery(
            @"UPDATE AssignmentSubmissions
              SET SubmissionText = @Text, Grade = NULL, Feedback = NULL, SubmittedDate = GETDATE()
              WHERE AssignmentID = @AssignmentID AND StudentID = @StudentID",
            new SqlParameter("@AssignmentID", AssignmentID),
            new SqlParameter("@StudentID", studentId),
            new SqlParameter("@Text", txtSubmission.Text.Trim()));
        if (updated == 0)
            DBHelper.ExecuteNonQuery(
                @"INSERT INTO AssignmentSubmissions (AssignmentID, StudentID, SubmissionText)
                  VALUES (@AssignmentID, @StudentID, @Text)",
                new SqlParameter("@AssignmentID", AssignmentID),
                new SqlParameter("@StudentID", studentId),
                new SqlParameter("@Text", txtSubmission.Text.Trim()));

        pnlMessage.Visible = true;
        litMessage.Text = "Your assignment has been submitted.";
        pnlReview.Visible = false;
    }
}
