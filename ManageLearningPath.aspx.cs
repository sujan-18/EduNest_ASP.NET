using System;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
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
                new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));
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

        string sql = "SELECT TopicID, Title, Content, SequenceOrder FROM LearningPathTopics WHERE CourseID = @CourseID ORDER BY SequenceOrder";
        gvTopics.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@CourseID", SelectedCourseId));
        gvTopics.DataBind();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || ddlCourse.Items.Count == 0) return;
        int sequenceOrder;
        if (!int.TryParse(txtOrder.Text, out sequenceOrder) || sequenceOrder < 1 || String.IsNullOrWhiteSpace(txtTitle.Text))
        {
            ShowMessage("Enter a topic title and a sequence order of 1 or higher.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "INSERT INTO LearningPathTopics (CourseID, Title, Content, SequenceOrder) VALUES (@CourseID, @Title, @Content, @Order)",
            new MySqlParameter("@CourseID", SelectedCourseId),
            new MySqlParameter("@Title", txtTitle.Text.Trim()),
            new MySqlParameter("@Content", txtContent.Text.Trim()),
            new MySqlParameter("@Order", sequenceOrder));

        txtTitle.Text = ""; txtContent.Text = ""; txtOrder.Text = "";
        ShowMessage("Topic added.");
        BindGrid();
    }

    protected void gvTopics_RowEditing(object sender, GridViewEditEventArgs e) { gvTopics.EditIndex = e.NewEditIndex; BindGrid(); }
    protected void gvTopics_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvTopics.EditIndex = -1; BindGrid(); }

    protected void gvTopics_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int topicId = Convert.ToInt32(gvTopics.DataKeys[e.RowIndex].Value);
        var row = gvTopics.Rows[e.RowIndex];
        string title = ((TextBox)row.FindControl("txtEditTitle")).Text.Trim();
        string content = ((TextBox)row.FindControl("txtEditContent")).Text.Trim();
        int sequenceOrder;
        if (string.IsNullOrWhiteSpace(title) || !int.TryParse(((TextBox)row.FindControl("txtEditOrder")).Text, out sequenceOrder) || sequenceOrder < 1)
        {
            ShowMessage("Topic title and a sequence order of 1 or higher are required.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            "UPDATE LearningPathTopics SET Title = @Title, Content = @Content, SequenceOrder = @Order WHERE TopicID = @TopicID AND CourseID = @CourseID",
            new MySqlParameter("@Title", title),
            new MySqlParameter("@Content", content),
            new MySqlParameter("@Order", sequenceOrder),
            new MySqlParameter("@TopicID", topicId),
            new MySqlParameter("@CourseID", SelectedCourseId));

        gvTopics.EditIndex = -1;
        ShowMessage("Topic updated.");
        BindGrid();
    }

    protected void gvTopics_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int topicId = Convert.ToInt32(gvTopics.DataKeys[e.RowIndex].Value);
        DBHelper.ExecuteNonQuery("DELETE FROM LearningPathTopics WHERE TopicID = @TopicID AND CourseID = @CourseID",
            new MySqlParameter("@TopicID", topicId), new MySqlParameter("@CourseID", SelectedCourseId));
        ShowMessage("Topic deleted.");
        BindGrid();
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
