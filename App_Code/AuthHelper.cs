using System.Web.UI;

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
            object role = page.Session["Role"];
            if (role == null)
            {
                page.Response.Redirect("~/Login.aspx");
                return false;
            }

            string roleStr = role.ToString();
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
