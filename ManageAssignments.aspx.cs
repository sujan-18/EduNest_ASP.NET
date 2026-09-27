using System;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
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
                new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        ddlCourse.DataSource = dt;
        ddlCourse.DataTextField = "Title";
        ddlCourse.DataValueField = "CourseID";
        ddlCourse.DataBind();
    }

    protected void ddlCourse_Changed(object sender, EventArgs e) { BindGrid(); }

    private void BindGrid()
    {
        if (ddlCourse.Items.Count == 0) return;
        if (!CanManageCourse(SelectedCourseId)) return;
        string sql = @"SELECT a.AssignmentID, a.Title, a.Description, a.DueDate,
                        (SELECT COUNT(*) FROM AssignmentSubmissions s WHERE s.AssignmentID = a.AssignmentID) AS SubmissionCount
                        FROM Assignments a WHERE a.CourseID = @CourseID ORDER BY a.DueDate";
        gvAssignments.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@CourseID", SelectedCourseId));
        gvAssignments.DataBind();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || ddlCourse.Items.Count == 0) return;
        if (!CanManageCourse(SelectedCourseId)) { ShowMessage("You can only manage assignments for courses assigned to you."); return; }
        DateTime dueDate;
        if (String.IsNullOrWhiteSpace(txtTitle.Text) || !DateTime.TryParse(txtDueDate.Text, out dueDate))
        {
            ShowMessage("Enter an assignment title and a valid due date.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "INSERT INTO Assignments (CourseID, Title, Description, DueDate) VALUES (@CourseID, @Title, @Description, @DueDate)",
            new SqlParameter("@CourseID", SelectedCourseId),
            new SqlParameter("@Title", txtTitle.Text.Trim()),
            new SqlParameter("@Description", txtDescription.Text.Trim()),
            new SqlParameter("@DueDate", dueDate));

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
            new SqlParameter("@Title", title),
            new SqlParameter("@Description", description),
            new SqlParameter("@DueDate", dueDate),
            new SqlParameter("@AssignmentID", assignmentId),
            new SqlParameter("@CourseID", SelectedCourseId));

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
            new SqlParameter("@AssignmentID", assignmentId),
            new SqlParameter("@CourseID", SelectedCourseId));
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
            new SqlParameter("@AssignmentID", assignmentId),
            new SqlParameter("@CourseID", SelectedCourseId),
            new SqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        return Convert.ToInt32(result) > 0;
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

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
