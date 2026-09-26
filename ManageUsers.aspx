<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageUsers.aspx.cs" Inherits="ManageUsers" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Manage Users</h1>
    <p>Administrators can create staff/student accounts directly, edit roles, deactivate, or permanently delete a user.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <!-- ============ INSERT ============ -->
    <div class="form-panel user-create-panel">
        <h2>Create User Account</h2>
        <div class="user-create-fields">
            <div class="form-group">
                <label>Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFullName" ValidationGroup="Insert"
                    CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail" ValidationGroup="Insert"
                    CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail" ValidationGroup="Insert"
                    ValidationExpression="^[^\s@]+@[^\s@]+\.[^\s@]+$" CssClass="field-error" ErrorMessage="Invalid email." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label>Temporary Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword" ValidationGroup="Insert"
                    CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
            </div>
            <div class="form-group">
                <label>Role</label>
                <asp:DropDownList ID="ddlRole" runat="server">
                    <asp:ListItem Text="Student" Value="Student" />
                    <asp:ListItem Text="Lecturer" Value="Lecturer" />
                    <asp:ListItem Text="Admin" Value="Admin" />
                </asp:DropDownList>
            </div>
        </div>
        <asp:Button ID="btnAdd" runat="server" Text="Create User" CssClass="btn btn-accent" ValidationGroup="Insert" OnClick="btnAdd_Click" />
    </div>

    <!-- ============ DISPLAY / UPDATE / DELETE ============ -->
    <div class="users-table-scroll">
    <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" CssClass="data-table users-data-table"
        DataKeyNames="UserID" OnRowEditing="gvUsers_RowEditing" OnRowCancelingEdit="gvUsers_RowCancelingEdit"
        OnRowUpdating="gvUsers_RowUpdating" OnRowDeleting="gvUsers_RowDeleting" OnRowDataBound="gvUsers_RowDataBound">
        <Columns>
            <asp:BoundField DataField="FullName" HeaderText="Name" />
            <asp:BoundField DataField="Email" HeaderText="Email" ReadOnly="true" />
            <asp:TemplateField HeaderText="Role">
                <ItemTemplate><span class="badge badge-<%# Eval("Role").ToString().ToLower() %>"><%# Eval("Role") %></span></ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList runat="server" ID="ddlEditRole">
                        <asp:ListItem Text="Student" Value="Student" />
                        <asp:ListItem Text="Lecturer" Value="Lecturer" />
                        <asp:ListItem Text="Admin" Value="Admin" />
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Active">
                <ItemTemplate><%# Convert.ToBoolean(Eval("IsActive")) ? "Yes" : "No" %></ItemTemplate>
                <EditItemTemplate><asp:CheckBox runat="server" ID="chkActive" Checked='<%# Convert.ToBoolean(Eval("IsActive")) %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Button" />
        </Columns>
    </asp:GridView>
    </div>

</asp:Content>
