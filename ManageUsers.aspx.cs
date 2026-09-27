using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class ManageUsers : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Admin")) return;
        if (!IsPostBack) BindGrid();
    }

    private void BindGrid()
    {
        gvUsers.DataSource = DBHelper.ExecuteQuery(
            "SELECT UserID, FullName, Email, Role, IsActive FROM Users ORDER BY CreatedDate DESC");
        gvUsers.DataBind();
    }

    // Pre-select the correct role in the edit dropdown once the row is rendered in edit mode
    protected void gvUsers_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowState == DataControlRowState.Edit || e.Row.RowState == (DataControlRowState.Edit | DataControlRowState.Alternate))
        {
            DropDownList ddl = (DropDownList)e.Row.FindControl("ddlEditRole");
            if (ddl != null)
            {
                string currentRole = DataBinder.Eval(e.Row.DataItem, "Role").ToString();
                ddl.SelectedValue = currentRole;
            }
        }
    }

    // -------- INSERT --------
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string email = txtEmail.Text.Trim().ToLower();
        object existing = DBHelper.ExecuteScalar("SELECT UserID FROM Users WHERE Email = @Email",
            new SqlParameter("@Email", email));

        if (existing != null)
        {
            ShowMessage("A user with that email already exists.");
            return;
        }

        string salt = PasswordHelper.GenerateSalt();
        string hash = PasswordHelper.HashPassword(txtPassword.Text, salt);

        DBHelper.ExecuteNonQuery(
            "INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role) VALUES (@Name, @Email, @Hash, @Salt, @Role)",
            new SqlParameter("@Name", txtFullName.Text.Trim()),
            new SqlParameter("@Email", email),
            new SqlParameter("@Hash", hash),
            new SqlParameter("@Salt", salt),
            new SqlParameter("@Role", ddlRole.SelectedValue));

        txtFullName.Text = ""; txtEmail.Text = ""; txtPassword.Text = "";
        ShowMessage("User created successfully.");
        BindGrid();
    }

    // -------- UPDATE --------
    protected void gvUsers_RowEditing(object sender, GridViewEditEventArgs e) { gvUsers.EditIndex = e.NewEditIndex; BindGrid(); }
    protected void gvUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvUsers.EditIndex = -1; BindGrid(); }

    protected void gvUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int userId = Convert.ToInt32(gvUsers.DataKeys[e.RowIndex].Value);
        var row = gvUsers.Rows[e.RowIndex];

        string newName = ((TextBox)row.Cells[0].Controls[0]).Text.Trim(); // BoundField in edit mode renders a TextBox
        string newRole = ((DropDownList)row.FindControl("ddlEditRole")).SelectedValue;
        bool isActive = ((CheckBox)row.FindControl("chkActive")).Checked;

        // Prevent an admin from locking themselves out by demoting/deactivating their own account
        if (userId == AuthHelper.CurrentUserId(this) && (newRole != "Admin" || !isActive))
        {
            ShowMessage("You cannot change your own role or deactivate your own account.");
            gvUsers.EditIndex = -1;
            BindGrid();
            return;
        }

        DBHelper.ExecuteNonQuery(
            "UPDATE Users SET FullName = @Name, Role = @Role, IsActive = @Active WHERE UserID = @UserID",
            new SqlParameter("@Name", newName),
            new SqlParameter("@Role", newRole),
            new SqlParameter("@Active", isActive),
            new SqlParameter("@UserID", userId));

        gvUsers.EditIndex = -1;
        ShowMessage("User updated.");
        BindGrid();
    }

    // -------- DELETE --------
    protected void gvUsers_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int userId = Convert.ToInt32(gvUsers.DataKeys[e.RowIndex].Value);

        if (userId == AuthHelper.CurrentUserId(this))
        {
            ShowMessage("You cannot delete your own account while logged in.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            @"BEGIN TRY
                  BEGIN TRANSACTION;
                  DELETE FROM PeerReviews WHERE ReviewerID = @UserID;
                  DELETE FROM CourseFeedback WHERE StudentID = @UserID;
                  DELETE FROM StudySessionParticipants WHERE StudentID = @UserID;
                  DELETE FROM TopicProgress WHERE StudentID = @UserID;
                  DELETE FROM QuizAttempts WHERE StudentID = @UserID;
                  DELETE FROM AssignmentSubmissions WHERE StudentID = @UserID;
                  DELETE FROM Enrollments WHERE StudentID = @UserID;
                  DELETE FROM Users WHERE UserID = @UserID;
                  COMMIT TRANSACTION;
              END TRY
              BEGIN CATCH
                  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                  THROW;
              END CATCH;",
            new SqlParameter("@UserID", userId));
        ShowMessage("User and their linked student activity were deleted.");
        BindGrid();
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
