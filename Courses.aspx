<%@ Page Title="Courses" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Courses.aspx.cs" Inherits="Courses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="catalog-heading"><span class="eyebrow">EXPLORE COURSES</span><h1>Find a new direction.</h1><p>Browse the courses on EduNest. Enroll to follow a structured path and track your progress.</p></div>

    <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
        <HeaderTemplate><div class="course-grid"></HeaderTemplate>
        <ItemTemplate>
            <article class="course-card">
                <div class="course-cover"><span class="cover-orbit"></span><span class="cover-code">EDUNEST COURSE</span><span class="cover-symbol">&#9998;</span></div>
                <div class="course-info">
                    <span class="course-label">AVAILABLE COURSE</span>
                    <h3><%#: Eval("Title") %></h3>
                    <p><%#: Eval("Description") %></p>
                    <div class="catalog-course-meta"><span class="badge badge-lecturer">Lecturer: <%#: Eval("LecturerName") %></span>
                        <div><a class="btn btn-small btn-outline" href="LearningPath.aspx?CourseID=<%# Eval("CourseID") %>">Path</a>
                        <asp:Button runat="server" CommandName="Enroll" CommandArgument='<%# Eval("CourseID") %>' Text="Enroll"
                            CssClass="btn btn-small btn-primary" Visible='<%# IsStudent() %>' /></div>
                    </div>
                </div>
            </article>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

</asp:Content>
