using System;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class ManageAssignments : System.Web.UI.Page
{
    private int SelectedCourseId { get { return Convert.ToInt32(ddlCourse.SelectedValue); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        if (!IsPostBack)
        {
            LoadCourseDropdown();
            if (ddlCourse.Items.Count > 0) BindGrid();
        }
    }

    private void LoadCourseDropdown()
    {
        string role = Session["Role"] as string;
        var dt = role == "Admin"
            ? DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses ORDER BY Title")
            : DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses WHERE LecturerID = @LecturerID ORDER BY Title",
                new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        ddlCourse.DataSource = dt;
        ddlCourse.DataTextField = "Title";
        ddlCourse.DataValueField = "CourseID";
        ddlCourse.DataBind();
    }

    protected void ddlCourse_Changed(object sender, EventArgs e) { BindGrid(); }

    private void BindGrid()
    {
        if (ddlCourse.Items.Count == 0) return;
        string sql = @"SELECT a.AssignmentID, a.Title, a.Description, a.DueDate,
                        (SELECT COUNT(*) FROM AssignmentSubmissions s WHERE s.AssignmentID = a.AssignmentID) AS SubmissionCount
                        FROM Assignments a WHERE a.CourseID = @CourseID ORDER BY a.DueDate";
        gvAssignments.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@CourseID", SelectedCourseId));
        gvAssignments.DataBind();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || ddlCourse.Items.Count == 0) return;
        DateTime dueDate;
        if (String.IsNullOrWhiteSpace(txtTitle.Text) || !DateTime.TryParse(txtDueDate.Text, out dueDate))
        {
            ShowMessage("Enter an assignment title and a valid due date.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "INSERT INTO Assignments (CourseID, Title, Description, DueDate) VALUES (@CourseID, @Title, @Description, @DueDate)",
            new MySqlParameter("@CourseID", SelectedCourseId),
            new MySqlParameter("@Title", txtTitle.Text.Trim()),
            new MySqlParameter("@Description", txtDescription.Text.Trim()),
            new MySqlParameter("@DueDate", dueDate));

        txtTitle.Text = ""; txtDescription.Text = ""; txtDueDate.Text = "";
        ShowMessage("Assignment added.");
        BindGrid();
    }

    protected void gvAssignments_RowEditing(object sender, GridViewEditEventArgs e) { gvAssignments.EditIndex = e.NewEditIndex; BindGrid(); }
    protected void gvAssignments_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvAssignments.EditIndex = -1; BindGrid(); }

    protected void gvAssignments_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int assignmentId = Convert.ToInt32(gvAssignments.DataKeys[e.RowIndex].Value);
        if (!CanManageAssignment(assignmentId))
        {
            gvAssignments.EditIndex = -1;
            ShowMessage("You can only manage assignments for courses assigned to you.");
            BindGrid();
            return;
        }
        var row = gvAssignments.Rows[e.RowIndex];
        string title = ((TextBox)row.FindControl("txtEditTitle")).Text.Trim();
        string description = ((TextBox)row.FindControl("txtEditDescription")).Text.Trim();
        DateTime dueDate;
        if (string.IsNullOrWhiteSpace(title) || !DateTime.TryParse(((TextBox)row.FindControl("txtEditDueDate")).Text, out dueDate))
        { ShowMessage("Enter an assignment title and a valid due date."); return; }

        DBHelper.ExecuteNonQuery(
            "UPDATE Assignments SET Title = @Title, Description = @Description, DueDate = @DueDate WHERE AssignmentID = @AssignmentID AND CourseID = @CourseID",
            new MySqlParameter("@Title", title),
            new MySqlParameter("@Description", description),
            new MySqlParameter("@DueDate", dueDate),
            new MySqlParameter("@AssignmentID", assignmentId),
            new MySqlParameter("@CourseID", SelectedCourseId));

        gvAssignments.EditIndex = -1;
        ShowMessage("Assignment updated.");
        BindGrid();
    }

    protected void gvAssignments_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int assignmentId = Convert.ToInt32(gvAssignments.DataKeys[e.RowIndex].Value);
        if (!CanManageAssignment(assignmentId))
        {
            ShowMessage("You can only manage assignments for courses assigned to you.");
            BindGrid();
            return;
        }
        DBHelper.ExecuteNonQuery("DELETE FROM Assignments WHERE AssignmentID = @AssignmentID AND CourseID = @CourseID",
            new MySqlParameter("@AssignmentID", assignmentId),
            new MySqlParameter("@CourseID", SelectedCourseId));
        ShowMessage("Assignment deleted.");
        BindGrid();
    }

    private bool CanManageAssignment(int assignmentId)
    {
        object result = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM Assignments a
              JOIN Courses c ON c.CourseID = a.CourseID
              WHERE a.AssignmentID = @AssignmentID AND a.CourseID = @CourseID
                AND (@IsAdmin = 1 OR c.LecturerID = @LecturerID)",
            new MySqlParameter("@AssignmentID", assignmentId),
            new MySqlParameter("@CourseID", SelectedCourseId),
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
