<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>
<asp:Content ID="LoginScripts" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Scripts/demo-login.js?v=role-entry-1" defer></script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="form-panel">
        <h2>Log In to EduNest</h2>
        <p class="login-role-hint">Your account role opens its own workspace automatically: Student, Teacher (Lecturer), or Administrator.</p>

        <asp:Panel ID="pnlCurrentSession" runat="server" Visible="false">
            <div class="alert alert-info">Currently signed in as <asp:Literal ID="litCurrentSession" runat="server" />. Logging in here will switch to the selected account.</div>
        </asp:Panel>

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
            <div class="alert alert-success">Registration successful! You can now log in.</div>
        </asp:Panel>
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div class="alert alert-error"><asp:Literal ID="litError" runat="server" /></div>
        </asp:Panel>

        <div class="form-group">
            <label for="txtEmail">Email Address</label>
            <asp:TextBox ID="txtEmail" runat="server" ClientIDMode="Static" TextMode="Email" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                CssClass="field-error" ErrorMessage="Email is required." Display="Dynamic" />
        </div>

        <div class="form-group">
            <label for="txtPassword">Password</label>
            <asp:TextBox ID="txtPassword" runat="server" ClientIDMode="Static" TextMode="Password" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                CssClass="field-error" ErrorMessage="Password is required." Display="Dynamic" />
        </div>

        <asp:Button ID="btnLogin" runat="server" ClientIDMode="Static" Text="Log In" CssClass="btn btn-block" OnClick="btnLogin_Click" />

        <p style="text-align:center; margin-top:14px;">
            New to EduNest? <a href="Register.aspx">Create an account</a>
        </p>
        <div class="demo-role-picker" aria-label="Demo sign-in accounts">
            <span class="eyebrow">TRY A DEMO WORKSPACE</span>
            <button type="button" class="demo-role-button" data-demo-email="student@edunest.com"><strong>Student</strong><small>Progress, quizzes, and courses</small></button>
            <button type="button" class="demo-role-button" data-demo-email="prakriti.joshi@edunest.com"><strong>Teacher / Lecturer</strong><small>Manage courses and review work</small></button>
            <button type="button" class="demo-role-button" data-demo-email="admin@edunest.com"><strong>Administrator</strong><small>Manage users and the platform</small></button>
            <small class="demo-role-password">Demo password: <strong>Password123</strong>. Select a role, then click Log In.</small>
        </div>
    </div>

</asp:Content>
