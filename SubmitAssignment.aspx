<%@ Page Title="Submit Assignment" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="SubmitAssignment.aspx.cs" Inherits="SubmitAssignment" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1><asp:Literal ID="litTitle" runat="server" /></h1>
    <p><asp:Literal ID="litDescription" runat="server" /></p>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlReview" runat="server" CssClass="assignment-review-card" Visible="false">
        <span class="eyebrow">LECTURER REVIEW</span><h2>Your result and feedback</h2>
        <p class="assignment-grade">Grade: <strong><asp:Literal ID="litGrade" runat="server" /></strong></p>
        <div class="assignment-feedback"><asp:Literal ID="litFeedback" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlClosed" runat="server" CssClass="alert alert-error" Visible="false"><asp:Literal ID="litClosed" runat="server" /></asp:Panel>

    <asp:Panel ID="pnlSubmissionForm" runat="server" CssClass="form-panel">
        <div class="form-group">
            <label>Your Submission</label>
            <asp:TextBox ID="txtSubmission" runat="server" TextMode="MultiLine" Rows="8" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSubmission"
                CssClass="field-error" ErrorMessage="Submission text cannot be empty." Display="Dynamic" />
        </div>
        <asp:Button ID="btnSubmit" runat="server" Text="Submit Assignment" CssClass="btn btn-block btn-accent" OnClick="btnSubmit_Click" />
    </asp:Panel>

</asp:Content>
