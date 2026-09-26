<%@ Page Title="Learning Path" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="LearningPath.aspx.cs" Inherits="LearningPath" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1><asp:Literal ID="litCourseTitle" runat="server" /> &mdash; Structured Learning Path</h1>
    <p>Topics are listed in the order they should be studied. Log in as a student and enroll to track your progress.</p>

    <asp:ListView ID="lvTopics" runat="server" OnItemCommand="lvTopics_ItemCommand">
        <LayoutTemplate>
            <div class="card-grid" style="grid-template-columns:1fr;">
                <div runat="server" id="itemPlaceholder"></div>
            </div>
        </LayoutTemplate>
        <ItemTemplate>
            <div class="card">
                <h3>Step <%#: Eval("SequenceOrder") %>: <%#: Eval("Title") %></h3>
                <asp:PlaceHolder runat="server" Visible='<%# CanViewContent() %>'><p><%#: Eval("Content") %></p></asp:PlaceHolder>
                <asp:Label runat="server" CssClass="badge badge-student" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>' Text="✓ Completed" />
                <asp:Button runat="server" CommandName="Complete" CommandArgument='<%# Eval("TopicID") %>'
                    Text="Mark as Complete" CssClass="btn btn-small"
                    Visible='<%# ShowCompleteButton(Eval("IsCompleted")) %>' />
            </div>
        </ItemTemplate>
    </asp:ListView>

</asp:Content>
