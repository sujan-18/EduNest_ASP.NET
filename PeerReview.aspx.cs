using System;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class PeerReview : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (!IsPostBack)
        {
            LoadSubmissionsToReview();
            LoadMyReviews();
        }
    }

    private void LoadSubmissionsToReview()
    {
        int studentId = AuthHelper.CurrentUserId(this);

        // Show submissions from courses the student is enrolled in, excluding
        // their own submission and anything they've already reviewed.
        string sql = @"SELECT s.SubmissionID, a.Title AS AssignmentTitle, u.FullName AS StudentName, s.SubmissionText
                        FROM AssignmentSubmissions s
                        JOIN Assignments a ON s.AssignmentID = a.AssignmentID
                        JOIN Users u ON s.StudentID = u.UserID
                        JOIN Enrollments e ON e.CourseID = a.CourseID AND e.StudentID = @StudentID
                        WHERE s.StudentID <> @StudentID
                          AND NOT EXISTS (SELECT 1 FROM PeerReviews r WHERE r.SubmissionID = s.SubmissionID AND r.ReviewerID = @StudentID)
                        ORDER BY s.SubmittedDate DESC";

        var dt = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
        rptSubmissions.DataSource = dt;
        rptSubmissions.DataBind();
    }

    private void LoadMyReviews()
    {
        int studentId = AuthHelper.CurrentUserId(this);
        string sql = @"SELECT a.Title AS AssignmentTitle, r.Feedback, r.Rating
                        FROM PeerReviews r
                        JOIN AssignmentSubmissions s ON r.SubmissionID = s.SubmissionID
                        JOIN Assignments a ON s.AssignmentID = a.AssignmentID
                        WHERE r.ReviewerID = @StudentID ORDER BY r.ReviewDate DESC";
        gvMyReviews.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@StudentID", studentId));
        gvMyReviews.DataBind();
    }

    protected void rptSubmissions_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName != "Review") return;

        int submissionId = Convert.ToInt32(e.CommandArgument);
        TextBox txtFeedback = (TextBox)e.Item.FindControl("txtFeedback");
        DropDownList ddlRating = (DropDownList)e.Item.FindControl("ddlRating");

        if (string.IsNullOrWhiteSpace(txtFeedback.Text))
        {
            ShowMessage("Please write some feedback before submitting.");
            LoadSubmissionsToReview();
            return;
        }

        int reviewerId = AuthHelper.CurrentUserId(this);
        object eligible = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM AssignmentSubmissions s
              JOIN Assignments a ON a.AssignmentID = s.AssignmentID
              JOIN Enrollments e ON e.CourseID = a.CourseID AND e.StudentID = @ReviewerID
              WHERE s.SubmissionID = @SubmissionID AND s.StudentID <> @ReviewerID
                AND EXISTS (SELECT 1 FROM Enrollments author_enrollment
                    WHERE author_enrollment.CourseID = a.CourseID AND author_enrollment.StudentID = s.StudentID)
                AND NOT EXISTS (SELECT 1 FROM PeerReviews r
                    WHERE r.SubmissionID = s.SubmissionID AND r.ReviewerID = @ReviewerID)",
            new SqlParameter("@SubmissionID", submissionId), new SqlParameter("@ReviewerID", reviewerId));
        if (Convert.ToInt32(eligible) == 0)
        {
            ShowMessage("That submission is no longer available for review.");
            LoadSubmissionsToReview();
            return;
        }

        int rating;
        if (!int.TryParse(ddlRating.SelectedValue, out rating) || rating < 1 || rating > 5)
        {
            ShowMessage("Choose a rating from 1 to 5.");
            return;
        }
        DBHelper.ExecuteNonQuery(
            @"IF NOT EXISTS (SELECT 1 FROM PeerReviews WHERE SubmissionID = @SubmissionID AND ReviewerID = @ReviewerID)
              INSERT INTO PeerReviews (SubmissionID, ReviewerID, Feedback, Rating) VALUES (@SubmissionID, @ReviewerID, @Feedback, @Rating)",
            new SqlParameter("@SubmissionID", submissionId),
            new SqlParameter("@ReviewerID", reviewerId),
            new SqlParameter("@Feedback", txtFeedback.Text.Trim()),
            new SqlParameter("@Rating", Convert.ToInt32(ddlRating.SelectedValue)));

        ShowMessage("Review submitted. Thank you for helping a classmate!");
        LoadSubmissionsToReview();
        LoadMyReviews();
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
