<%@ Page Title="Learning Path" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="LearningPath.aspx.cs" Inherits="LearningPath" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-title-row">
        <div class="learning-path-heading"><h1><asp:Literal ID="litCourseTitle" runat="server" /> &mdash; Learning Path</h1>
            <p class="learning-course-description"><asp:Literal ID="litCourseDescription" runat="server" /></p>
            <p>Work through the lesson notes and practice activity. Use the learning resource for a deeper explanation, then mark the lesson complete.</p>
            <p class="course-progress"><asp:Literal ID="litCourseProgress" runat="server" /></p>
            <asp:Panel ID="pnlCourseComplete" runat="server" CssClass="course-complete-banner" Visible="false">
                &#10003; Course complete. You have finished every lesson in this learning path.
            </asp:Panel>
        </div>
        <asp:HyperLink ID="hlCourseQuizzes" runat="server" CssClass="btn btn-primary" Text="Take a course quiz" Visible="false" />
    </div>

    <asp:ListView ID="lvTopics" runat="server" OnItemCommand="lvTopics_ItemCommand">
        <LayoutTemplate>
            <div class="card-grid" style="grid-template-columns:1fr;">
                <div runat="server" id="itemPlaceholder"></div>
            </div>
        </LayoutTemplate>
        <ItemTemplate>
            <article class="card learning-lesson">
                <p class="lesson-step">Lesson <%#: Eval("SequenceOrder") %></p>
                <h2><%#: Eval("Title") %></h2>
                <asp:PlaceHolder runat="server" Visible='<%# CanViewContent() %>'>
                    <div class="lesson-content"><%#: Eval("Content") %><span class="lesson-content-end" aria-hidden="true"></span></div>
                    <asp:HyperLink runat="server" CssClass="lesson-resource"
                        NavigateUrl='<%# Eval("ResourceUrl") %>'
                        Text='<%# "Open learning resource: " + Convert.ToString(Eval("ResourceTitle")) %>'
                        Target="_blank" rel="noopener noreferrer" Visible='<%# HasResource(Eval("ResourceUrl")) %>' />
                </asp:PlaceHolder>
                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsCompleted")) %>'>
                    <span class="badge badge-student lesson-complete">&#10003; Completed</span>
                </asp:PlaceHolder>
                <asp:Button runat="server" CommandName="Complete" CommandArgument='<%# Eval("TopicID") %>'
                    Text="Mark lesson complete" CssClass="btn btn-small lesson-complete-action"
                    Enabled="false" Visible='<%# Convert.ToBoolean(Eval("CanComplete")) %>' />
            </article>
        </ItemTemplate>
    </asp:ListView>

    <script>
        (function () {
            function attachLessonReadingGates() {
                var lessons = document.querySelectorAll('.learning-lesson');
                for (var i = 0; i < lessons.length; i++) {
                    (function (lesson) {
                        var endMarker = lesson.querySelector('.lesson-content-end');
                        var completeButton = lesson.querySelector('.lesson-complete-action');
                        if (!endMarker || !completeButton) return;
                        completeButton.disabled = true;
                        if (!('IntersectionObserver' in window)) {
                            completeButton.disabled = false;
                            return;
                        }
                        var observer = new IntersectionObserver(function (entries) {
                            if (entries.some(function (entry) { return entry.isIntersecting; })) {
                                completeButton.disabled = false;
                                observer.disconnect();
                            }
                        }, { threshold: 0.5 });
                        observer.observe(endMarker);
                    }(lessons[i]));
                }
            }
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', attachLessonReadingGates);
            } else {
                attachLessonReadingGates();
            }
        }());
    </script>

    <asp:Panel ID="pnlCourseFeedback" runat="server" CssClass="card" Visible="false">
        <h2>Course feedback</h2>
        <p><asp:Literal ID="litFeedbackSummary" runat="server" /></p>
        <div class="form-panel">
            <h3><asp:Literal ID="litFeedbackFormHeading" runat="server" Text="Share your feedback" /></h3>
            <div class="form-group"><label for="<%= ddlCourseRating.ClientID %>">Your rating</label>
                <asp:DropDownList ID="ddlCourseRating" runat="server">
                    <asp:ListItem Value="5">5 - Excellent</asp:ListItem>
                    <asp:ListItem Value="4">4 - Very good</asp:ListItem>
                    <asp:ListItem Value="3">3 - Good</asp:ListItem>
                    <asp:ListItem Value="2">2 - Needs improvement</asp:ListItem>
                    <asp:ListItem Value="1">1 - Poor</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="form-group"><label for="<%= txtCourseFeedback.ClientID %>">What helped you learn? What could be better?</label>
                <asp:TextBox ID="txtCourseFeedback" runat="server" TextMode="MultiLine" Rows="4" MaxLength="1000" />
            </div>
            <asp:Button ID="btnSubmitCourseFeedback" runat="server" Text="Save feedback" CssClass="btn btn-primary" OnClick="btnSubmitCourseFeedback_Click" />
            <asp:Label ID="litFeedbackMessage" runat="server" CssClass="form-message" />
        </div>
        <asp:Panel ID="pnlNoCourseFeedback" runat="server" CssClass="empty-state" Visible="false">Be the first student to share course feedback.</asp:Panel>
        <asp:Repeater ID="rptCourseFeedback" runat="server">
            <HeaderTemplate><div class="card-grid"></HeaderTemplate>
            <ItemTemplate>
                <article class="card">
                    <strong><%#: Eval("StudentName") %></strong>
                    <span class="catalog-pill"><%#: Eval("Rating") %> / 5</span>
                    <p><%#: Eval("FeedbackText") %></p>
                    <small><%#: Eval("CreatedDate", "{0:MMM d, yyyy}") %></small>
                </article>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>
    </asp:Panel>

</asp:Content>

