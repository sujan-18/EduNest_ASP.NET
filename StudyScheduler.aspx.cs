using System;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class StudyScheduler : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        if (!IsPostBack) LoadSessions();
    }

    private void LoadSessions()
    {
        int userId = AuthHelper.CurrentUserId(this);

        string sql = @"SELECT s.SessionID, s.Title, s.SessionDate, s.SessionTime, s.Description,
                        u.FullName AS HostName,
                        (SELECT COUNT(*) FROM StudySessionParticipants p WHERE p.SessionID = s.SessionID) AS ParticipantCount,
                        EXISTS(SELECT 1 FROM StudySessionParticipants p WHERE p.SessionID = s.SessionID AND p.StudentID = @UserID) AS HasJoined,
                        (s.CreatedBy = @UserID) AS IsHost
                        FROM StudySessions s
                        JOIN Users u ON s.CreatedBy = u.UserID
                        WHERE s.SessionDate >= CURDATE()
                        ORDER BY s.SessionDate, s.SessionTime";

        rptSessions.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@UserID", userId));
        rptSessions.DataBind();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        DateTime sessionDate;
        TimeSpan sessionTime;
        if (!DateTime.TryParse(txtDate.Text, out sessionDate) || sessionDate.Date < DateTime.Today ||
            !TimeSpan.TryParse(txtTime.Text, out sessionTime) || sessionTime < TimeSpan.Zero || sessionTime >= TimeSpan.FromDays(1))
        {
            ShowMessage("Choose today or a future date and a valid session time.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            @"INSERT INTO StudySessions (CreatedBy, Title, SessionDate, SessionTime, Description)
              VALUES (@CreatedBy, @Title, @Date, @Time, @Description)",
            new MySqlParameter("@CreatedBy", AuthHelper.CurrentUserId(this)),
            new MySqlParameter("@Title", txtTitle.Text.Trim()),
            new MySqlParameter("@Date", sessionDate.Date),
            new MySqlParameter("@Time", sessionTime),
            new MySqlParameter("@Description", txtDescription.Text.Trim()));

        txtTitle.Text = ""; txtDate.Text = ""; txtTime.Text = ""; txtDescription.Text = "";
        ShowMessage("Study session scheduled.");
        LoadSessions();
    }

    protected void rptSessions_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int sessionId = Convert.ToInt32(e.CommandArgument);
        int userId = AuthHelper.CurrentUserId(this);

        switch (e.CommandName)
        {
            case "Join":
                DBHelper.ExecuteNonQuery(
                    "INSERT IGNORE INTO StudySessionParticipants (SessionID, StudentID) VALUES (@SessionID, @UserID)",
                    new MySqlParameter("@SessionID", sessionId),
                    new MySqlParameter("@UserID", userId));
                ShowMessage("You've joined the session.");
                break;

            case "Leave":
                DBHelper.ExecuteNonQuery(
                    "DELETE FROM StudySessionParticipants WHERE SessionID = @SessionID AND StudentID = @UserID",
                    new MySqlParameter("@SessionID", sessionId),
                    new MySqlParameter("@UserID", userId));
                ShowMessage("You've left the session.");
                break;

            case "Delete":
                // Only the host (checked again server-side) may cancel their own session
                DBHelper.ExecuteNonQuery(
                    "DELETE FROM StudySessions WHERE SessionID = @SessionID AND CreatedBy = @UserID",
                    new MySqlParameter("@SessionID", sessionId),
                    new MySqlParameter("@UserID", userId));
                ShowMessage("Session cancelled.");
                break;
        }

        LoadSessions();
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
