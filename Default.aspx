<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="hero reference-hero">
        <div class="hero-copy">
            <span class="hero-pill"><i></i> Smart Campus Learning Hub</span>
            <h1>Learn with<br /><em>direction.</em><br />Grow with<br /><strong>confidence.</strong></h1>
            <p>EduNest brings structured learning, academic progress, peer collaboration, and study planning into one connected campus space.</p>
            <div class="hero-actions">
                <a class="btn btn-primary" href="Courses.aspx">Explore EduNest <span aria-hidden="true">&#8594;</span></a>
                <a class="btn btn-outline" href="Register.aspx">Get started</a>
            </div>
            <div class="hero-stats">
                <div><strong>4</strong><span>learning tools</span></div>
                <div><strong>3</strong><span>user roles</span></div>
                <div><strong><asp:Literal ID="litCourseCount" runat="server" /></strong><span>available courses</span></div>
            </div>
        </div>
        <div class="hero-visual">
            <figure class="hero-photo-frame">
                <asp:Image ID="imgLearningHero" runat="server" ImageUrl="~/Images/student-study.jpg" CssClass="hero-photo" AlternateText="A university student studying with a laptop at a library table" />
            </figure>
            <div class="floating-card progress-float">
                <span class="float-icon">&#10003;</span><b>Learning paths</b>
                <small>Clear steps for every course</small>
            </div>
            <div class="floating-card next-float"><small>YOUR NEXT STEP</small><strong>Learn at your pace</strong><span>One topic at a time</span></div>
            <div class="floating-session"><span>&#9711;</span><div><small>Study session</small><b>Learn together</b></div></div>
        </div>
    </section>

    <section id="features" class="home-section">
        <div class="center-heading"><span class="eyebrow">CORE FEATURES</span><h2>Four pillars of academic success</h2><p>Everything you need to understand your learning, track progress, collaborate with peers, and stay organised.</p></div>
        <div class="feature-showcase">
            <div class="feature-list">
                <article class="feature-row"><span class="feature-number">01</span><div><h3>Structured Learning Paths</h3><p>Follow a clear roadmap, one topic at a time.</p></div></article>
                <article class="feature-row"><span class="feature-number feature-gold">02</span><div><h3>Academic Progress</h3><p>See your progress, quiz results, and recent activity.</p></div></article>
                <article class="feature-row"><span class="feature-number feature-teal">03</span><div><h3>Peer Review</h3><p>Share useful feedback and improve together.</p></div></article>
                <article class="feature-row"><span class="feature-number feature-green">04</span><div><h3>Study Room Scheduler</h3><p>Plan time to work with your classmates.</p></div></article>
            </div>
            <div class="showcase-preview">
                <div class="preview-window">
                    <div class="preview-top"><span class="window-dots"><i></i><i></i><i></i></span><span>My learning journey</span><span class="preview-avatar">S</span></div>
                    <div class="preview-body">
                        <div class="preview-intro"><div><small>WEB APPLICATION DEVELOPMENT</small><h3>You're on your way</h3></div><div class="preview-ring"><b>72<small>%</small></b></div></div>
                        <div class="preview-topic topic-done"><span>&#10003;</span><div><b>Introduction to HTML5</b><small>Completed</small></div></div>
                        <div class="preview-topic topic-done"><span>&#10003;</span><div><b>CSS Styling Fundamentals</b><small>Completed</small></div></div>
                        <div class="preview-topic topic-current"><span>03</span><div><b>Build responsive layouts</b><small>Continue learning</small></div><i>&#8594;</i></div>
                        <div class="preview-topic topic-next"><span>04</span><div><b>ASP.NET Web Forms</b><small>Up next</small></div></div>
                    </div>
                </div>
                <div class="preview-caption"><span class="caption-check">&#10003;</span><span><b>One clear next step</b><small>Know where you are and what comes next.</small></span></div>
            </div>
        </div>
    </section>

    <section id="how-it-works" class="journey-section home-section">
        <div class="center-heading"><span class="eyebrow">THE PROCESS</span><h2>Your learning journey, simplified</h2><p>Small, steady steps make progress easier to see.</p></div>
        <div class="journey-steps">
            <article><span>01</span><h3>Discover</h3><p>Choose your course and see the learning roadmap.</p></article>
            <article><span>02</span><h3>Follow</h3><p>Work through each topic in a useful order.</p></article>
            <article><span>03</span><h3>Practice</h3><p>Reinforce what you've learned with quizzes and assignments.</p></article>
            <article><span>04</span><h3>Improve</h3><p>Check your progress and learn from peer feedback.</p></article>
        </div>
    </section>

    <section id="courses" class="home-section courses-section">
        <div class="courses-heading"><div><span class="eyebrow">EXPLORE COURSES</span><h2>Structured for your studies</h2></div><a class="text-link" href="Courses.aspx">View all courses &#8594;</a></div>
        <asp:Repeater ID="rptFeaturedCourses" runat="server">
            <HeaderTemplate><div class="course-grid"></HeaderTemplate>
            <ItemTemplate>
                <article class="course-card">
                    <div class="course-cover"><span class="cover-orbit"></span><span class="cover-code">EDUNEST COURSE</span><span class="cover-symbol">&#9998;</span></div>
                    <div class="course-info"><span class="course-label">FEATURED COURSE</span><h3><%#: Eval("Title") %></h3><p><%#: Eval("Description") %></p><div class="course-meta"><span class="badge badge-lecturer">By <%#: Eval("LecturerName") %></span><a href="Courses.aspx" aria-label="Explore courses">&#8594;</a></div></div>
                </article>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>
    </section>

    <section class="closing-cta"><span class="eyebrow">START YOUR NEXT CHAPTER</span><h2>A little more direction<br />can change everything.</h2><p>Find a course, follow your progress, and build better study habits with EduNest.</p><a class="btn btn-warm" href="Register.aspx">Get started free <span aria-hidden="true">&#8594;</span></a></section>

</asp:Content>
