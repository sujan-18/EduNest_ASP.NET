<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="form-panel">
        <h2>Log In to EduNest</h2>

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="alert alert-success">Registration successful! You can now log in.</div>
        </asp:Panel>
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="alert alert-error"><asp:Literal ID="litError" runat="server" /></div>
        </asp:Panel>

        <div class="form-group">
            <label for="<%=txtEmail.ClientID%>">Email Address</label>
            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                CssClass="field-error" ErrorMessage="Email is required." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label for="<%=txtPassword.ClientID%>">Password</label>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                CssClass="field-error" ErrorMessage="Password is required." Display="Dynamic" />
        </div>

        <asp:Button ID="btnLogin" runat="server" Text="Log In" CssClass="btn btn-block" OnClick="btnLogin_Click" />

        <p style="text-align:center; margin-top:14px;">
            New to EduNest? <a href="Register.aspx">Create an account</a>
        </p>
        <p style="text-align:center; font-size:12px; color:#888;">
            Demo accounts (password: <strong>Password123</strong>):<br />
            admin@edunest.com &middot; lecturer@edunest.com &middot; student@edunest.com
        </p>
    </div>

</asp:Content>
