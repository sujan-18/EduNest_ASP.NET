using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using EduNest.App_Code;

public partial class ManageQuizzes : System.Web.UI.Page
{
    private int SelectedCourseId { get { return Convert.ToInt32(ddlCourse.SelectedValue); } }

    private int SelectedQuizId
    {
        get { return ViewState["SelectedQuizId"] != null ? Convert.ToInt32(ViewState["SelectedQuizId"]) : 0; }
        set { ViewState["SelectedQuizId"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Lecturer", "Admin")) return;
        if (!IsPostBack)
        {
            LoadCourseDropdown();
            if (ddlCourse.Items.Count > 0) BindQuizGrid();
        }
    }

    private void LoadCourseDropdown()
    {
        string role = Session["Role"] as string;
        var dt = role == "Admin"
            ? DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses ORDER BY Title")
            : DBHelper.ExecuteQuery("SELECT CourseID, Title FROM Courses WHERE LecturerID = @LecturerID ORDER BY Title",
                new MySqlParameter("@LecturerID", AuthHelper.CurrentUserId(this)));

        ddlCourse.DataSource = dt;
        ddlCourse.DataTextField = "Title";
        ddlCourse.DataValueField = "CourseID";
        ddlCourse.DataBind();
    }

    protected void ddlCourse_Changed(object sender, EventArgs e)
    {
        pnlQuestions.Visible = false;
        BindQuizGrid();
    }

    private void BindQuizGrid()
    {
        if (ddlCourse.Items.Count == 0) return;
        string sql = @"SELECT q.QuizID, q.Title, COUNT(qq.QuestionID) AS QuestionCount
                        FROM Quizzes q LEFT JOIN QuizQuestions qq ON q.QuizID = qq.QuizID
                        WHERE q.CourseID = @CourseID GROUP BY q.QuizID, q.Title";
        gvQuizzes.DataSource = DBHelper.ExecuteQuery(sql, new MySqlParameter("@CourseID", SelectedCourseId));
        gvQuizzes.DataBind();
    }

    protected void btnAddQuiz_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || ddlCourse.Items.Count == 0) return;

        DBHelper.ExecuteNonQuery("INSERT INTO Quizzes (CourseID, Title) VALUES (@CourseID, @Title)",
            new MySqlParameter("@CourseID", SelectedCourseId),
            new MySqlParameter("@Title", txtQuizTitle.Text.Trim()));

        txtQuizTitle.Text = "";
        ShowMessage("Quiz created.");
        BindQuizGrid();
    }

    protected void gvQuizzes_SelectedIndexChanged(object sender, EventArgs e)
    {
        SelectedQuizId = Convert.ToInt32(gvQuizzes.DataKeys[gvQuizzes.SelectedIndex].Value);
        object title = DBHelper.ExecuteScalar("SELECT Title FROM Quizzes WHERE QuizID=@QuizID AND CourseID=@CourseID",
            new MySqlParameter("@QuizID", SelectedQuizId), new MySqlParameter("@CourseID", SelectedCourseId));
        litSelectedQuiz.Text = title == null ? "" : Server.HtmlEncode(title.ToString());
        pnlQuestions.Visible = true;
        BindQuestionsGrid();
    }

    private void BindQuestionsGrid()
    {
        if (SelectedQuizId <= 0) return;
        gvQuestions.DataSource = DBHelper.ExecuteQuery(
            "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption FROM QuizQuestions WHERE QuizID = @QuizID ORDER BY QuestionID",
            new MySqlParameter("@QuizID", SelectedQuizId));
        gvQuestions.DataBind();
    }

    protected void gvQuestions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowState.HasFlag(DataControlRowState.Edit))
        {
            var ddl = (DropDownList)e.Row.FindControl("ddlEditCorrect");
            if (ddl != null && e.Row.DataItem != null)
                ddl.SelectedValue = DataBinder.Eval(e.Row.DataItem, "CorrectOption").ToString();
        }
    }

    protected void gvQuestions_RowEditing(object sender, GridViewEditEventArgs e) { gvQuestions.EditIndex = e.NewEditIndex; BindQuestionsGrid(); }
    protected void gvQuestions_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvQuestions.EditIndex = -1; BindQuestionsGrid(); }

    protected void gvQuestions_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int questionId = Convert.ToInt32(gvQuestions.DataKeys[e.RowIndex].Value);
        var row = gvQuestions.Rows[e.RowIndex];
        string question = ((TextBox)row.FindControl("txtEditQuestion")).Text.Trim();
        string[] options = { "txtEditA", "txtEditB", "txtEditC", "txtEditD" };
        string[] values = new string[4];
        for (int i = 0; i < options.Length; i++) values[i] = ((TextBox)row.FindControl(options[i])).Text.Trim();
        string correct = ((DropDownList)row.FindControl("ddlEditCorrect")).SelectedValue;
        if (question.Length == 0 || Array.Exists(values, String.IsNullOrWhiteSpace))
        {
            ShowMessage("Question and all four options are required.");
            return;
        }
        DBHelper.ExecuteNonQuery(
            @"UPDATE QuizQuestions SET QuestionText=@Question, OptionA=@A, OptionB=@B, OptionC=@C, OptionD=@D, CorrectOption=@Correct
              WHERE QuestionID=@QuestionID AND QuizID=@QuizID",
            new MySqlParameter("@Question", question), new MySqlParameter("@A", values[0]),
            new MySqlParameter("@B", values[1]), new MySqlParameter("@C", values[2]),
            new MySqlParameter("@D", values[3]), new MySqlParameter("@Correct", correct),
            new MySqlParameter("@QuestionID", questionId), new MySqlParameter("@QuizID", SelectedQuizId));
        gvQuestions.EditIndex = -1;
        BindQuestionsGrid();
        ShowMessage("Question updated.");
    }

    protected void btnAddQuestion_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || ddlCourse.Items.Count == 0 || SelectedQuizId <= 0) return;
        object ownsQuiz = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Quizzes WHERE QuizID=@QuizID AND CourseID=@CourseID",
            new MySqlParameter("@QuizID", SelectedQuizId), new MySqlParameter("@CourseID", SelectedCourseId));
        if (Convert.ToInt32(ownsQuiz) == 0) return;
        if (String.IsNullOrWhiteSpace(txtQuestion.Text) || String.IsNullOrWhiteSpace(txtOptionA.Text) ||
            String.IsNullOrWhiteSpace(txtOptionB.Text) || String.IsNullOrWhiteSpace(txtOptionC.Text) ||
            String.IsNullOrWhiteSpace(txtOptionD.Text))
        {
            ShowMessage("Enter the question and all four answer options.");
            return;
        }

        DBHelper.ExecuteNonQuery(
            @"INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption)
              VALUES (@QuizID, @Q, @A, @B, @C, @D, @Correct)",
            new MySqlParameter("@QuizID", SelectedQuizId),
            new MySqlParameter("@Q", txtQuestion.Text.Trim()),
            new MySqlParameter("@A", txtOptionA.Text.Trim()),
            new MySqlParameter("@B", txtOptionB.Text.Trim()),
            new MySqlParameter("@C", txtOptionC.Text.Trim()),
            new MySqlParameter("@D", txtOptionD.Text.Trim()),
            new MySqlParameter("@Correct", ddlCorrect.SelectedValue));

        txtQuestion.Text = ""; txtOptionA.Text = ""; txtOptionB.Text = ""; txtOptionC.Text = ""; txtOptionD.Text = "";
        pnlQuestions.Visible = true;
        BindQuestionsGrid();
        BindQuizGrid();
        ShowMessage("Question added.");
    }

    protected void gvQuizzes_RowEditing(object sender, GridViewEditEventArgs e) { gvQuizzes.EditIndex = e.NewEditIndex; BindQuizGrid(); }
    protected void gvQuizzes_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e) { gvQuizzes.EditIndex = -1; BindQuizGrid(); }
    protected void gvQuizzes_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int quizId = Convert.ToInt32(gvQuizzes.DataKeys[e.RowIndex].Value);
        string title = ((TextBox)gvQuizzes.Rows[e.RowIndex].FindControl("txtEditQuizTitle")).Text.Trim();
        if (String.IsNullOrWhiteSpace(title)) { ShowMessage("Quiz title is required."); return; }
        DBHelper.ExecuteNonQuery("UPDATE Quizzes SET Title=@Title WHERE QuizID=@QuizID AND CourseID=@CourseID",
            new MySqlParameter("@Title", title), new MySqlParameter("@QuizID", quizId), new MySqlParameter("@CourseID", SelectedCourseId));
        gvQuizzes.EditIndex = -1;
        BindQuizGrid();
        ShowMessage("Quiz updated.");
    }

    protected void gvQuestions_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int questionId = Convert.ToInt32(gvQuestions.DataKeys[e.RowIndex].Value);
        DBHelper.ExecuteNonQuery("DELETE FROM QuizQuestions WHERE QuestionID = @QuestionID AND QuizID = @QuizID",
            new MySqlParameter("@QuestionID", questionId), new MySqlParameter("@QuizID", SelectedQuizId));
        pnlQuestions.Visible = true;
        BindQuestionsGrid();
        BindQuizGrid();
        ShowMessage("Question deleted.");
    }

    protected void gvQuizzes_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int quizId = Convert.ToInt32(gvQuizzes.DataKeys[e.RowIndex].Value);
        DBHelper.ExecuteNonQuery("DELETE FROM Quizzes WHERE QuizID = @QuizID AND CourseID = @CourseID",
            new MySqlParameter("@QuizID", quizId), new MySqlParameter("@CourseID", SelectedCourseId));
        pnlQuestions.Visible = false;
        ShowMessage("Quiz deleted.");
        BindQuizGrid();
    }

    private void ShowMessage(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = Server.HtmlEncode(message);
    }
}
