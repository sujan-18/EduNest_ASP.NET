<%@ Page Title="My Dashboard" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="StudentDashboard.aspx.cs" Inherits="StudentDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-page">
        <section class="dashboard-welcome">
            <div><span class="eyebrow">YOUR LEARNING SPACE</span><h1>Welcome back,<br /><asp:Literal ID="litName" runat="server" /></h1><p>Pick up where you left off and keep building momentum.</p></div>
            <a class="btn btn-primary" href="Courses.aspx">&#43; Explore courses</a>
        </section>

        <section class="achievement-profile" aria-label="Quiz achievement">
            <span id="achievementMedal" runat="server" class="achievement-medal is-locked"><asp:Literal ID="litAchievementEmoji" runat="server" /></span>
            <div class="achievement-copy"><span class="eyebrow">QUIZ ACHIEVEMENT</span><h2><asp:Literal ID="litAchievementTitle" runat="server" /></h2><p><asp:Literal ID="litAchievementDetail" runat="server" /></p></div>
            <div class="achievement-next"><small>UP NEXT</small><strong><asp:Literal ID="litAchievementNext" runat="server" /></strong></div>
        </section>

        <div class="stat-grid student-stats">
            <div class="stat-card"><span class="stat-icon"><svg aria-hidden="true"><use href="#icon-course" /></svg></span><div><strong><asp:Literal ID="litEnrolledCount" runat="server" /></strong><small>Enrolled courses</small></div></div>
            <div class="stat-card"><span class="stat-icon stat-icon-gold"><svg aria-hidden="true"><use href="#icon-check" /></svg></span><div><strong><asp:Literal ID="litCompletedCount" runat="server" /></strong><small>Topics completed</small></div></div>
            <div class="stat-card"><span class="stat-icon stat-icon-teal"><svg aria-hidden="true"><use href="#icon-quiz" /></svg></span><div><strong><asp:Literal ID="litAttemptCount" runat="server" /></strong><small>Quiz attempts</small></div></div>
            <div class="stat-card"><span class="stat-icon stat-icon-gold"><svg aria-hidden="true"><use href="#icon-star" /></svg></span><div><strong><asp:Literal ID="litQuizRating" runat="server" /></strong><small>Quiz performance rating</small><small><asp:Literal ID="litQuizRatingDetail" runat="server" /></small></div></div>
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
                <section class="dashboard-panel deadline-panel"><div class="page-section-heading"><div><span class="eyebrow">PLAN AHEAD</span><h2>Upcoming assignments</h2></div><a class="text-link" href="Courses.aspx">Find courses</a></div>
                    <asp:Repeater ID="rptUpcomingAssignments" runat="server">
                        <HeaderTemplate><div class="deadline-list"></HeaderTemplate>
                        <ItemTemplate><article class="deadline-item"><div class="deadline-copy"><strong><%#: Eval("Title") %></strong><small><%#: Eval("CourseTitle") %> &middot; Due <%#: Eval("DueDate", "{0:dd MMM}") %></small></div><span class='deadline-status <%# Convert.ToBoolean(Eval("HasSubmitted")) ? "is-submitted" : "is-pending" %>'><%# Convert.ToBoolean(Eval("HasSubmitted")) ? "Submitted" : "To do" %></span><a href='SubmitAssignment.aspx?AssignmentID=<%# Eval("AssignmentID") %>' aria-label="Open assignment">&#8594;</a></article></ItemTemplate>
                        <FooterTemplate></div></FooterTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoUpcomingAssignments" runat="server" CssClass="empty-state" Visible="false"><strong>You're all caught up.</strong><p>New assignment deadlines will appear here.</p></asp:Panel>
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
