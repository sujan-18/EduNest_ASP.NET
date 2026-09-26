<%@ Page Title="My Dashboard" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="StudentDashboard.aspx.cs" Inherits="StudentDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-page">
        <section class="dashboard-welcome">
            <div><span class="eyebrow">YOUR LEARNING SPACE</span><h1>Welcome back,<br /><asp:Literal ID="litName" runat="server" /></h1><p>Pick up where you left off and keep building momentum.</p></div>
            <a class="btn btn-primary" href="Courses.aspx">&#43; Explore courses</a>
        </section>

        <div class="stat-grid student-stats">
            <div class="stat-card"><span class="stat-icon">&#9635;</span><div><strong><asp:Literal ID="litEnrolledCount" runat="server" /></strong><small>Enrolled courses</small></div></div>
            <div class="stat-card"><span class="stat-icon stat-icon-gold">&#10003;</span><div><strong><asp:Literal ID="litCompletedCount" runat="server" /></strong><small>Topics completed</small></div></div>
            <div class="stat-card"><span class="stat-icon stat-icon-teal">&#9733;</span><div><strong><asp:Literal ID="litAttemptCount" runat="server" /></strong><small>Quiz attempts</small></div></div>
        </div>

        <div class="dashboard-columns">
            <section class="dashboard-section">
                <div class="page-section-heading"><div><span class="eyebrow">KEEP GOING</span><h2>My Courses</h2></div><a class="text-link" href="Courses.aspx">Browse courses &#8594;</a></div>
                <asp:Repeater ID="rptCourses" runat="server">
                    <HeaderTemplate><div class="enrolled-course-list"></HeaderTemplate>
                    <ItemTemplate>
                        <article class="enrolled-course">
                            <div class="course-mark">&#9635;</div>
                            <div class="enrolled-course-main"><div class="enrolled-course-title"><h3><%#: Eval("Title") %></h3><span><%#: Eval("PercentComplete") %>%</span></div>
                                <p><%#: Eval("CompletedTopics") %> of <%#: Eval("TotalTopics") %> topics completed</p>
                                <div class="progress-bar-track"><div class="progress-bar-fill" style="width:<%# Eval("PercentComplete") %>%;"></div></div>
                                <div class="course-actions"><a href="LearningPath.aspx?CourseID=<%# Eval("CourseID") %>">My journey &#8594;</a><a href="Quizzes.aspx?CourseID=<%# Eval("CourseID") %>">Quizzes</a><a href="Assignments.aspx?CourseID=<%# Eval("CourseID") %>">Assignments</a></div>
                            </div>
                        </article>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoCourses" runat="server" CssClass="empty-state" Visible="false"><strong>Your learning journey starts here.</strong><p>Explore the course catalog and enroll to see your progress.</p><a class="btn btn-primary btn-small" href="Courses.aspx">Explore courses</a></asp:Panel>
            </section>

            <aside class="dashboard-side">
                <section class="next-step-card"><span class="eyebrow">YOUR NEXT STEP</span><h2>One topic at a time.</h2><p>Open a course learning path to continue with the next topic in sequence.</p><a href="Courses.aspx">Continue learning &#8594;</a><span class="next-step-orbit"></span></section>
                <section class="dashboard-panel"><div class="page-section-heading"><div><span class="eyebrow">RECENT RESULTS</span><h2>Quiz scores</h2></div></div>
                    <asp:GridView ID="gvQuizScores" runat="server" AutoGenerateColumns="false" CssClass="data-table dashboard-table">
                        <Columns><asp:BoundField DataField="QuizTitle" HeaderText="Quiz" /><asp:BoundField DataField="Score" HeaderText="Score" /><asp:BoundField DataField="TotalQuestions" HeaderText="Out of" /></Columns>
                        <EmptyDataTemplate>You haven't attempted a quiz yet.</EmptyDataTemplate>
                    </asp:GridView>
                </section>
            </aside>
        </div>

        <section class="dashboard-panel activity-panel"><div class="page-section-heading"><div><span class="eyebrow">YOUR PROGRESS</span><h2>Recent activity</h2></div></div>
            <asp:GridView ID="gvActivity" runat="server" AutoGenerateColumns="false" CssClass="data-table">
                <Columns><asp:BoundField DataField="Activity" HeaderText="Activity" /><asp:BoundField DataField="CourseTitle" HeaderText="Course" /><asp:BoundField DataField="ActivityDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy HH:mm}" /></Columns>
                <EmptyDataTemplate>No learning activity yet. Enroll in a course to get started.</EmptyDataTemplate>
            </asp:GridView>
        </section>
    </div>

</asp:Content>
