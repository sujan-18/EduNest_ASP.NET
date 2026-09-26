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

            page.Response.Redirect("~/Default.aspx");
            return false;
        }

        public static int CurrentUserId(Page page)
        {
            return (int)page.Session["UserID"];
        }
    }
}
