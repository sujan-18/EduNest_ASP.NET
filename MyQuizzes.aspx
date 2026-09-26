<%@ Page Title="My Quizzes" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="MyQuizzes.aspx.cs" Inherits="MyQuizzes" %>
<asp:Content ID="HeadContent1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Scripts/my-quizzes.js?v=quiz-filters-1" defer></script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="dashboard-welcome">
        <div><span class="eyebrow">PRACTICE AND CHECK YOUR PROGRESS</span><h1>My quizzes</h1><p>Take a knowledge check from any course you are enrolled in. Your latest result and attempt count are shown here.</p></div>
        <a class="btn btn-primary" href="Courses.aspx">Explore courses</a>
    </section>

    <section class="quiz-filters" aria-label="Filter quizzes">
        <div><label for="quizSubjectFilter">Subject</label><select id="quizSubjectFilter">
            <option value="">All subjects</option><option>Web Development</option><option>AI &amp; Machine Learning</option>
            <option>Data &amp; Analytics</option><option>Networking &amp; Infrastructure</option><option>Cloud &amp; DevOps</option>
            <option>Cybersecurity</option><option>Mobile Development</option><option>Product Design</option><option>Web3 &amp; Blockchain</option>
        </select></div>
        <div><label for="quizCourseFilter">Course</label><select id="quizCourseFilter"><option value="">All courses</option></select></div>
        <p id="quizFilterCount" aria-live="polite"></p>
    </section>

    <asp:Repeater ID="rptQuizzes" runat="server">
        <HeaderTemplate><div class="card-grid quiz-center-grid"></HeaderTemplate>
        <ItemTemplate>
            <article class="card quiz-center-card" data-quiz-category='<%#: Eval("Category") %>' data-quiz-course='<%#: Eval("CourseTitle") %>'>
                <span class="eyebrow"><%#: Eval("Category") %> &middot; <%#: Eval("CourseTitle") %></span>
                <h2><%#: Eval("Title") %></h2>
                <p><%#: Eval("QuestionCount") %> questions</p>
                <p><strong>Attempts:</strong> <%#: Eval("AttemptCount") %>
                    <%# Convert.ToInt32(Eval("AttemptCount")) > 0 ? " - Latest score: " + Eval("LatestScore") : " - Not attempted yet" %>
                </p>
                <a class="btn btn-small btn-accent" href='TakeQuiz.aspx?QuizID=<%# Eval("QuizID") %>'><%# Convert.ToInt32(Eval("AttemptCount")) > 0 ? "Try again" : "Start quiz" %></a>
            </article>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
    <asp:Panel ID="pnlNoQuizzes" runat="server" CssClass="empty-state" Visible="false">
        <strong>No quizzes available yet.</strong><p>Enroll in a course with a quiz to see it here.</p><a class="btn btn-primary btn-small" href="Courses.aspx">Browse courses</a>
    </asp:Panel>
    <p id="noQuizMatches" class="empty-state" hidden>No quizzes match those filters. Choose another subject or course.</p>
</asp:Content>
