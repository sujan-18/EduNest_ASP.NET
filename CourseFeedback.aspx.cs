using System;
using System.Data;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class CourseFeedbackReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        if (!IsPostBack) BindFeedback();
    }

    private void BindFeedback()
    {
        bool isAdmin = Session["Role"] as string == "Admin";
        int lecturerId = AuthHelper.CurrentUserId(this);
        DataTable feedback = DBHelper.ExecuteQuery(
            @"SELECT c.Title AS CourseTitle, u.FullName AS StudentName, f.Rating, f.FeedbackText, f.CreatedDate
              FROM CourseFeedback f
              JOIN Courses c ON c.CourseID = f.CourseID
              JOIN Users u ON u.UserID = f.StudentID
              WHERE @IsAdmin = 1 OR c.LecturerID = @LecturerID
              ORDER BY f.CreatedDate DESC, f.CourseFeedbackID DESC", ScopeParameters(isAdmin, lecturerId));
        gvFeedback.DataSource = feedback;
        gvFeedback.DataBind();

        object count = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM CourseFeedback f JOIN Courses c ON c.CourseID = f.CourseID
              WHERE @IsAdmin = 1 OR c.LecturerID = @LecturerID", ScopeParameters(isAdmin, lecturerId));
        object average = DBHelper.ExecuteScalar(
            @"SELECT AVG(CAST(f.Rating AS DECIMAL(4,2))) FROM CourseFeedback f JOIN Courses c ON c.CourseID = f.CourseID
              WHERE @IsAdmin = 1 OR c.LecturerID = @LecturerID", ScopeParameters(isAdmin, lecturerId));
        litFeedbackCount.Text = Convert.ToInt32(count).ToString();
        litAverageRating.Text = average == DBNull.Value ? "N/A" : Convert.ToDecimal(average).ToString("0.0");
    }

    private SqlParameter[] ScopeParameters(bool isAdmin, int lecturerId)
    {
        return new[] {
            new SqlParameter("@IsAdmin", isAdmin),
            new SqlParameter("@LecturerID", lecturerId)
        };
    }
}
