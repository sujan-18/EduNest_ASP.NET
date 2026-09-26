using System;
using EduNest.App_Code;

public partial class Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFeaturedCourses();
        }
    }

    private void LoadFeaturedCourses()
    {
        litCourseCount.Text = Convert.ToInt32(DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Courses")).ToString();
        string sql = @"SELECT c.Title, c.Description, c.Category, c.Level, c.EstimatedHours, u.FullName AS LecturerName
                        FROM Courses c
                        JOIN Users u ON c.LecturerID = u.UserID
                        ORDER BY c.CreatedDate DESC, c.CourseID DESC
                        LIMIT 4";
        rptFeaturedCourses.DataSource = DBHelper.ExecuteQuery(sql);
        rptFeaturedCourses.DataBind();
    }
}
