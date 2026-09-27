using System;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class ManageCourses : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        if (!IsPostBack)
        {
            pnlLecturerPicker.Visible = Session["Role"] as string == "Admin";
            if (pnlLecturerPicker.Visible) LoadLecturers();
            BindGrid();
        }
    }

    private void LoadLecturers()
    {
        ddlLecturer.Items.Clear();
        ddlLecturer.Items.Add(new System.Web.UI.WebControls.ListItem("Select a lecturer", ""));
        ddlLecturer.AppendDataBoundItems = true;
        ddlLecturer.DataSource = DBHelper.ExecuteQuery(
            "SELECT UserID, FullName FROM Users WHERE Role = 'Lecturer' AND IsActive = 1 ORDER BY FullName");
        ddlLecturer.DataTextField = "FullName";
        ddlLecturer.DataValueField = "UserID";
        ddlLecturer.DataBind();
        ddlLecturer.AppendDataBoundItems = false;
    }

    private void BindGrid()
    {
        string role = Session["Role"] as string;
        string sql;

        if (role == "Admin")
        {
            // Admin sees every course in the system
            sql = @"SELECT c.CourseID, c.Title, c.Description, c.Category, c.Level, c.EstimatedHours,
                            COALESCE(u.FullName, '(lecturer unavailable)') AS LecturerName
                     FROM dbo.Courses c LEFT JOIN dbo.Users u ON c.LecturerID = u.UserID
                     ORDER BY c.CreatedDate DESC";
            gvCourses.DataSource = DBHelper.ExecuteQuery(sql);
        }
        else
        {
            // Lecturers only manage their own courses
            sql = @"SELECT c.CourseID, c.Title, c.Description, c.Category, c.Level, c.EstimatedHours, u.FullName AS LecturerName
                     FROM dbo.Courses c JOIN dbo.Users u ON c.LecturerID = u.UserID
                     WHERE c.LecturerID = @LecturerID
                     ORDER BY c.CreatedDate DESC";
            gvCourses.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        }
        gvCourses.DataBind();
    }

    // -------- INSERT --------
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        int estimatedHours;
        if (!TryReadCourseMetadata(ddlCategory.SelectedValue, ddlLevel.SelectedValue, txtEstimatedHours.Text, out estimatedHours))
        {
            ShowMessage("Choose a course category and level, and enter learning hours from 1 to 200.");
            return;
        }

        int lecturerId = AuthHelper.CurrentUserId(this);
        if (Session["Role"] as string == "Admin")
        {
            if (!Int32.TryParse(ddlLecturer.SelectedValue, out lecturerId) ||
                Convert.ToInt32(DBHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM Users WHERE UserID = @LecturerID AND Role = 'Lecturer' AND IsActive = 1",
                    new SqlParameter("@LecturerID", lecturerId))) == 0)
            {
                ShowMessage("Choose an active lecturer to teach this course.");
                return;
            }
        }

        DBHelper.ExecuteNonQuery(
            "INSERT INTO Courses (Title, Description, Category, Level, EstimatedHours, LecturerID) VALUES (@Title, @Description, @Category, @Level, @Hours, @LecturerID)",
            new SqlParameter("@Title", txtTitle.Text.Trim()),
            new SqlParameter("@Description", txtDescription.Text.Trim()),
            new SqlParameter("@Category", ddlCategory.SelectedValue),
            new SqlParameter("@Level", ddlLevel.SelectedValue),
            new SqlParameter("@Hours", estimatedHours),
            new SqlParameter("@LecturerID", lecturerId));

        txtTitle.Text = "";
        txtDescription.Text = "";
        txtEstimatedHours.Text = "12";
        ShowMessage("Course added successfully.");
        BindGrid();
    }

    // -------- UPDATE --------
    protected void gvCourses_RowEditing(object sender, System.Web.UI.WebControls.GridViewEditEventArgs e)
    {
        gvCourses.EditIndex = e.NewEditIndex;
        BindGrid();
    }

    protected void gvCourses_RowCancelingEdit(object sender, System.Web.UI.WebControls.GridViewCancelEditEventArgs e)
    {
        gvCourses.EditIndex = -1;
        BindGrid();
    }

    protected void gvCourses_RowUpdating(object sender, System.Web.UI.WebControls.GridViewUpdateEventArgs e)
    {
        int courseId = Convert.ToInt32(gvCourses.DataKeys[e.RowIndex].Value);
        if (!CanManageCourse(courseId))
        {
            gvCourses.EditIndex = -1;
            ShowMessage("You can only manage courses assigned to you.");
            BindGrid();
            return;
        }
        var row = gvCourses.Rows[e.RowIndex];

        string newTitle = ((System.Web.UI.WebControls.TextBox)row.FindControl("txtEditTitle")).Text.Trim();
        string newDescription = ((System.Web.UI.WebControls.TextBox)row.FindControl("txtEditDescription")).Text.Trim();
        string category = ((System.Web.UI.WebControls.TextBox)row.FindControl("txtEditCategory")).Text.Trim();
        string level = ((System.Web.UI.WebControls.DropDownList)row.FindControl("ddlEditLevel")).SelectedValue;
        string hoursText = ((System.Web.UI.WebControls.TextBox)row.FindControl("txtEditHours")).Text;
        int estimatedHours;

        if (string.IsNullOrEmpty(newTitle) || !TryReadCourseMetadata(category, level, hoursText, out estimatedHours))
        {
            ShowMessage("Enter a course title, valid category and level, and learning hours from 1 to 200.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "UPDATE Courses SET Title = @Title, Description = @Description, Category = @Category, Level = @Level, EstimatedHours = @Hours WHERE CourseID = @CourseID AND (@IsAdmin = 1 OR LecturerID = @LecturerID)",
            new SqlParameter("@Title", newTitle),
            new SqlParameter("@Description", newDescription),
            new SqlParameter("@Category", category),
            new SqlParameter("@Level", level),
            new SqlParameter("@Hours", estimatedHours),
            new SqlParameter("@CourseID", courseId),
            new SqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));

        gvCourses.EditIndex = -1;
        ShowMessage("Course updated successfully.");
        BindGrid();
    }

    // -------- DELETE --------
    protected void gvCourses_RowDeleting(object sender, System.Web.UI.WebControls.GridViewDeleteEventArgs e)
    {
        int courseId = Convert.ToInt32(gvCourses.DataKeys[e.RowIndex].Value);
        if (!CanManageCourse(courseId))
        {
            ShowMessage("You can only manage courses assigned to you.");
            BindGrid();
            return;
        }
        DBHelper.ExecuteNonQuery(
            "DELETE FROM Courses WHERE CourseID = @CourseID AND (@IsAdmin = 1 OR LecturerID = @LecturerID)",
            new SqlParameter("@CourseID", courseId),
            new SqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));

        ShowMessage("Course deleted.");
        BindGrid();
    }

    private bool CanManageCourse(int courseId)
    {
        object result = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Courses WHERE CourseID = @CourseID AND (@IsAdmin = 1 OR LecturerID = @LecturerID)",
            new SqlParameter("@CourseID", courseId),
            new SqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        return Convert.ToInt32(result) > 0;
    }

    private bool TryReadCourseMetadata(string category, string level, string hoursText, out int estimatedHours)
    {
        string[] allowedCategories = { "Web Development", "AI & Machine Learning", "Data & Analytics", "Networking & Infrastructure", "Cloud & DevOps", "Cybersecurity", "Mobile Development", "Product Design", "Web3 & Blockchain" };
        string[] allowedLevels = { "Beginner", "Intermediate", "Advanced" };
        bool validHours = Int32.TryParse(hoursText, out estimatedHours) && estimatedHours >= 1 && estimatedHours <= 200;
        return Array.IndexOf(allowedCategories, category) >= 0 && Array.IndexOf(allowedLevels, level) >= 0 && validHours;
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
