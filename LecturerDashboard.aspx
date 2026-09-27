<%@ Page Title="Lecturer Dashboard" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="LecturerDashboard.aspx.cs" Inherits="LecturerDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-page">
    <section class="dashboard-welcome"><div><span class="eyebrow">TEACHING WORKSPACE</span><h1>Welcome back,<br /><asp:Literal ID="litName" runat="server" /></h1><p>Manage your courses and see how your students are progressing.</p></div><a class="btn btn-primary" href="ManageCourses.aspx">+ Manage courses</a></section>

    <div class="stat-grid admin-stat-grid">
        <div class="stat-card"><span class="stat-icon">&#9635;</span><div><strong><asp:Literal ID="litCourseCount" runat="server" /></strong><small>Your courses</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-teal">&#9786;</span><div><strong><asp:Literal ID="litStudentCount" runat="server" /></strong><small>Enrolled students</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-gold">&#9998;</span><div><strong><asp:Literal ID="litSubmissionCount" runat="server" /></strong><small>Submissions received</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-green">&#10003;</span><div><strong><asp:Literal ID="litPendingReviewCount" runat="server" /></strong><small>Awaiting review</small></div></div>
    </div>

    <div class="page-section-heading"><div><span class="eyebrow">COURSE MANAGEMENT</span><h2>Your Courses</h2></div></div>
    <div class="management-shortcuts">
        <a href="ManageLearningPath.aspx"><span>&#8594;</span><b>Learning paths</b><small>Organise topics and sequence</small></a>
        <a href="ManageQuizzes.aspx"><span>&#63;</span><b>Quizzes</b><small>Create and edit assessments</small></a>
        <a href="ManageAssignments.aspx"><span>&#9998;</span><b>Assignments</b><small>Set deadlines and view work</small></a>
        <a href="ReviewSubmissions.aspx"><span>&#10003;</span><b>Review submissions</b><small>Grade work and give feedback</small></a>
        <a href="CourseFeedback.aspx"><span><svg class="nav-icon" aria-hidden="true"><use href="#icon-review" /></svg></span><b>Course feedback</b><small>Read learner ratings and comments</small></a>
    </div>

    <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" CssClass="data-table">
        <Columns>
            <asp:BoundField DataField="Title" HeaderText="Course" />
            <asp:BoundField DataField="StudentCount" HeaderText="Students Enrolled" />
            <asp:BoundField DataField="TopicCount" HeaderText="Topics" />
        </Columns>
    </asp:GridView>
    </div>

</asp:Content>
