<%@ Page Title="Review Submissions" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ReviewSubmissions.aspx.cs" Inherits="ReviewSubmissions" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-page">
        <div class="dashboard-welcome"><div><span class="eyebrow">TEACHING FEEDBACK</span><h1>Review student work</h1><p>Read submissions, leave actionable feedback, and record grades. Students see your review in their assignment page.</p></div><a class="btn btn-outline" href="ManageAssignments.aspx">Manage assignments</a></div>
        <div class="form-group review-course-filter"><label for="<%= ddlCourse.ClientID %>">Filter by course</label><asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_Changed" /></div>
        <asp:Panel ID="pnlMessage" runat="server" Visible="false"><div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div></asp:Panel>
        <asp:GridView ID="gvSubmissions" runat="server" AutoGenerateColumns="false" CssClass="data-table review-submissions-table" DataKeyNames="SubmissionID" AllowPaging="true" PageSize="8" OnPageIndexChanging="gvSubmissions_PageIndexChanging" OnRowEditing="gvSubmissions_RowEditing" OnRowCancelingEdit="gvSubmissions_RowCancelingEdit" OnRowUpdating="gvSubmissions_RowUpdating">
            <Columns>
                <asp:BoundField DataField="CourseTitle" HeaderText="Course" ReadOnly="true" />
                <asp:BoundField DataField="AssignmentTitle" HeaderText="Assignment" ReadOnly="true" />
                <asp:BoundField DataField="StudentName" HeaderText="Student" ReadOnly="true" />
                <asp:BoundField DataField="SubmittedDate" HeaderText="Submitted" DataFormatString="{0:dd MMM yyyy}" ReadOnly="true" />
                <asp:TemplateField HeaderText="Student submission"><ItemTemplate><div class="submission-text"><%#: Eval("SubmissionText") %></div></ItemTemplate><EditItemTemplate><div class="submission-text"><%#: Eval("SubmissionText") %></div></EditItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Grade / 100"><ItemTemplate><%# Eval("Grade") == DBNull.Value ? "Not graded" : Eval("Grade", "{0:0.##}") %></ItemTemplate><EditItemTemplate><asp:TextBox ID="txtEditGrade" runat="server" TextMode="Number" min="0" max="100" step="0.01" Text='<%# Eval("Grade") == DBNull.Value ? "" : Eval("Grade", "{0:0.##}") %>' /></EditItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Lecturer feedback"><ItemTemplate><div class="submission-feedback"><%#: Eval("Feedback") %></div></ItemTemplate><EditItemTemplate><asp:TextBox ID="txtEditFeedback" runat="server" TextMode="MultiLine" Rows="4" Text='<%# Bind("Feedback") %>' /></EditItemTemplate></asp:TemplateField>
                <asp:CommandField ShowEditButton="true" ButtonType="Button" EditText="Review" UpdateText="Save review" CancelText="Cancel" ControlStyle-CssClass="btn btn-small" />
            </Columns>
            <EmptyDataTemplate><div class="empty-state"><strong>No submissions to review yet.</strong><p>Student work will appear here after it is submitted.</p></div></EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Content>
