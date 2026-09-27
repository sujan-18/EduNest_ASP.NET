<%@ Page Title="Take Quiz" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="TakeQuiz.aspx.cs" Inherits="TakeQuiz" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1><asp:Literal ID="litQuizTitle" runat="server" /></h1>

    <asp:Panel ID="pnlResult" runat="server" Visible="false">
        <div class="alert alert-success">
            You scored <asp:Literal ID="litScore" runat="server" /> out of <asp:Literal ID="litTotal" runat="server" />.
        </div>
        <a class="btn" href="StudentDashboard.aspx">Back to Dashboard</a>
    </asp:Panel>

    <asp:Panel ID="pnlQuiz" runat="server">
        <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
            <ItemTemplate>
                <section class="card quiz-question-card">
                    <h2><span>Question <%#: Container.ItemIndex + 1 %></span></h2>
                    <p><%#: Eval("QuestionText") %></p>
                    <asp:RadioButtonList runat="server" ID="rblOptions"
                        CssClass="quiz-answer-list" RepeatDirection="Vertical" RepeatLayout="UnorderedList" />
                    <asp:HiddenField runat="server" ID="hdnQuestionId" Value='<%# Eval("QuestionID") %>' />
                </section>
            </ItemTemplate>
        </asp:Repeater>
        <asp:Panel ID="pnlNoQuestions" runat="server" CssClass="empty-state" Visible="false">
            <strong>This quiz has no questions yet.</strong>
            <p>Choose another quiz or check back after your teacher adds questions.</p>
            <a class="btn btn-small btn-primary" href="MyQuizzes.aspx">Back to my quizzes</a>
        </asp:Panel>
        <asp:Button ID="btnSubmit" runat="server" Text="Submit Quiz" CssClass="btn btn-accent" OnClick="btnSubmit_Click" />
    </asp:Panel>

</asp:Content>
