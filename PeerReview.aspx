<%@ Page Title="Peer Review" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="PeerReview.aspx.cs" Inherits="PeerReview" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Peer Review</h1>
    <p>Give structured feedback on classmates' assignment submissions using the rubric below.</p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <asp:Repeater ID="rptSubmissions" runat="server" OnItemCommand="rptSubmissions_ItemCommand">
        <ItemTemplate>
            <div class="card" style="margin-bottom:18px;">
                <h3><%#: Eval("AssignmentTitle") %> &mdash; submitted by <%#: Eval("StudentName") %></h3>
                <p><%#: Eval("SubmissionText") %></p>

                <div class="form-group">
                    <label>Your Feedback</label>
                    <asp:TextBox runat="server" ID="txtFeedback" TextMode="MultiLine" />
                </div>
                <div class="form-group" style="max-width:160px;">
                    <label>Rating (1-5)</label>
                    <asp:DropDownList runat="server" ID="ddlRating">
                        <asp:ListItem Text="1" Value="1" /><asp:ListItem Text="2" Value="2" />
                        <asp:ListItem Text="3" Value="3" /><asp:ListItem Text="4" Value="4" />
                        <asp:ListItem Text="5" Value="5" Selected="true" />
                    </asp:DropDownList>
                </div>
                <asp:Button runat="server" CommandName="Review" CommandArgument='<%# Eval("SubmissionID") %>'
                    Text="Submit Review" CssClass="btn btn-small btn-accent" />
            </div>
        </ItemTemplate>
        <FooterTemplate>
            <asp:Literal runat="server" ID="litEmpty" />
        </FooterTemplate>
    </asp:Repeater>

    <h2>Reviews You've Given</h2>
    <asp:GridView ID="gvMyReviews" runat="server" AutoGenerateColumns="false" CssClass="data-table">
        <Columns>
            <asp:BoundField DataField="AssignmentTitle" HeaderText="Assignment" />
            <asp:BoundField DataField="Feedback" HeaderText="Feedback" />
            <asp:BoundField DataField="Rating" HeaderText="Rating" />
        </Columns>
        <EmptyDataTemplate>You haven't reviewed anything yet.</EmptyDataTemplate>
    </asp:GridView>

</asp:Content>
