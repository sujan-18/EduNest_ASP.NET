using System;

public partial class SiteMaster : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string role = Session["Role"] as string;
        bool signedIn = role == "Student" || role == "Lecturer" || role == "Admin";

        if (!signedIn) return;

        appFrame.Attributes["class"] = "app-frame is-authenticated";
        phPublicHeader.Visible = false;
        phPublicFooter.Visible = false;
        phAppSidebar.Visible = true;
        phAppTopbar.Visible = true;

        string name = Session["FullName"] as string ?? "EduNest member";
        lblSidebarName.Text = Server.HtmlEncode(name);
        lblTopbarName.Text = Server.HtmlEncode(name);
        lblSidebarRole.Text = Server.HtmlEncode(role);
        lblTopbarRole.Text = Server.HtmlEncode(role);

        string[] words = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        string initials = words.Length == 0 ? "EN" : words[0].Substring(0, 1).ToUpperInvariant();
        if (words.Length > 1) initials += words[words.Length - 1].Substring(0, 1).ToUpperInvariant();
        litInitials.Text = Server.HtmlEncode(initials);

        switch (role)
        {
            case "Student": phStudent.Visible = true; break;
            case "Lecturer": phLecturer.Visible = true; break;
            case "Admin": phAdmin.Visible = true; break;
        }
    }
}
