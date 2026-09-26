<%@ Page Title="Manage Quizzes" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ManageQuizzes.aspx.cs" Inherits="ManageQuizzes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h1>Manage Quizzes</h1>

    <div class="form-group">
        <label>Select Course</label>
        <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_Changed" />
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false">
        <div class="alert alert-success"><asp:Literal ID="litMessage" runat="server" /></div>
    </asp:Panel>

    <!-- Add a new quiz shell -->
    <div class="form-panel" style="max-width:100%; margin-bottom:24px;">
        <h2>Create Quiz</h2>
        <div class="form-group">
            <label>Quiz Title</label>
            <asp:TextBox ID="txtQuizTitle" runat="server" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuizTitle" ValidationGroup="Quiz"
                CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
        </div>
        <asp:Button ID="btnAddQuiz" runat="server" Text="Create Quiz" CssClass="btn btn-accent" ValidationGroup="Quiz" OnClick="btnAddQuiz_Click" />
    </div>

    <h2>Existing Quizzes</h2>
    <asp:GridView ID="gvQuizzes" runat="server" AutoGenerateColumns="false" CssClass="data-table"
        DataKeyNames="QuizID" OnSelectedIndexChanged="gvQuizzes_SelectedIndexChanged" OnRowDeleting="gvQuizzes_RowDeleting"
        OnRowEditing="gvQuizzes_RowEditing" OnRowCancelingEdit="gvQuizzes_RowCancelingEdit" OnRowUpdating="gvQuizzes_RowUpdating">
        <Columns>
            <asp:TemplateField HeaderText="Quiz Title"><ItemTemplate><%#: Eval("Title") %></ItemTemplate>
                <EditItemTemplate><asp:TextBox runat="server" ID="txtEditQuizTitle" Text='<%# Bind("Title") %>' /></EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="QuestionCount" HeaderText="Questions" />
            <asp:ButtonField CommandName="Select" Text="Manage Questions" ButtonType="Button" ControlStyle-CssClass="btn btn-small" />
            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Button" />
        </Columns>
    </asp:GridView>

    <!-- Question management for the selected quiz -->
    <asp:Panel ID="pnlQuestions" runat="server" Visible="false">
        <h2 style="margin-top:32px;">Questions for: <asp:Literal ID="litSelectedQuiz" runat="server" /></h2>

        <div class="form-panel" style="max-width:100%; margin-bottom:24px;">
            <div class="form-group">
                <label>Question Text</label>
                <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuestion" ValidationGroup="Question"
                    CssClass="field-error" ErrorMessage="Required." Display="Dynamic" />
            </div>
            <div class="form-group"><label>Option A</label><asp:TextBox ID="txtOptionA" runat="server" /></div>
            <div class="form-group"><label>Option B</label><asp:TextBox ID="txtOptionB" runat="server" /></div>
            <div class="form-group"><label>Option C</label><asp:TextBox ID="txtOptionC" runat="server" /></div>
            <div class="form-group"><label>Option D</label><asp:TextBox ID="txtOptionD" runat="server" /></div>
            <div class="form-group">
                <label>Correct Option</label>
                <asp:DropDownList ID="ddlCorrect" runat="server">
                    <asp:ListItem Text="A" Value="A" /><asp:ListItem Text="B" Value="B" />
                    <asp:ListItem Text="C" Value="C" /><asp:ListItem Text="D" Value="D" />
                </asp:DropDownList>
            </div>
            <asp:Button ID="btnAddQuestion" runat="server" Text="Add Question" CssClass="btn btn-accent" ValidationGroup="Question" OnClick="btnAddQuestion_Click" />
        </div>

        <asp:GridView ID="gvQuestions" runat="server" AutoGenerateColumns="false" CssClass="data-table"
            DataKeyNames="QuestionID" OnRowEditing="gvQuestions_RowEditing" OnRowCancelingEdit="gvQuestions_RowCancelingEdit"
            OnRowUpdating="gvQuestions_RowUpdating" OnRowDataBound="gvQuestions_RowDataBound" OnRowDeleting="gvQuestions_RowDeleting">
            <Columns>
                <asp:TemplateField HeaderText="Question">
                    <ItemTemplate><%#: Eval("QuestionText") %></ItemTemplate>
                    <EditItemTemplate><asp:TextBox runat="server" ID="txtEditQuestion" Text='<%# Bind("QuestionText") %>' /></EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Option A"><ItemTemplate><%#: Eval("OptionA") %></ItemTemplate><EditItemTemplate><asp:TextBox runat="server" ID="txtEditA" Text='<%# Bind("OptionA") %>' /></EditItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Option B"><ItemTemplate><%#: Eval("OptionB") %></ItemTemplate><EditItemTemplate><asp:TextBox runat="server" ID="txtEditB" Text='<%# Bind("OptionB") %>' /></EditItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Option C"><ItemTemplate><%#: Eval("OptionC") %></ItemTemplate><EditItemTemplate><asp:TextBox runat="server" ID="txtEditC" Text='<%# Bind("OptionC") %>' /></EditItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Option D"><ItemTemplate><%#: Eval("OptionD") %></ItemTemplate><EditItemTemplate><asp:TextBox runat="server" ID="txtEditD" Text='<%# Bind("OptionD") %>' /></EditItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Correct"><ItemTemplate><%#: Eval("CorrectOption") %></ItemTemplate><EditItemTemplate>
                    <asp:DropDownList runat="server" ID="ddlEditCorrect"><asp:ListItem>A</asp:ListItem><asp:ListItem>B</asp:ListItem><asp:ListItem>C</asp:ListItem><asp:ListItem>D</asp:ListItem></asp:DropDownList>
                </EditItemTemplate></asp:TemplateField>
                <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Button" />
            </Columns>
        </asp:GridView>
    </asp:Panel>

</asp:Content>
