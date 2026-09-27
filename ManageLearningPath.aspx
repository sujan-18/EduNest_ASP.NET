<%@ Page Title="Manage Learning Path" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageLearningPath.aspx.cs" Inherits="ManageLearningPath" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Manage Learning Path</h1>

    <div class="form-group">
        <label>Select Course</label>
        <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" />
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <!-- ============ INSERT ============ -->
    <div class="form-panel" style="max-width:100%; margin-bottom:30px;">
        <h2>Add Topic</h2>
        <div class="form-group">
            <label>Sequence Order</label>
            <asp:TextBox ID="txtOrder" runat="server" TextMode="Number" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOrder" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Topic Title</label>
            <asp:TextBox ID="txtTitle" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle" ValidationGroup="Insert"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <div class="form-group">
            <label>Content</label>
            <asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" />
        </div>
        <div class="form-group">
            <label>Learning resource title</label>
            <asp:TextBox ID="txtResourceTitle" runat="server" placeholder="For example: MDN HTML guide" />
        </div>
        <div class="form-group">
            <label>Learning resource URL (http or https)</label>
            <asp:TextBox ID="txtResourceUrl" runat="server" TextMode="Url" placeholder="https://..." />
        </div>
        <asp:Button ID="btnAdd" runat="server" Text="Add Topic" CssClass="btn btn-accent" ValidationGroup="Insert" OnClick="btnAdd_Click" />
    </div>

    <!-- ============ DISPLAY / UPDATE / DELETE ============ -->
    <asp:GridView ID="gvTopics" runat="server" AutoGenerateColumns="false" CssClass="data-table"
        DataKeyNames="TopicID" OnRowEditing="gvTopics_RowEditing" OnRowCancelingEdit="gvTopics_RowCancelingEdit"
        OnRowUpdating="gvTopics_RowUpdating" OnRowDeleting="gvTopics_RowDeleting">
        <Columns>
            <asp:TemplateField HeaderText="Order">
                <ItemTemplate><%#: Eval("SequenceOrder") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditOrder" TextMode="Number" Text='<%# Bind("SequenceOrder") %>' /></EditItemTemplate>
                <ItemStyle Width="70px" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Title">
                <ItemTemplate><%#: Eval("Title") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditTitle" Text='<%# Bind("Title") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Content">
                <ItemTemplate><%#: Eval("Content") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditContent" TextMode="MultiLine" Text='<%# Bind("Content") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Resource title">
                <ItemTemplate><%#: Eval("ResourceTitle") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditResourceTitle" Text='<%# Bind("ResourceTitle") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Resource URL">
                <ItemTemplate><%#: Eval("ResourceUrl") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditResourceUrl" TextMode="Url" Text='<%# Bind("ResourceUrl") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Button" />
        </Columns>
    </asp:GridView>

</asp:Content>
