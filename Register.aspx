<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Register" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="form-panel">
        <h2>Create Your EduNest Account</h2>

        <asp:Panel ID="pnlMessage" runat="server" Visible="false">
            <div class="alert alert-error"><asp:Literal ID="litMessage" runat="server" /></div>
        </asp:Panel>

        <div class="form-group">
            <label for="<%=txtFullName.ClientID%>">Full Name</label>
            <asp:TextBox ID="txtFullName" runat="server" CssClass="" placeholder="e.g. Sujan Shrestha" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFullName"
                CssClass="field-error" ErrorMessage="Full name is required." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label for="<%=txtEmail.ClientID%>">Email Address</label>
            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="sujanshrestha1822@example.com" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                CssClass="field-error" ErrorMessage="Email is required." Display="Dynamic" />
            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail"
                ValidationExpression="^[^\s@]+@[^\s@]+\.[^\s@]+$"
                CssClass="field-error" ErrorMessage="Enter a valid email address." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label for="<%=txtPassword.ClientID%>">Password</label>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                CssClass="field-error" ErrorMessage="Password is required." Display="Dynamic" />
            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPassword"
                ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{8,}$"
                CssClass="field-error" ErrorMessage="Min 8 characters, with at least one letter and one number." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label for="<%=txtConfirmPassword.ClientID%>">Confirm Password</label>
            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" />
            <asp:CompareValidator runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                CssClass="field-error" ErrorMessage="Passwords do not match." Display="Dynamic" />
        </div>

        <p>Public registration creates a student account. Lecturers are added by an administrator.</p>

        <asp:Button ID="btnRegister" runat="server" Text="Create Account" CssClass="btn btn-block" OnClick="btnRegister_Click" />

        <p style="text-align:center; margin-top:14px;">
            Already have an account? <a href="Login.aspx">Log in</a>
        </p>
    </div>

</asp:Content>
