<%@ Page Title="Courses" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Courses.aspx.cs" Inherits="Courses" %>
<asp:Content ID="HeadContent1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Scripts/course-catalog.js?v=catalog-1" defer></script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="catalog-heading"><span class="eyebrow">MODERN TECH LEARNING</span><h1>Find your next skill.</h1><p>Explore hands-on courses in AI, cloud, cybersecurity, data, app development, product design, and more. Each course includes a learning path, knowledge check, and practical project.</p></div>

    <section class="catalog-tools" aria-label="Find and sort courses">
        <div class="catalog-search"><label for="courseSearch">Search courses</label><input id="courseSearch" type="search" placeholder="Try React, AI, cloud, or design" autocomplete="off" /></div>
        <div><label for="categoryFilter">Subject</label><select id="categoryFilter">
            <option value="">All subjects</option><option>Web Development</option><option>AI &amp; Machine Learning</option>
            <option>Data &amp; Analytics</option><option>Cloud &amp; DevOps</option><option>Cybersecurity</option>
            <option>Mobile Development</option><option>Product Design</option><option>Web3 &amp; Blockchain</option>
        </select></div>
        <div><label for="levelFilter">Level</label><select id="levelFilter"><option value="">All levels</option><option>Beginner</option><option>Intermediate</option><option>Advanced</option></select></div>
        <div><label for="courseSort">Sort by</label><select id="courseSort"><option value="title">Course name</option><option value="shortest">Shortest first</option><option value="longest">Longest first</option></select></div>
        <button type="button" id="clearCourseFilters" class="btn btn-outline btn-small">Clear filters</button>
    </section>
    <p id="courseResultCount" class="catalog-result-count" aria-live="polite"></p>

    <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
        <HeaderTemplate><div class="course-grid" id="courseGrid"></HeaderTemplate>
        <ItemTemplate>
            <article class="course-card catalog-course-card" data-course-title='<%#: Eval("Title") %>' data-course-category='<%#: Eval("Category") %>' data-course-level='<%#: Eval("Level") %>' data-course-hours='<%#: Eval("EstimatedHours") %>'>
                <div class="course-cover"><span class="cover-orbit"></span><span class="cover-code"><%#: Eval("Category") %></span><span class="cover-symbol">&#9998;</span></div>
                <div class="course-info">
                    <span class="course-label"><%#: Eval("Category") %></span>
                    <h3><%#: Eval("Title") %></h3>
                    <p><%#: Eval("Description") %></p>
                    <div class="catalog-course-facts"><span class="catalog-pill"><%#: Eval("Level") %></span><span class="catalog-pill"><%#: Eval("EstimatedHours") %> hours</span></div>
                    <div class="catalog-course-meta"><span class="badge badge-lecturer">Lecturer: <%#: Eval("LecturerName") %></span>
                        <div><a class="btn btn-small btn-outline" href="LearningPath.aspx?CourseID=<%# Eval("CourseID") %>">Path</a>
                        <asp:Button runat="server" CommandName="Enroll" CommandArgument='<%# Eval("CourseID") %>' Text="Enroll"
                            CssClass="btn btn-small btn-primary" Visible='<%# IsStudent() && !Convert.ToBoolean(Eval("IsEnrolled")) %>' />
                        <asp:HyperLink runat="server" Text="Continue" CssClass="btn btn-small btn-primary"
                            NavigateUrl='<%# "LearningPath.aspx?CourseID=" + Eval("CourseID") %>' Visible='<%# IsStudent() && Convert.ToBoolean(Eval("IsEnrolled")) %>' /></div>
                    </div>
                </div>
            </article>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
    <p id="noCourseMatches" class="empty-state" hidden>No courses match those filters. Try a different search or clear the filters.</p>

</asp:Content>
