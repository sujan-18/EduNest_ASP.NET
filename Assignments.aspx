<%@ Page Title="Assignments" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Assignments.aspx.cs" Inherits="Assignments" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Course Assignments</h1>
    <asp:Repeater ID="rptAssignments" runat="server">
        <HeaderTemplate><div class="card-grid"></HeaderTemplate>
        <ItemTemplate>
            <div class="card">
                <h3><%#: Eval("Title") %></h3>
                <p><%#: Eval("Description") %></p>
                <p><strong>Due:</strong> <%#: Eval("DueDate", "{0:dd MMM yyyy}") %></p>
                <span class="badge <%# Convert.ToBoolean(Eval("HasSubmitted")) ? "badge-student" : "badge-admin" %>">
                    <%# Convert.ToBoolean(Eval("HasSubmitted")) ? "Submitted" : "Not Submitted" %>
                </span>
                <div style="margin-top:10px;">
                    <a class="btn btn-small" href="SubmitAssignment.aspx?AssignmentID=<%# Eval("AssignmentID") %>">
                        <%# Convert.ToBoolean(Eval("HasSubmitted")) ? "View / Resubmit" : "Submit" %>
                    </a>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

</asp:Content>
