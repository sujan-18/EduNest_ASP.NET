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
                <div class="card" style="margin-bottom:16px;">
                    <p><strong>Q<%#: Container.ItemIndex + 1 %>.</strong> <%#: Eval("QuestionText") %></p>
                    <asp:RadioButtonList runat="server" ID="rblOptions"
                        RepeatLayout="Flow" />
                    <asp:HiddenField runat="server" ID="hdnQuestionId" Value='<%# Eval("QuestionID") %>' />
                </div>
            </ItemTemplate>
        </asp:Repeater>
        <asp:Button ID="btnSubmit" runat="server" Text="Submit Quiz" CssClass="btn btn-accent" OnClick="btnSubmit_Click" />
    </asp:Panel>

</asp:Content>
