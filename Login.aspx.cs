using System;
using System.Data;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class Login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && AuthHelper.IsKnownRole(Session["Role"] as string))
        {
            Response.Redirect(AuthHelper.DashboardForRole(Session["Role"] as string));
            return;
        }
        if (!IsPostBack && Session["Role"] != null) Session.Clear();
        if (!IsPostBack && Request.QueryString["registered"] == "1")
        {
            pnlSuccess.Visible = true;
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string email = txtEmail.Text.Trim().ToLower();
        string password = txtPassword.Text;

        DataTable dt = DBHelper.ExecuteQuery(
            "SELECT UserID, FullName, PasswordHash, PasswordSalt, Role, IsActive FROM Users WHERE Email = @Email",
            new MySqlParameter("@Email", email));

        if (dt.Rows.Count == 0)
        {
            ShowError("No account found with that email.");
            return;
        }

        DataRow row = dt.Rows[0];
        string storedHash = row["PasswordHash"].ToString();
        string salt = row["PasswordSalt"].ToString();
        bool isActive = Convert.ToBoolean(row["IsActive"]);

        if (!isActive)
        {
            ShowError("This account has been deactivated. Contact an administrator.");
            return;
        }

        if (!PasswordHelper.VerifyPassword(password, salt, storedHash))
        {
            ShowError("Incorrect password.");
            return;
        }

        // Upgrade accounts made with the original fast SHA-256 hash after a
        // successful login; new and migrated passwords use PBKDF2.
        if (!storedHash.StartsWith("pbkdf2$", StringComparison.Ordinal))
        {
            string upgradedSalt = PasswordHelper.GenerateSalt();
            DBHelper.ExecuteNonQuery(
                "UPDATE Users SET PasswordHash = @Hash, PasswordSalt = @Salt WHERE UserID = @UserID",
                new MySqlParameter("@Hash", PasswordHelper.HashPassword(password, upgradedSalt)),
                new MySqlParameter("@Salt", upgradedSalt),
                new MySqlParameter("@UserID", row["UserID"]));
        }

        // Successful login: start the session
        Session["UserID"] = Convert.ToInt32(row["UserID"]);
        Session["FullName"] = row["FullName"].ToString();
        Session["Role"] = row["Role"].ToString();

        Response.Redirect(AuthHelper.DashboardForRole(row["Role"].ToString()));
    }

    private void ShowError(string message)
    {
        pnlError.Visible = true;
        litError.Text = Server.HtmlEncode(message);
    }
}
