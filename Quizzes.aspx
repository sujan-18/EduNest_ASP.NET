<%@ Page Title="Quizzes" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Quizzes.aspx.cs" Inherits="Quizzes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Course Quizzes</h1>
    <asp:Repeater ID="rptQuizzes" runat="server">
        <HeaderTemplate><div class="card-grid"></HeaderTemplate>
        <ItemTemplate>
            <div class="card">
                <h3><%#: Eval("Title") %></h3>
                <p><%# Eval("QuestionCount") %> questions</p>
                <a class="btn btn-small btn-accent" href="TakeQuiz.aspx?QuizID=<%# Eval("QuizID") %>">Take Quiz</a>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

</asp:Content>
