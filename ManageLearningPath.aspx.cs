using System;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class ManageLearningPath : System.Web.UI.Page
{
    private int SelectedCourseId
    {
        get { return Convert.ToInt32(ddlCourse.SelectedValue); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        DBHelper.EnsureLearningPathResourceColumns();

        if (!IsPostBack)
        {
            LoadCourseDropdown();
            if (ddlCourse.Items.Count > 0) BindGrid();
        }
    }

    private void LoadCourseDropdown()
    {
        string role = Session["Role"] as string;
        System.Data.DataTable dt;

        if (role == "Admin")
        {
            dt = DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses ORDER BY Title");
        }
        else
        {
            dt = DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses WHERE LecturerID = @LecturerID ORDER BY Title",
                new SqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
        }

        ddlCourse.DataSource = dt;
        ddlCourse.DataTextField = "Title";
        ddlCourse.DataValueField = "CourseID";
        ddlCourse.DataBind();
    }

    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    private void BindGrid()
    {
        if (ddlCourse.Items.Count == 0) return;
        if (!CanManageCourse(SelectedCourseId)) return;

        string sql = "SELECT TopicID, Title, Content, ResourceTitle, ResourceUrl, SequenceOrder FROM LearningPathTopics WHERE CourseID = @CourseID ORDER BY SequenceOrder";
        gvTopics.DataSource = DBHelper.ExecuteQuery(sql, new SqlParameter("@CourseID", SelectedCourseId));
        gvTopics.DataBind();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || ddlCourse.Items.Count == 0) return;
        if (!CanManageCourse(SelectedCourseId)) { ShowMessage("You can only manage learning paths for your own courses."); return; }
        int sequenceOrder;
        if (!int.TryParse(txtOrder.Text, out sequenceOrder) || sequenceOrder < 1 || String.IsNullOrWhiteSpace(txtTitle.Text))
        {
            ShowMessage("Enter a topic title and a sequence order of 1 or higher.");
            return;
        }
        string resourceTitle, resourceUrl;
        if (!TryReadResource(txtResourceTitle.Text, txtResourceUrl.Text, out resourceTitle, out resourceUrl))
        {
            ShowMessage("Enter both a resource title and a valid http or https URL, or leave both blank.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "INSERT INTO LearningPathTopics (CourseID, Title, Content, ResourceTitle, ResourceUrl, SequenceOrder) VALUES (@CourseID, @Title, @Content, @ResourceTitle, @ResourceUrl, @Order)",
            new SqlParameter("@CourseID", SelectedCourseId),
            new SqlParameter("@Title", txtTitle.Text.Trim()),
            new SqlParameter("@Content", txtContent.Text.Trim()),
            new SqlParameter("@ResourceTitle", (object)resourceTitle ?? DBNull.Value),
            new SqlParameter("@ResourceUrl", (object)resourceUrl ?? DBNull.Value),
            new SqlParameter("@Order", sequenceOrder));

        txtTitle.Text = ""; txtContent.Text = ""; txtResourceTitle.Text = ""; txtResourceUrl.Text = ""; txtOrder.Text = "";
        ShowMessage("Topic added.");
        BindGrid();
    }

    protected void gvTopics_RowEditing(object sender, GridViewEditEventArgs e) { gvTopics.EditIndex = e.NewEditIndex; BindGrid(); }
    protected void gvTopics_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvTopics.EditIndex = -1; BindGrid(); }

    protected void gvTopics_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int topicId = Convert.ToInt32(gvTopics.DataKeys[e.RowIndex].Value);
        if (!CanManageTopic(topicId)) { ShowMessage("You can only manage learning paths for your own courses."); return; }
        var row = gvTopics.Rows[e.RowIndex];
        string title = ((TextBox)row.FindControl("txtEditTitle")).Text.Trim();
        string content = ((TextBox)row.FindControl("txtEditContent")).Text.Trim();
        string resourceTitle, resourceUrl;
        if (!TryReadResource(((TextBox)row.FindControl("txtEditResourceTitle")).Text,
            ((TextBox)row.FindControl("txtEditResourceUrl")).Text, out resourceTitle, out resourceUrl))
        {
            ShowMessage("Enter both a resource title and a valid http or https URL, or leave both blank.");
            return;
        }
        int sequenceOrder;
        if (string.IsNullOrWhiteSpace(title) || !int.TryParse(((TextBox)row.FindControl("txtEditOrder")).Text, out sequenceOrder) || sequenceOrder < 1)
        {
            ShowMessage("Topic title and a sequence order of 1 or higher are required.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "UPDATE LearningPathTopics SET Title = @Title, Content = @Content, ResourceTitle = @ResourceTitle, ResourceUrl = @ResourceUrl, SequenceOrder = @Order WHERE TopicID = @TopicID AND CourseID = @CourseID",
            new SqlParameter("@Title", title),
            new SqlParameter("@Content", content),
            new SqlParameter("@ResourceTitle", (object)resourceTitle ?? DBNull.Value),
            new SqlParameter("@ResourceUrl", (object)resourceUrl ?? DBNull.Value),
            new SqlParameter("@Order", sequenceOrder),
            new SqlParameter("@TopicID", topicId),
            new SqlParameter("@CourseID", SelectedCourseId));

        gvTopics.EditIndex = -1;
        ShowMessage("Topic updated.");
        BindGrid();
    }

    protected void gvTopics_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int topicId = Convert.ToInt32(gvTopics.DataKeys[e.RowIndex].Value);
        if (!CanManageTopic(topicId)) { ShowMessage("You can only manage learning paths for your own courses."); return; }
        DBHelper.ExecuteNonQuery("DELETE FROM LearningPathTopics WHERE TopicID = @TopicID AND CourseID = @CourseID",
            new SqlParameter("@TopicID", topicId), new SqlParameter("@CourseID", SelectedCourseId));
        ShowMessage("Topic deleted.");
        BindGrid();
    }

    private bool CanManageCourse(int courseId)
    {
        object allowed = DBHelper.ExecuteScalar(
            "SELECT COUNT(*) FROM Courses WHERE CourseID = @CourseID AND (@IsAdmin = 1 OR LecturerID = @UserID)",
            new SqlParameter("@CourseID", courseId),
            new SqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new SqlParameter("@UserID", AuthHelper.CurrentUserId(this)));
        return Convert.ToInt32(allowed) > 0;
    }

    private bool CanManageTopic(int topicId)
    {
        object allowed = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM LearningPathTopics t JOIN Courses c ON c.CourseID = t.CourseID
              WHERE t.TopicID = @TopicID AND (@IsAdmin = 1 OR c.LecturerID = @UserID)",
            new SqlParameter("@TopicID", topicId),
            new SqlParameter("@IsAdmin", Session["Role"] as string == "Admin"),
            new SqlParameter("@UserID", AuthHelper.CurrentUserId(this)));
        return Convert.ToInt32(allowed) > 0;
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }

    private bool TryReadResource(string titleInput, string urlInput, out string title, out string url)
    {
        title = String.IsNullOrWhiteSpace(titleInput) ? null : titleInput.Trim();
        url = String.IsNullOrWhiteSpace(urlInput) ? null : urlInput.Trim();
        if (title == null && url == null) return true;
        Uri parsed;
        return title != null && url != null && Uri.TryCreate(url, UriKind.Absolute, out parsed)
            && (parsed.Scheme == Uri.UriSchemeHttp || parsed.Scheme == Uri.UriSchemeHttps);
    }
}
