<%@ Page Title="Manage Assignments" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageAssignments.aspx.cs" Inherits="ManageAssignments" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Manage Assignments</h1>

    <div class="form-group">
        <label>Select Course</label>
        <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_Changed" />
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <div class="form-panel" style="max-width:100%; margin-bottom:24px;">
        <h2>Add Assignment</h2>
        <div class="form-group">
            <label>Title</label>
            <asp:TextBox ID="txtTitle" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
        </div>
        <div class="form-group">
            <label>Due Date</label>
            <asp:TextBox ID="txtDueDate" runat="server" TextMode="Date" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDueDate" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <asp:Button ID="btnAdd" runat="server" Text="Add Assignment" CssClass="btn btn-accent" ValidationGroup="Insert" OnClick="btnAdd_Click" />
    </div>

    <asp:GridView ID="gvAssignments" runat="server" AutoGenerateColumns="false" CssClass="data-table"
        DataKeyNames="AssignmentID" OnRowEditing="gvAssignments_RowEditing" OnRowCancelingEdit="gvAssignments_RowCancelingEdit"
        OnRowUpdating="gvAssignments_RowUpdating" OnRowDeleting="gvAssignments_RowDeleting">
        <Columns>
            <asp:TemplateField HeaderText="Title">
                <ItemTemplate><%#: Eval("Title") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditTitle" Text='<%# Bind("Title") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Description">
                <ItemTemplate><%#: Eval("Description") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditDescription" TextMode="MultiLine" Text='<%# Bind("Description") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Due Date">
                <ItemTemplate><%#: Eval("DueDate", "{0:dd MMM yyyy}") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditDueDate" TextMode="Date" Text='<%# Eval("DueDate", "{0:yyyy-MM-dd}") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="SubmissionCount" HeaderText="Submissions" ReadOnly="true" />
            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Button" />
        </Columns>
    </asp:GridView>

</asp:Content>
