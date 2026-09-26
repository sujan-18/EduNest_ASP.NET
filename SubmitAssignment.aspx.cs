using System;
using System.Data;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class SubmitAssignment : System.Web.UI.Page
{
    private int AssignmentID { get { return Convert.ToInt32(Request.QueryString["AssignmentID"]); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (!IsPostBack) LoadAssignment();
    }

    private void LoadAssignment()
    {
        DataTable assignments = DBHelper.ExecuteQuery(
            @"SELECT a.Title, a.Description FROM Assignments a
              JOIN Enrollments e ON e.CourseID = a.CourseID
              WHERE a.AssignmentID = @AssignmentID AND e.StudentID = @StudentID AND a.DueDate >= CURDATE()",
            new MySqlParameter("@AssignmentID", AssignmentID),
            new MySqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
        if (assignments.Rows.Count == 0)
        {
            Response.Redirect("Assignments.aspx");
            return;
        }
        DataRow assignment = assignments.Rows[0];

        litTitle.Text = Server.HtmlEncode(assignment["Title"].ToString());
        litDescription.Text = Server.HtmlEncode(assignment["Description"].ToString());

        DataTable existing = DBHelper.ExecuteQuery(
            "SELECT SubmissionText FROM AssignmentSubmissions WHERE AssignmentID = @AssignmentID AND StudentID = @StudentID",
            new MySqlParameter("@AssignmentID", AssignmentID),
            new MySqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));

        if (existing.Rows.Count > 0)
        {
            txtSubmission.Text = existing.Rows[0]["SubmissionText"].ToString();
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int studentId = AuthHelper.CurrentUserId(this);

        object eligible = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM Assignments a JOIN Enrollments e ON e.CourseID = a.CourseID
              WHERE a.AssignmentID = @AssignmentID AND e.StudentID = @StudentID AND a.DueDate >= CURDATE()",
            new MySqlParameter("@AssignmentID", AssignmentID), new MySqlParameter("@StudentID", studentId));
        if (Convert.ToInt32(eligible) == 0) { Response.Redirect("Assignments.aspx"); return; }

        // Upsert: replace the previous submission if the student already submitted once
        DBHelper.ExecuteNonQuery(
            @"INSERT INTO AssignmentSubmissions (AssignmentID, StudentID, SubmissionText)
              VALUES (@AssignmentID, @StudentID, @Text)
              ON DUPLICATE KEY UPDATE SubmissionText = @Text, SubmittedDate = CURRENT_TIMESTAMP",
            new MySqlParameter("@AssignmentID", AssignmentID),
            new MySqlParameter("@StudentID", studentId),
            new MySqlParameter("@Text", txtSubmission.Text.Trim()));

        pnlMessage.Visible = true;
        litMessage.Text = "Your assignment has been submitted.";
    }
}
