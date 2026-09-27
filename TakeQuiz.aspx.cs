using System;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using EduNest.App_Code;

public partial class TakeQuiz : System.Web.UI.Page
{
    private int QuizID
    {
        get { return Convert.ToInt32(Request.QueryString["QuizID"]); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!AuthHelper.RequireRole(this, "Student")) return;
        int quizId;
        if (!int.TryParse(Request.QueryString["QuizID"], out quizId) || quizId <= 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }

        object enrolled = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM Quizzes q JOIN Enrollments e ON e.CourseID = q.CourseID
              WHERE q.QuizID = @QuizID AND e.StudentID = @StudentID",
            new SqlParameter("@QuizID", quizId),
            new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
        if (Convert.ToInt32(enrolled) == 0)
        {
            Response.Redirect("Courses.aspx");
            return;
        }

        // Recreate the Repeater and its answer controls on every request so
        // posted radio selections are restored before the submit handler scores them.
        object title = DBHelper.ExecuteScalar("SELECT Title FROM Quizzes WHERE QuizID = @QuizID",
            new SqlParameter("@QuizID", quizId));
        litQuizTitle.Text = title != null ? Server.HtmlEncode(title.ToString()) : "Quiz";

        DataTable dt = DBHelper.ExecuteQuery(
            "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD FROM QuizQuestions WHERE QuizID = @QuizID ORDER BY QuestionID",
            new SqlParameter("@QuizID", quizId));
        rptQuestions.DataSource = dt;
        rptQuestions.DataBind();
        pnlNoQuestions.Visible = dt.Rows.Count == 0;
        btnSubmit.Visible = dt.Rows.Count > 0;
    }

    protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
        DataRowView row = e.Item.DataItem as DataRowView;
        RadioButtonList options = e.Item.FindControl("rblOptions") as RadioButtonList;
        if (row == null || options == null) return;

        options.Items.Add(new ListItem("A. " + row["OptionA"].ToString(), "A"));
        options.Items.Add(new ListItem("B. " + row["OptionB"].ToString(), "B"));
        options.Items.Add(new ListItem("C. " + row["OptionC"].ToString(), "C"));
        options.Items.Add(new ListItem("D. " + row["OptionD"].ToString(), "D"));
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (ViewState["Submitted"] != null) return;
        object enrolled = DBHelper.ExecuteScalar(
            @"SELECT COUNT(*) FROM Quizzes q JOIN Enrollments e ON e.CourseID = q.CourseID
              WHERE q.QuizID = @QuizID AND e.StudentID = @StudentID",
            new SqlParameter("@QuizID", QuizID), new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)));
        if (Convert.ToInt32(enrolled) == 0) { Response.Redirect("Courses.aspx"); return; }

        DataTable answerKey = DBHelper.ExecuteQuery(
            "SELECT QuestionID, CorrectOption FROM QuizQuestions WHERE QuizID = @QuizID ORDER BY QuestionID",
            new SqlParameter("@QuizID", QuizID));

        int score = 0;
        int total = answerKey.Rows.Count;
        if (total == 0 || total != rptQuestions.Items.Count) return;

        for (int i = 0; i < total; i++)
        {
            RepeaterItem item = rptQuestions.Items[i];
            RadioButtonList rbl = (RadioButtonList)item.FindControl("rblOptions");

            string selected = rbl.SelectedValue; // may be null if unanswered

            // Determine the correct answer from the server's ordered answer key;
            // never trust the QuestionID hidden field submitted by the browser.
            if (selected == answerKey.Rows[i]["CorrectOption"].ToString()) score++;
        }

        DBHelper.ExecuteNonQuery(
            "INSERT INTO QuizAttempts (QuizID, StudentID, Score, TotalQuestions) VALUES (@QuizID, @StudentID, @Score, @Total)",
            new SqlParameter("@QuizID", QuizID),
            new SqlParameter("@StudentID", AuthHelper.CurrentUserId(this)),
            new SqlParameter("@Score", score),
            new SqlParameter("@Total", total));

        ViewState["Submitted"] = true;

        pnlQuiz.Visible = false;
        pnlResult.Visible = true;
        litScore.Text = score.ToString();
        litTotal.Text = total.ToString();
    }
}
