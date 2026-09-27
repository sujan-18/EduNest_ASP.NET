<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="AdminDashboard.aspx.cs" Inherits="AdminDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-page">
    <section class="dashboard-welcome"><div><span class="eyebrow">PLATFORM OVERVIEW</span><h1>Administration</h1><p>Manage people, learning content, and activity across EduNest.</p></div><a class="btn btn-primary" href="ManageUsers.aspx">+ Add user</a></section>

    <div class="stat-grid admin-stat-grid">
        <div class="stat-card"><span class="stat-icon">&#9786;</span><div><strong><asp:Literal ID="litUserCount" runat="server" /></strong><small>All users</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-gold">&#9635;</span><div><strong><asp:Literal ID="litCourseCount" runat="server" /></strong><small>Courses</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-teal">&#8646;</span><div><strong><asp:Literal ID="litEnrollmentCount" runat="server" /></strong><small>Enrollments</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-green">&#9733;</span><div><strong><asp:Literal ID="litQuizAttempts" runat="server" /></strong><small>Quiz attempts</small></div></div>
        <div class="stat-card"><span class="stat-icon stat-icon-green">&#10003;</span><div><strong><asp:Literal ID="litPendingReviews" runat="server" /></strong><small>Submissions awaiting review</small></div></div>
    </div>

    <div class="page-section-heading"><div><span class="eyebrow">SYSTEM MANAGEMENT</span><h2>Manage the platform</h2></div></div>
    <div class="management-shortcuts">
        <a href="ManageUsers.aspx"><span>&#9786;</span><b>Users</b><small>Create accounts and assign roles</small></a>
        <a href="ManageCourses.aspx"><span>&#9635;</span><b>Courses</b><small>Manage course listings</small></a>
        <a href="ManageLearningPath.aspx"><span>&#8594;</span><b>Learning paths</b><small>Organise course topics</small></a>
        <a href="ManageQuizzes.aspx"><span>&#63;</span><b>Quizzes</b><small>Manage questions and scores</small></a>
        <a href="ManageAssignments.aspx"><span>&#9998;</span><b>Assignments</b><small>Manage tasks and due dates</small></a>
        <a href="ReviewSubmissions.aspx"><span>&#10003;</span><b>Submission reviews</b><small>Review grades and feedback</small></a>
        <a href="CourseFeedback.aspx"><span><svg class="nav-icon" aria-hidden="true"><use href="#icon-review" /></svg></span><b>Course feedback</b><small>Review learner ratings and comments</small></a>
    </div>
    </div>

</asp:Content>
