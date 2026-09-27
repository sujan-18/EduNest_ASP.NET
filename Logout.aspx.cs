using System;

public partial class Logout : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));

        Session.Clear();
        Session.Abandon();

        // Expire the current session cookie so the next request cannot reuse
        // the authenticated session identifier.
        System.Web.HttpCookie sessionCookie = new System.Web.HttpCookie("ASP.NET_SessionId", "");
        sessionCookie.Expires = DateTime.UtcNow.AddDays(-1);
        sessionCookie.Path = "/";
        Response.Cookies.Add(sessionCookie);

        Response.Redirect("~/Default.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
}
