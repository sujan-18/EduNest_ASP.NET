using System;
using System.Data;
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
        DataTable courses = DBHelper.ExecuteQuery(sql);
        courses.Columns.Add("ImagePath", typeof(string));
        foreach (DataRow course in courses.Rows)
            course["ImagePath"] = ResolveUrl(CourseVisualHelper.GetImagePath(course["Category"].ToString()));
        rptFeaturedCourses.DataSource = courses;
        rptFeaturedCourses.DataBind();
    }
}
