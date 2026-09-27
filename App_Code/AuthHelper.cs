using System.Web.UI;
using System.Data;
using System.Data.SqlClient;

namespace EduNest.App_Code
{
    /// <summary>
    /// Simple session-based role guard. Call RequireRole(this, "Student")
    /// (or with multiple allowed roles) at the top of Page_Load on every
    /// page that must not be reachable by the wrong user type.
    /// </summary>
    public static class AuthHelper
    {
        public static string DashboardForRole(string role)
        {
            switch (role)
            {
                case "Student": return "~/StudentDashboard.aspx";
                case "Lecturer": return "~/LecturerDashboard.aspx";
                case "Admin": return "~/AdminDashboard.aspx";
                default: return "~/Login.aspx";
            }
        }

        public static bool IsKnownRole(string role)
        {
            return role == "Student" || role == "Lecturer" || role == "Admin";
        }

        public static bool RequireRole(Page page, params string[] allowedRoles)
        {
            object sessionUserId = page.Session["UserID"];
            int userId;
            if (sessionUserId == null || !int.TryParse(sessionUserId.ToString(), out userId))
            {
                page.Session.Clear();
                page.Response.Redirect("~/Login.aspx");
                return false;
            }

            DataTable account = DBHelper.ExecuteQuery(
                "SELECT FullName, Role, IsActive FROM Users WHERE UserID = @UserID",
                new SqlParameter("@UserID", userId));
            if (account.Rows.Count == 0 || !System.Convert.ToBoolean(account.Rows[0]["IsActive"]))
            {
                page.Session.Clear();
                page.Session.Abandon();
                page.Response.Redirect("~/Login.aspx");
                return false;
            }

            string roleStr = account.Rows[0]["Role"].ToString();
            page.Session["Role"] = roleStr;
            page.Session["FullName"] = account.Rows[0]["FullName"].ToString();
            if (!IsKnownRole(roleStr))
            {
                page.Session.Clear();
                page.Response.Redirect("~/Login.aspx");
                return false;
            }

            foreach (string allowed in allowedRoles)
            {
                if (roleStr == allowed) return true;
            }

            page.Response.Redirect(DashboardForRole(roleStr));
            return false;
        }

        public static int CurrentUserId(Page page)
        {
            return (int)page.Session["UserID"];
        }
    }
}
