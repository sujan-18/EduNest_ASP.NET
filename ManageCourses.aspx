<%@ Page Title="Manage Courses" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageCourses.aspx.cs" Inherits="ManageCourses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Manage Courses</h1>
    <p>Full CRUD: add a new course, then edit or delete any row directly in the table below.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <!-- ============ INSERT ============ -->
    <div class="form-panel" style="max-width:100%; margin-bottom:30px;">
        <h2>Add New Course</h2>
        <div class="form-group">
            <label>Course Title</label>
            <asp:TextBox ID="txtTitle" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Title is required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
        </div>
        <asp:Button ID="btnAdd" runat="server" Text="Add Course" CssClass="btn btn-accent" ValidationGroup="Insert" OnClick="btnAdd_Click" />
    </div>

    <!-- ============ DISPLAY / UPDATE / DELETE ============ -->
    <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="false" CssClass="data-table"
        DataKeyNames="CourseID" OnRowEditing="gvCourses_RowEditing" OnRowCancelingEdit="gvCourses_RowCancelingEdit"
        OnRowUpdating="gvCourses_RowUpdating" OnRowDeleting="gvCourses_RowDeleting" GridLines="None">
        <Columns>
            <asp:BoundField DataField="CourseID" HeaderText="ID" ReadOnly="true" />
            <asp:TemplateField HeaderText="Title">
                <ItemTemplate><%#: Eval("Title") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditTitle" Text='<%# Bind("Title") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Description">
                <ItemTemplate><%#: Eval("Description") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditDescription" TextMode="MultiLine" Text='<%# Bind("Description") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" ReadOnly="true" />
            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true"
                ButtonType="Button" ControlStyle-CssClass="btn btn-small" />
        </Columns>
    </asp:GridView>

</asp:Content>
