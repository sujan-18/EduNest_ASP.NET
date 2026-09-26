using System;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class ManageCourses : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        if (!IsPostBack) BindGrid();
    }

    private void BindGrid()
    {
        string role = Session["Role"] as string;
        string sql;

        if (role == "Admin")
        {
            // Admin sees every course in the system
            sql = @"SELECT c.CourseID, c.Title, c.Description, u.FullName AS LecturerName
                     FROM Courses c JOIN Users u ON c.LecturerID = u.UserID
                     ORDER BY c.CreatedDate DESC";
            gvCourses.DataSource = DBHelper.ExecuteQuery(sql);
        }
        else
        {
            // Lecturers only manage their own courses
            sql = @"SELECT c.CourseID, c.Title, c.Description, u.FullName AS LecturerName
                     FROM Courses c JOIN Users u ON c.LecturerID = u.UserID
                     WHERE c.LecturerID = @LecturerID
                     ORDER BY c.CreatedDate DESC";
            gvCourses.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        }
        gvCourses.DataBind();
    }

    // -------- INSERT --------
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        DBHelper.ExecuteNonQuery(
            "INSERT INTO Courses (Title, Description, LecturerID) VALUES (@Title, @Description, @LecturerID)",
            new MySqlParameter("@Title", txtTitle.Text.Trim()),
            new MySqlParameter("@Description", txtDescription.Text.Trim()),
            new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));

        txtTitle.Text = "";
        txtDescription.Text = "";
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

        if (string.IsNullOrEmpty(newTitle))
        {
            ShowMessage("Title cannot be empty. Update cancelled.");
            gvCourses.EditIndex = -1;
            BindGrid();
            return;
        }

        DBHelper.ExecuteNonQuery(
            "UPDATE Courses SET Title = @Title, Description = @Description WHERE CourseID = @CourseID AND (@IsAdmin = 1 OR LecturerID = @LecturerID)",
            new MySqlParameter("@Title", newTitle),
            new MySqlParameter("@Description", newDescription),
            new MySqlParameter("@CourseID", courseId),
            new MySqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));

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
            new MySqlParameter("@CourseID", courseId),
            new MySqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));

        ShowMessage("Course deleted.");
        BindGrid();
    }

    private bool CanManageCourse(int courseId)
    {
        object result = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Courses WHERE CourseID = @CourseID AND (@IsAdmin = 1 OR LecturerID = @LecturerID)",
            new MySqlParameter("@CourseID", courseId),
            new MySqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        return Convert.ToInt32(result) > 0;
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
