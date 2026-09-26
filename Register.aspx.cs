using System;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class Register : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e) { }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        // Server-side validation runs automatically via the validator controls
        // (RequiredFieldValidator / RegularExpressionValidator / CompareValidator)
        // declared on the .aspx page. This check re-confirms it server-side.
        if (!Page.IsValid) return;

        string fullName = txtFullName.Text.Trim();
        string email = txtEmail.Text.Trim().ToLower();
        string password = txtPassword.Text;
        // Public registration must never grant privileged roles. Staff accounts
        // are provisioned by an administrator through Manage Users.
        const string role = "Student";

        // Prevent duplicate email registration
        object existing = DBHelper.ExecuteScalar(
            "SELECT UserID FROM Users WHERE Email = @Email",
            new MySqlParameter("@Email", email));

        if (existing != null)
        {
            ShowError("An account with this email already exists. Please log in instead.");
            return;
        }

        string salt = PasswordHelper.GenerateSalt();
        string hash = PasswordHelper.HashPassword(password, salt);

        DBHelper.ExecuteNonQuery(
            @"INSERT INTO Users (FullName, Email, PasswordHash, PasswordSalt, Role)
              VALUES (@FullName, @Email, @Hash, @Salt, @Role)",
            new MySqlParameter("@FullName", fullName),
            new MySqlParameter("@Email", email),
            new MySqlParameter("@Hash", hash),
            new MySqlParameter("@Salt", salt),
            new MySqlParameter("@Role", role));

        Response.Redirect("Login.aspx?registered=1");
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
