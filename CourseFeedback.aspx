<%@ Page Title="Course Feedback" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CourseFeedback.aspx.cs" Inherits="CourseFeedbackReport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title-row">
        <div><span class="eyebrow">LEARNER VOICE</span><h1>Course feedback</h1>
            <p>Read ratings and comments from students enrolled in your courses.</p></div>
    </div>
    <div class="stat-grid">
        <div class="stat-card"><span class="stat-icon stat-icon-gold"><svg class="nav-icon" aria-hidden="true"><use href="#icon-review" /></svg></span><div><strong><asp:Literal ID="litFeedbackCount" runat="server" /></strong><small>Student reviews</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-teal"><svg class="nav-icon" aria-hidden="true"><use href="#icon-star" /></svg></span><div><strong><asp:Literal ID="litAverageRating" runat="server" /></strong><small>Average rating out of 5</small></div></div>
    </div>
    <asp:GridView ID="gvFeedback" runat="server" AutoGenerateColumns="false" CssClass="data-table"
        EmptyDataText="No student feedback has been submitted yet." GridLines="None">
        <Columns>
            <asp:BoundField DataField="CourseTitle" HeaderText="Course" />
            <asp:BoundField DataField="StudentName" HeaderText="Student" />
            <asp:BoundField DataField="Rating" HeaderText="Rating" DataFormatString="{0} / 5" />
            <asp:BoundField DataField="FeedbackText" HeaderText="Feedback" />
            <asp:BoundField DataField="CreatedDate" HeaderText="Submitted" DataFormatString="{0:MMM d, yyyy}" />
        </Columns>
    </asp:GridView>
</asp:Content>
