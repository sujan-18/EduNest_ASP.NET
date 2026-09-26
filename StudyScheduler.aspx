<%@ Page Title="Study Scheduler" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="StudyScheduler.aspx.cs" Inherits="StudyScheduler" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Study Room Scheduler</h1>
    <p>Create a virtual study session or join one a classmate has already scheduled.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <div class="form-panel" style="max-width:100%; margin-bottom:24px;">
        <h2>Schedule a New Session</h2>
        <div class="form-group">
            <label>Title</label>
            <asp:TextBox ID="txtTitle" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Date</label>
            <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDate" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Time</label>
            <asp:TextBox ID="txtTime" runat="server" TextMode="Time" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTime" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Description</label>
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
        </div>
        <asp:Button ID="btnAdd" runat="server" Text="Schedule Session" CssClass="btn btn-accent" ValidationGroup="Insert" OnClick="btnAdd_Click" />
    </div>

    <h2>Upcoming Sessions</h2>
    <asp:Repeater ID="rptSessions" runat="server" OnItemCommand="rptSessions_ItemCommand">
        <HeaderTemplate><div class="card-grid"></HeaderTemplate>
        <ItemTemplate>
            <div class="card">
                <h3><%#: Eval("Title") %></h3>
                <p><%# Eval("SessionDate", "{0:dd MMM yyyy}") %> at <%# Eval("SessionTime") %></p>
                <p><%#: Eval("Description") %></p>
                <p><small>Hosted by <%#: Eval("HostName") %> &middot; <%#: Eval("ParticipantCount") %> joined</small></p>

                <asp:Button runat="server" CommandName="Join" CommandArgument='<%# Eval("SessionID") %>'
                    Text="Join Session" CssClass="btn btn-small btn-accent" Visible='<%# !Convert.ToBoolean(Eval("HasJoined")) && !Convert.ToBoolean(Eval("IsHost")) %>' />
                <asp:Button runat="server" CommandName="Leave" CommandArgument='<%# Eval("SessionID") %>'
                    Text="Leave" CssClass="btn btn-small" Visible='<%# Convert.ToBoolean(Eval("HasJoined")) %>' />
                <asp:Button runat="server" CommandName="Delete" CommandArgument='<%# Eval("SessionID") %>'
                    Text="Cancel Session" CssClass="btn btn-small btn-danger" Visible='<%# Convert.ToBoolean(Eval("IsHost")) %>' />
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

</asp:Content>
