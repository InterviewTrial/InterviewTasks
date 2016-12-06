﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TaskGenerator.ascx.cs" Inherits="JG_Prospect.Sr_App.Controls.TaskGenerator" %>
<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit.HTMLEditor" TagPrefix="ajax" %>

<link rel="stylesheet" href="../css/jquery-ui.css" />
<style>
    table tr th {
        border: 1px solid;
        padding: 0px;
    }

    table.table tr.trHeader {
        background: #000000;
        color: #ffffff;
    }

    .FirstRow {
        background: #f57575;
        padding: 2px;
    }

    .AlternateRow {
        background: #f6f1f3;
        padding: 2px;
    }

    .dark-gray-background {
        background-color: darkgray;
        background-image: none;
    }

    .AlternateRow a, .FirstRow a {
        color: #111;
    }

    .textbox {
        padding: 5px;
        border-radius: 5px;
        border: #b5b4b4 1px solid;
        margin-left: 0;
        margin-right: 0;
        margin-bottom: 5px;
    }

    .tablealign {
        margin-top: 5px;
    }

    div.dd_chk_select {
        height: 30px;
    }

        div.dd_chk_select div#caption {
            top: 7px;
            margin-left: 10px;
        }

    div.dd_chk_drop {
        top: 30px;
    }

    .ui-autocomplete {
        max-height: 250px;
        overflow-y: auto;
        /* prevent horizontal scrollbar */
        overflow-x: hidden;
    }

    .ui-autocomplete-category {
        font-weight: bold;
        padding: .2em .4em;
        margin: .8em 0 .2em;
        line-height: 1.5;
        text-align: center;
    }

    .ui-autocomplete-loading {
        background: white url("../img/ui-anim_basic_16x16.png") right center no-repeat;
    }

    .task-history-tab {
        min-height: 200px;
        max-height: 400px;
        overflow: auto;
        overflow-x: hidden;
    }
</style>

<div id="divTaskMain" class="tasklist">
    <asp:UpdatePanel ID="upnlTasks" runat="server" UpdateMode="Always">
        <ContentTemplate>
            <table class="table">
                <tr>
                    <td id="tdAddCap" runat="server" style="width: 7%;"></td>

                    <td id="tdDesigCap" runat="server">
                        <span style="color: #fefefe;">Designation:</span>
                    </td>
                    <td id="tdUserCap" runat="server">
                        <span style="color: #fefefe;">User:</span>
                    </td>
                    <td>
                        <span style="color: #fefefe;">Status:</span>
                    </td>
                    <td>
                        <span style="color: #fefefe;">Period From:</span>

                    </td>
                    <td><span style="color: #fefefe;">To:</span></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td style="display: none"></td>
                </tr>
                <tr>
                    <td id="tdAdd" runat="server" style="width: 7%;">

                        <asp:LinkButton ID="lbtnAddNew" runat="server" Text="Add New" OnClick="lbtnAddNew_Click" />
                    </td>

                    <td id="tdDesig" runat="server">

                        <asp:DropDownList ID="ddlDesignation" Width="130" AutoPostBack="true" runat="server" OnSelectedIndexChanged="ddlDesignation_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                                <asp:ListItem Text="ITLead" Value="ITLead"></asp:ListItem>
                                <asp:ListItem Text="Jr. Sales" Value="Jr. Sales"></asp:ListItem>
                                <asp:ListItem Text="Jr Project Manager" Value="Jr Project Manager"></asp:ListItem>
                                <asp:ListItem Text="Office Manager" Value="Office Manager"></asp:ListItem>
                                <asp:ListItem Text="Recruiter" Value="Recruiter"></asp:ListItem>
                                <asp:ListItem Text="Sales Manager" Value="Sales Manager"></asp:ListItem>
                                <asp:ListItem Text="Sr. Sales" Value="Sr. Sales"></asp:ListItem>
                                <asp:ListItem Text="IT - Network Admin" Value="ITNetworkAdmin"></asp:ListItem>
                                <asp:ListItem Text="IT - Jr .Net Developer" Value="ITJr.NetDeveloper"></asp:ListItem>
                                <asp:ListItem Text="IT - Sr .Net Developer" Value="ITSr.NetDeveloper"></asp:ListItem>
                                <asp:ListItem Text="IT - Android Developer" Value="ITAndroidDeveloper"></asp:ListItem>
                                <asp:ListItem Text="IT - PHP Developer" Value="ITPHPDeveloper"></asp:ListItem>
                                <asp:ListItem Text="IT - SEO / BackLinking" Value="ITSEOBackLinking"></asp:ListItem>
                                <asp:ListItem Text="Installer - Helper" Value="InstallerHelper"></asp:ListItem>
                                <asp:ListItem Text="Installer - Journeyman" Value="InstallerJourneyman"></asp:ListItem>
                                <asp:ListItem Text="Installer - Mechanic" Value="InstallerMechanic"></asp:ListItem>
                                <asp:ListItem Text="Installer - Lead mechanic" Value="InstallerLeadMechanic"></asp:ListItem>
                                <asp:ListItem Text="Installer - Foreman" Value="InstallerForeman"></asp:ListItem>
                                <asp:ListItem Text="Commercial Only" Value="CommercialOnly"></asp:ListItem>
                                <asp:ListItem Text="SubContractor" Value="SubContractor"></asp:ListItem>
                            </Items>
                        </asp:DropDownList></td>
                    <td id="tdUsers" runat="server">

                        <asp:DropDownList ID="ddlUsers" Width="100" AutoPostBack="true" runat="server" OnSelectedIndexChanged="ddlUsers_SelectedIndexChanged">
                        </asp:DropDownList></td>
                    <td>

                        <asp:DropDownList ID="ddlTaskStatus" Width="100" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlTaskStatus_SelectedIndexChanged">
                            <%--<asp:ListItem Text="--All--" Value="0"></asp:ListItem>
                            <asp:ListItem Text="Open" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                            <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                            <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                            <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                            <asp:ListItem Text="Closed" Value="6"></asp:ListItem>--%>
                        </asp:DropDownList></td>
                    <td>


                        <asp:TextBox ID="txtFromDate" CssClass="filter-datepicker" Width="80" runat="server"></asp:TextBox></td>
                    <td>
                        <asp:TextBox ID="txtToDate" CssClass="filter-datepicker" Width="80" runat="server"></asp:TextBox></td>
                    <td>

                        <%--<asp:TextBox ID="txtSearch" runat="server" onkeyup="javascript:setSearchTextKeyUpSearchTrigger(this);" Width="150"></asp:TextBox></td>--%>
                        <asp:TextBox ID="txtSearch" runat="server" PlaceHolder="Search.." Width="150"></asp:TextBox></td>
                    <td>
                        <asp:ImageButton ID="btnSearch" runat="server" ImageUrl="~/img/search_btn.png" CssClass="searchbtn" Style="display: none;" OnClick="btnSearch_Click" />
                    </td>
                    <td style="width: 8%;">
                        <asp:LinkButton ID="btnLoadMore" runat="server" Style="display: none;" Text="View More" OnClick="btnLoadMore_Click" />
                        <a id="hypViewMore" href="javascript:void(0);" data-expanded="0">View More</a>
                    </td>
                    <td style="display: none">
                        <%--<asp:Button ID="btnSubmit" runat="server" OnClick="btnSubmit_Click"  />--%>
                        <a id="hypTaskListMore" href="../Sr_App/TaskList.aspx">View All</a>
                    </td>
                </tr>
            </table>
            <div id="taskGrid">
                <asp:GridView ID="gvTasks" runat="server" EmptyDataRowStyle-ForeColor="White" EmptyDataRowStyle-HorizontalAlign="Center"
                    EmptyDataText="No task available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" GridLines="Vertical"
                    AutoGenerateColumns="False" AllowSorting="true" OnRowDataBound="gvTasks_RowDataBound" OnRowCommand="gvTasks_RowCommand"
                    DataKeyNames="TaskId,CreatedBy" HeaderStyle-ForeColor="White"
                    OnSorting="gvTasks_Sorting">
                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                    <HeaderStyle CssClass="trHeader " />
                    <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                    <AlternatingRowStyle CssClass="AlternateRow " />
                    <Columns>
                        <asp:BoundField DataField="InstallId" ItemStyle-CssClass="tip" HeaderText="ID#" HeaderStyle-Width="10%" SortExpression="InstallId" />
                        <asp:TemplateField HeaderText="Task Title" SortExpression="Title">
                            <ItemTemplate>
                                <asp:HyperLink ID="hypTask" runat="server" Text='<%# Eval("Title")%>' Target="_self" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Designation" HeaderStyle-Width="15%" SortExpression="TaskDesignations">
                            <ItemTemplate>
                                <a id="hypDesg" style="text-decoration: none;" class="tooltip" runat="server"></a>
                                <%-- <asp:Label ID="lblUserDesignation" runat="server" Text='<%# Eval("Designation") %>' HeaderStyle-Width="10%"></asp:Label>--%>
                                <%-- <asp:DropDownList ID="ddlRole" runat="server">
                                            <asp:ListItem Text="Sr.Developer"></asp:ListItem>
                                            <asp:ListItem Text="Jr.Developer"></asp:ListItem>
                                        </asp:DropDownList>--%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Assigned To" HeaderStyle-Width="12%" SortExpression="TaskAssignedUsers">
                            <ItemTemplate>
                                <a id="hypUsers" style="text-decoration: none;" class="tooltip" runat="server"></a>
                                <asp:DropDownCheckBoxes ID="ddcbAssigned" runat="server" UseSelectAllNode="false"
                                    AutoPostBack="true" OnSelectedIndexChanged="gvTasks_ddcbAssigned_SelectedIndexChanged">
                                    <Style SelectBoxWidth="100" DropDownBoxBoxWidth="100" DropDownBoxBoxHeight="150" />
                                    <Texts SelectBoxCaption="--Open--" />
                                </asp:DropDownCheckBoxes>
                                <div id="divAcceptRejectButtons" runat="server" visible="false">
                                    <asp:LinkButton ID="lbtnAcceptTask" runat="server" Text="Accept" CommandName="accept" CommandArgument='<%# Eval("TaskId") %>' />&nbsp;
                                    <asp:LinkButton ID="lbtnRejectTask" runat="server" Text="Reject" CommandName="reject" CommandArgument='<%# Eval("TaskId") %>' />
                                </div>
                                <asp:LinkButton ID="lbtnRequestStatus" runat="server" Visible="false" Text="Request" CommandName="request" CommandArgument='<%# Eval("TaskId") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status" HeaderStyle-Width="5%" SortExpression="Status">
                            <ItemTemplate>
                                <%--<asp:Label ID="lblTaskStatus" runat="server"></asp:Label>--%>
                                <asp:DropDownList ID="ddlTaskStatus" Width="100" OnSelectedIndexChanged="gvTasks_ddlTaskStatus_SelectedIndexChanged"
                                    AutoPostBack="true" runat="server">
                                    <%--<asp:ListItem Text="Open" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="Closed" Value="6"></asp:ListItem>--%>
                                </asp:DropDownList>
                                <asp:HiddenField ID="hdnTaskId" runat="server" Value='<%# Eval("TaskId") %>' />
                            </ItemTemplate>
                            <HeaderStyle Width="5%" />
                        </asp:TemplateField>
                        <%--<asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton ID="hypDelete" runat="server" OnClientClick="javascript: return confirm('Are you sure you want to remove this task?');" CommandName="RemoveTask" CommandArgument='<%# Eval("TaskId")%>' Text="Delete"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                    </Columns>
                </asp:GridView>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>

<div id="divModal" title="Task : Title" style="background: #efeeee url(../img/form-bg.png) repeat-x top; display: none;"
    runat="server" visible="false">
    <hr />
    <asp:UpdatePanel ID="upnlTaskPopup" runat="server">
        <ContentTemplate>
            <asp:ImageButton ID="btnRemoveTask" runat="server" ImageUrl="~/img/search_btn.png" Style="display: none;" OnClick="btnRemoveTask_Click" />
            <asp:HiddenField ID="hdnDeleteTaskId" runat="server" />
            <table id="tblAdminTaskView" runat="server" class="tablealign" width="100%">
                <tr>
                    <td width="150">Designation <span style="color: red;">*</span>:</td>
                    <td>
                        <asp:UpdatePanel ID="upnlDesignation" runat="server" RenderMode="Inline">
                            <ContentTemplate>
                                <asp:DropDownCheckBoxes ID="ddlUserDesignation" runat="server" UseSelectAllNode="false" AutoPostBack="true" OnSelectedIndexChanged="ddlUserDesignation_SelectedIndexChanged">
                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                    <Items>
                                        <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                                        <asp:ListItem Text="ITLead" Value="ITLead"></asp:ListItem>
                                        <asp:ListItem Text="Jr. Sales" Value="Jr. Sales"></asp:ListItem>
                                        <asp:ListItem Text="Jr Project Manager" Value="Jr Project Manager"></asp:ListItem>
                                        <asp:ListItem Text="Office Manager" Value="Office Manager"></asp:ListItem>
                                        <asp:ListItem Text="Recruiter" Value="Recruiter"></asp:ListItem>
                                        <asp:ListItem Text="Sales Manager" Value="Sales Manager"></asp:ListItem>
                                        <asp:ListItem Text="Sr. Sales" Value="Sr. Sales"></asp:ListItem>
                                        <asp:ListItem Text="IT - Network Admin" Value="ITNetworkAdmin"></asp:ListItem>
                                        <asp:ListItem Text="IT - Jr .Net Developer" Value="ITJr.NetDeveloper"></asp:ListItem>
                                        <asp:ListItem Text="IT - Sr .Net Developer" Value="ITSr.NetDeveloper"></asp:ListItem>
                                        <asp:ListItem Text="IT - Android Developer" Value="ITAndroidDeveloper"></asp:ListItem>
                                        <asp:ListItem Text="IT - PHP Developer" Value="ITPHPDeveloper"></asp:ListItem>
                                        <asp:ListItem Text="IT - SEO / BackLinking" Value="ITSEOBackLinking"></asp:ListItem>
                                        <asp:ListItem Text="Installer - Helper" Value="InstallerHelper"></asp:ListItem>
                                        <asp:ListItem Text="Installer - Journeyman" Value="InstallerJourneyman"></asp:ListItem>
                                        <asp:ListItem Text="Installer - Mechanic" Value="InstallerMechanic"></asp:ListItem>
                                        <asp:ListItem Text="Installer - Lead mechanic" Value="InstallerLeadMechanic"></asp:ListItem>
                                        <asp:ListItem Text="Installer - Foreman" Value="InstallerForeman"></asp:ListItem>
                                        <asp:ListItem Text="Commercial Only" Value="CommercialOnly"></asp:ListItem>
                                        <asp:ListItem Text="SubContractor" Value="SubContractor"></asp:ListItem>
                                    </Items>
                                </asp:DropDownCheckBoxes>
                                <asp:CustomValidator ID="cvDesignations" runat="server" ValidationGroup="Submit" ErrorMessage="Please Select Designation" Display="None" ClientValidationFunction="checkDesignations"></asp:CustomValidator>
                                <%--<asp:DropDownList ID="ddlUserDesignation" runat="server" CssClass="textbox" AutoPostBack="True" OnSelectedIndexChanged="txtDesignation_SelectedIndexChanged">
                                </asp:DropDownList>--%>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </td>
                    <td>Assigned:</td>
                    <td>
                        <asp:UpdatePanel ID="upnlAssigned" runat="server" RenderMode="Inline">
                            <ContentTemplate>
                                <asp:DropDownCheckBoxes ID="ddcbAssigned" runat="server" UseSelectAllNode="false"
                                    AutoPostBack="true" OnSelectedIndexChanged="ddcbAssigned_SelectedIndexChanged">
                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                    <Texts SelectBoxCaption="--Open--" />
                                </asp:DropDownCheckBoxes>
                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <%--                       <asp:DropDownList ID="ddlAssigned" runat="server" CssClass="textbox" onchange="addRow(this)">
                        <asp:ListItem Text="Darmendra"></asp:ListItem>
                        <asp:ListItem Text="Shabir"></asp:ListItem>
                       </asp:DropDownList>--%>
                  
                    </td>
                </tr>
                <tr>
                    <td colspan="4" valign="top">
                        <table width="100%" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="40%" valign="top">Task Title <span style="color: red;">*</span>:<br />
                                    <asp:TextBox ID="txtTaskTitle" runat="server" Style="width: 90%" CssClass="textbox"></asp:TextBox>
                                    <%--<ajax:Editor ID="txtTaskTitle" Width="100%" Height="20px" runat="server" ActiveMode="Design" AutoFocus="true" />--%>
                                    <asp:RequiredFieldValidator ID="rfvTaskTitle" ValidationGroup="Submit"
                                        runat="server" ControlToValidate="txtTaskTitle" ForeColor="Red" ErrorMessage="Please Enter Task Title" Display="None">                                 
                                    </asp:RequiredFieldValidator>
                                    <asp:HiddenField ID="controlMode" runat="server" />
                                    <asp:HiddenField ID="hdnTaskId" runat="server" Value="0" />
                                </td>
                                <td valign="top">
                                    <asp:UpdatePanel ID="upWorkSpecifications" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:TabContainer ID="tcWork" runat="server" ActiveTabIndex="0" AutoPostBack="false" Width="460">
                                                <asp:TabPanel ID="tpWork_Files" runat="server" TabIndex="0" CssClass="task-history-tab">
                                                    <HeaderTemplate>Work Files</HeaderTemplate>
                                                    <ContentTemplate>
                                                        <table>
                                                            <tr>
                                                                <td>Attachment(s):<br>
                                                                    <table>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:Repeater ID="rptWorkFiles" OnItemCommand="rptAttachment_ItemCommand" OnItemDataBound="rptAttachment_ItemDataBound" runat="server">
                                                                                    <ItemTemplate>
                                                                                        <small>
                                                                                            <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue"
                                                                                                CommandName="DownloadFile" /><asp:Literal ID="ltrlSeprator" runat="server" Text=" ," /></small>
                                                                                    </ItemTemplate>
                                                                                </asp:Repeater>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <input id="hdnWorkFiles" runat="server" type="hidden" />
                                                                                <div id="divWorkFile" class="drop-zone">
                                                                                    <div class="fallback">
                                                                                        <input name="WorkFile" type="file" multiple />
                                                                                        <input type="submit" value="UploadWorkFile" />
                                                                                    </div>
                                                                                </div>
                                                                                <div id="divWorkFilePreview" class="drop-zone-previews">
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div class="btn_sec">
                                                                                    <asp:Button ID="btnAddAttachment" runat="server" OnClick="btnAddAttachment_ClicK" Text="Save"
                                                                                        CssClass="ui-button" />
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                </asp:TabPanel>
                                                <asp:TabPanel ID="tpWork_Specifications" runat="server" TabIndex="1" CssClass="task-history-tab">
                                                    <HeaderTemplate>Work Specifications</HeaderTemplate>
                                                    <ContentTemplate>
                                                    </ContentTemplate>
                                                </asp:TabPanel>
                                            </asp:TabContainer>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">Task Description <span style="color: red;">*</span>:<br />
                        <asp:TextBox ID="txtDescription" TextMode="MultiLine" runat="server" CssClass="textbox" Width="100%" Rows="5"></asp:TextBox>
                        <%--<ajax:Editor ID="txtDescription" Width="100%" Height="100px" runat="server" ActiveMode="Design" AutoFocus="true" />--%>
                        <asp:RequiredFieldValidator ID="rfvDesc" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtDescription" ForeColor="Red" ErrorMessage="Please Enter Task Description" Display="None">                                 
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr id="trSubTaskList" runat="server">
                    <td colspan="4">
                        <fieldset class="tasklistfieldset">
                            <legend>Task List</legend>
                            <asp:UpdatePanel ID="upSubTasks" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div id="divSubTaskGrid">
                                        <asp:GridView ID="gvSubTasks" runat="server" ShowHeaderWhenEmpty="true" EmptyDataRowStyle-HorizontalAlign="Center"
                                            HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                                            EmptyDataText="No sub task available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0"
                                            AutoGenerateColumns="False" OnRowDataBound="gvSubTasks_RowDataBound" GridLines="Vertical">
                                            <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                            <HeaderStyle CssClass="trHeader " />
                                            <RowStyle CssClass="FirstRow" />
                                            <AlternatingRowStyle CssClass="AlternateRow " />
                                            <Columns>
                                                <asp:BoundField DataField="InstallId" HeaderText="List ID" HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                                <asp:TemplateField HeaderText="Task Description" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                                    <ItemTemplate>
                                                        <%# Eval("Description") %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <%--<asp:TemplateField HeaderText="Due Date" HeaderStyle-Width="11%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#  string.IsNullOrEmpty( Eval("DueDate").ToString() )?string.Empty: Convert.ToDateTime(Eval("DueDate")).ToShortDateString()%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Hrs. Est" HeaderStyle-Width="13%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# Eval("Hours") %>
                                                    </ItemTemplate>
                                                    <HeaderStyle Width="5%" />
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Note Ref:" HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        Note Ref#
                                                    </ItemTemplate>
                                                </asp:TemplateField>--%>
                                                <asp:TemplateField HeaderText="Type" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# String.IsNullOrEmpty(Eval("TaskType").ToString()) == true ? String.Empty : ddlTaskType.Items.FindByValue( Eval("TaskType").ToString()).Text %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Status" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# string.Concat(cmbStatus.Items.FindByValue( Eval("Status").ToString()).Text , ":" , Eval("FristName")).Trim().TrimEnd(':') %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Attachments" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left">
                                                    <ItemTemplate>
                                                        <asp:Repeater ID="rptAttachment" OnItemCommand="rptAttachment_ItemCommand" OnItemDataBound="rptAttachment_ItemDataBound" runat="server">
                                                            <ItemTemplate>
                                                                <small>
                                                                    <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue"
                                                                        CommandName="DownloadFile" /><asp:Literal ID="ltrlSeprator" runat="server" Text=" ," /></small>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <br />
                            <asp:UpdatePanel ID="upAddSubTask" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:LinkButton ID="lbtnAddNewSubTask" runat="server" Text="Add New Task" OnClick="lbtnAddNewSubTask_Click" />
                                    <br />
                                    <asp:ValidationSummary ID="vsSubTask" runat="server" ValidationGroup="vgSubTask" ShowSummary="False" ShowMessageBox="True" />
                                    <div id="divSubTask" runat="server" style="display: none;">
                                        <asp:HiddenField ID="hdnSubTaskId" runat="server" Value="0" />
                                        <table class="tablealign fullwidth">
                                            <tr>
                                                <td>ListID:
                                                   
                                                    <asp:TextBox ID="txtTaskListID" runat="server" />
                                                    &nbsp; <small><a href="javascript:void(0);" style="color: #06c;" onclick="copytoListID(this);">
                                                        <asp:Literal ID="listIDOpt" runat="server" />
                                                    </a></small></td>
                                                <td>Type:
                                                   
                                                    <asp:DropDownList ID="ddlTaskType" AutoPostBack="true" OnSelectedIndexChanged="ddlTaskType_SelectedIndexChanged" runat="server"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr style="display: none;">
                                                <td colspan="2">Title <span style="color: red;">*</span>:
                           
                                                    <br />
                                                    <asp:TextBox ID="txtSubTaskTitle" Text="N.A." runat="server" Width="98%" CssClass="textbox" />
                                                    <asp:RequiredFieldValidator ID="rfvSubTaskTitle" Visible="false" ValidationGroup="vgSubTask"
                                                        runat="server" ControlToValidate="txtSubTaskTitle" ForeColor="Red" ErrorMessage="Please Enter Task Title" Display="None" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">Description <span style="color: red;">*</span>:
                           
                                                    <br />
                                                    <asp:TextBox ID="txtSubTaskDescription" runat="server" CssClass="textbox" TextMode="MultiLine" Rows="5" Width="98%" />
                                                    <asp:RequiredFieldValidator ID="rfvSubTaskDescription" ValidationGroup="vgSubTask"
                                                        runat="server" ControlToValidate="txtSubTaskDescription" ForeColor="Red" ErrorMessage="Please Enter Task Description" Display="None" />
                                                </td>
                                            </tr>
                                            <tr id="trDateHours" runat="server" visible="false">
                                                <td>Due Date:
                           
                                                    <asp:TextBox ID="txtSubTaskDueDate" runat="server" CssClass="textbox datepicker" />
                                                    <%--<asp:CalendarExtender ID="ceSubTaskDueDate" runat="server" TargetControlID="txtSubTaskDueDate" PopupPosition="TopRight" />--%>
                                                </td>
                                                <td>Hrs of Task:
                           
                                                    <asp:TextBox ID="txtSubTaskHours" runat="server" CssClass="textbox" />
                                                    <asp:RegularExpressionValidator ID="revSubTaskHours" runat="server" ControlToValidate="txtSubTaskHours" Display="None"
                                                        ErrorMessage="Please enter decimal numbers for hours of task." ValidationGroup="vgSubTask"
                                                        ValidationExpression="(\d+\.\d{1,2})?\d*" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Attachment(s):<br>
                                                    <input id="hdnAttachments" runat="server" type="hidden" />
                                                    <div id="divSubTaskDropzone1" class="drop-zone" style="overflow: auto; width: 415px;">
                                                        <div class="fallback">
                                                            <input name="file" type="file" multiple />
                                                            <input type="submit" value="Upload" />
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div id="divSubTaskDropzonePreview1" class="drop-zone-previews">
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div class="btn_sec">
                                                        <asp:Button ID="btnSaveSubTask" runat="server" Text="Save Sub Task" CssClass="ui-button" ValidationGroup="vgSubTask"
                                                            OnClick="btnSaveSubTask_Click" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </fieldset>
                    </td>
                </tr>
                <tr>
                    <td>User Acceptance:</td>
                    <td>
                        <asp:DropDownList ID="ddlUserAcceptance" runat="server" CssClass="textbox">
                            <asp:ListItem Text="Accept" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Reject" Value="0"></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td>Due Date:</td>
                    <td>
                        <asp:TextBox ID="txtDueDate" runat="server" CssClass="textbox datepicker" />
                        <%--<asp:CalendarExtender ID="CEDueDate" runat="server" TargetControlID="txtDueDate"></asp:CalendarExtender>--%>
                        <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator3" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtDueDate" ForeColor="Red" ErrorMessage="Please Enter Due Date" Display="None">                                 
                        </asp:RequiredFieldValidator>--%>
                    </td>
                </tr>
                <tr>
                    <td>Hrs of Task:</td>
                    <td>
                        <asp:TextBox ID="txtHours" runat="server" CssClass="textbox" />
                        <asp:RegularExpressionValidator ID="revHours" runat="server" ControlToValidate="txtHours" Display="None"
                            ErrorMessage="Please enter decimal numbers for hours of task." ValidationGroup="Submit" ValidationExpression="(\d+\.\d{1,2})?\d*" />
                        <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator4" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtHours" ForeColor="Red" ErrorMessage="Please Enter Hours Of Task" Display="None">                                 
                        </asp:RequiredFieldValidator>--%>
                    </td>
                    <td>Staus:</td>
                    <td>
                        <asp:DropDownList ID="cmbStatus" runat="server" CssClass="textbox">
                            <%--<asp:ListItem Text="Open" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                            <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                            <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                            <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                            <asp:ListItem Text="Closed" Value="6"></asp:ListItem>--%>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div class="btn_sec">
                            <asp:Button ID="btnSaveTask" runat="server" Text="Save Task" CssClass="ui-button" ValidationGroup="Submit" OnClick="btnSaveTask_Click" />
                        </div>
                    </td>
                </tr>
            </table>
            <!-- table for userview -->
            <table id="tblUserTaskView" class="tablealign" style="width: 100%;" runat="server">
                <tr>

                    <td><b>Designation:</b>
                        <asp:Literal ID="ltlTUDesig" runat="server"></asp:Literal>
                    </td>

                    <td><b>Status:</b>
                        <asp:DropDownList ID="ddlTUStatus" AutoPostBack="true" runat="server" CssClass="textbox">
                            <%--<asp:ListItem Text="Open" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                            <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                            <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                            <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                            <asp:ListItem Text="Closed" Value="6"></asp:ListItem>--%>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2"><b>Task Title:</b>
                        <asp:Literal ID="ltlTUTitle" runat="server"></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td colspan="2"><b>Task Description:</b>
                        <asp:TextBox ID="txtTUDesc" TextMode="MultiLine" ReadOnly="true" Style="width: 100%;" Rows="10" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td><b>User Acceptance:</b>
                        <asp:DropDownList ID="ddlTUAcceptance" AutoPostBack="true" runat="server" CssClass="textbox">
                            <asp:ListItem Text="Accept" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Reject" Value="0"></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td><b>Due Date:</b>
                        <asp:Literal ID="ltlTUDueDate" runat="server"></asp:Literal></td>
                </tr>
                <tr>
                    <td><b>Hrs of Task:</b>
                        <asp:Literal ID="ltlTUHrsTask" runat="server"></asp:Literal></td>
                    <td></td>
                </tr>
            </table>
            <hr />
            <br />
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ValidationGroup="Submit" ShowSummary="False" ShowMessageBox="True" />
            <asp:UpdatePanel ID="upTaskHistory" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:TabContainer ID="tcTaskHistory" runat="server" ActiveTabIndex="0" AutoPostBack="false">
                        <asp:TabPanel ID="tpTaskHistory_Notes" runat="server" TabIndex="0" CssClass="task-history-tab">
                            <HeaderTemplate>Notes</HeaderTemplate>
                            <ContentTemplate>
                                <div class="grid">
                                    <asp:GridView ID="gdTaskUsers" runat="server" EmptyDataText="No task history available!" ShowHeaderWhenEmpty="true" AutoGenerateColumns="false" Width="100%" HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" AllowSorting="false" BackColor="White" PageSize="3" GridLines="Horizontal" OnRowDataBound="gdTaskUsers_RowDataBound" OnRowCommand="gdTaskUsers_RowCommand">
                                        <%--<EmptyDataTemplate>
                    </EmptyDataTemplate>--%>
                                        <Columns>
                                            <asp:TemplateField ShowHeader="True" HeaderText="User" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lbluser" runat="server" Text='<%#String.IsNullOrEmpty(Eval("FristName").ToString())== true ? Eval("UserFirstName").ToString() : Eval("FristName").ToString() %>'></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="True" HeaderText="Date & Time" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblupdateDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="false" Visible="false" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lbluserId" runat="server" Text='<%#Eval("Id")%>' Visible="false"></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <%--<asp:TemplateField ShowHeader="false" Visible="false" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                            ItemStyle-HorizontalAlign="Left">
                            <ItemTemplate>
                                <asp:Label ID="lbluserType" runat="server" Text='<%#Eval("UserType")%>' Visible="false"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                                            <asp:TemplateField ShowHeader="True" HeaderText="Notes" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblNotes" runat="server" Text='<%#Eval("Notes")%>'></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="True" HeaderText="Status" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="True" HeaderText="Files" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblFiles" runat="server" Text='<%# Eval("AttachmentCount")%>'></asp:Label>
                                                    <br>
                                                    <asp:LinkButton ID="lbtnAttachment" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("attachments")%>'></asp:LinkButton>
                                                </ItemTemplate>
                                                <ControlStyle ForeColor="Black" />
                                                <ControlStyle ForeColor="Black" />
                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:TemplateField>
                                        </Columns>
                                        <HeaderStyle BackColor="Black" ForeColor="White"></HeaderStyle>
                                    </asp:GridView>
                                    <%-- OnRowDataBound="GridView1_RowDataBound"    OnPageIndexChanging="GridView1_PageIndexChanging" OnRowCommand="GridView1_RowCommand"--%>
                                </div>
                                <br />
                                <table cellspacing="0" cellpadding="0" width="950px" border="1" style="width: 100%; border-collapse: collapse;">
                                    <tr>
                                        <td>Notes:
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Width="90%" CssClass="textbox"></asp:TextBox>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td colspan="2">
                                            <div class="btn_sec">
                                                <asp:Button ID="btnAddNote" runat="server" Text="Add Note & Files" CssClass="ui-button" OnClick="btnAddNote_Click" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                        </asp:TabPanel>
                        <asp:TabPanel ID="tpTaskHistory_FilesAndDocs" runat="server" TabIndex="0" CssClass="task-history-tab">
                            <HeaderTemplate>Files & docs</HeaderTemplate>
                            <ContentTemplate>
                                HTML Goes here 1
                           
                            </ContentTemplate>
                        </asp:TabPanel>
                        <asp:TabPanel ID="tpTaskHistory_Images" runat="server" TabIndex="0" CssClass="task-history-tab">
                            <HeaderTemplate>Images</HeaderTemplate>
                            <ContentTemplate>
                                HTML Goes here 3
                           
                            </ContentTemplate>
                        </asp:TabPanel>
                        <asp:TabPanel ID="tpTaskHistory_Links" runat="server" TabIndex="0" CssClass="task-history-tab">
                            <HeaderTemplate>Links</HeaderTemplate>
                            <ContentTemplate>
                                HTML Goes here 4
                           
                            </ContentTemplate>
                        </asp:TabPanel>
                        <asp:TabPanel ID="tpTaskHistory_Videos" runat="server" TabIndex="0" CssClass="task-history-tab">
                            <HeaderTemplate>Videos</HeaderTemplate>
                            <ContentTemplate>
                                HTML Goes here 5
                           
                            </ContentTemplate>
                        </asp:TabPanel>
                        <asp:TabPanel ID="tpTaskHistory_Audios" runat="server" TabIndex="0" CssClass="task-history-tab">
                            <HeaderTemplate>Audios</HeaderTemplate>
                            <ContentTemplate>
                                HTML Goes here 6
                           
                            </ContentTemplate>
                        </asp:TabPanel>
                    </asp:TabContainer>
                </ContentTemplate>
            </asp:UpdatePanel>
        </ContentTemplate>
    </asp:UpdatePanel>


</div>
<script>

    $(function () {

        //functions for auto search suggestions.
        createCategorisedAutoSearch();
        setAutoSearch();
        setDatePicker();
        setTaskDivClickTrigger();
        setClickableTooltip('#taskGrid');
        bindViewMore();
    });

    var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

    prmTaskGenerator.add_endRequest(function () {

        //functions for auto search suggestions.
        createCategorisedAutoSearch();
        setAutoSearch();
        setDatePicker();
        setTaskDivClickTrigger();
        setClickableTooltip('#<%=upnlTasks.ClientID%>');
        bindViewMore();
    });

    function RemoveTask(TaskId) {

        var userChoice = confirm('Are you sure you want to delete this task?');

        if (userChoice) {
            $("#<%=hdnDeleteTaskId.ClientID%>").val(TaskId);
            $('#<%=btnRemoveTask.ClientID %>').click();
        }

    }

    function setAutoSearch() {

        $("#<%=txtSearch.ClientID%>").catcomplete({
            delay: 500,
            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    url: "ajaxcalls.aspx/GetSearchSuggestions",
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    data: JSON.stringify({ searchterm: request.term }),
                    success: function (data) {
                        // Handle 'no match' indicated by [ "" ] response

                        if (data.d) {

                            response(data.length === 1 && data[0].length === 0 ? [] : JSON.parse(data.d));
                        }

                        // remove loading spinner image.                                
                        $("#<%=txtSearch.ClientID%>").removeClass("ui-autocomplete-loading");

                    }
                });
            },
            minLength: 2,
            select: function (event, ui) {
                //console.log(event);
                //console.log(ui);
                $("#<%=txtSearch.ClientID%>").val(ui.item.value);
                TriggerSearch();
            }
        });
        }

        function createCategorisedAutoSearch() {

            $.widget("custom.catcomplete", $.ui.autocomplete, {
                _create: function () {
                    this._super();
                    this.widget().menu("option", "items", "> :not(.ui-autocomplete-category)");
                },
                _renderMenu: function (ul, items) {
                    var that = this,
                      currentCategory = "";
                    $.each(items, function (index, item) {
                        var li;
                        if (item.Category != currentCategory) {
                            ul.append("<li class='ui-autocomplete-category'> Search " + item.Category + "</li>");
                            currentCategory = item.Category;
                        }
                        li = that._renderItemData(ul, item);
                        if (item.Category) {
                            li.attr("aria-label", item.Category + " : " + item.label);
                        }
                    });

                }
            });
        }

        function setTaskDivClickTrigger() {
            //On click of task list it should open tasklist page.
            $('#taskGrid').click(function (e) {

                if ($(e.target).is("a") || $(e.target).is("select") || e.target.id == "caption" || $(e.target).hasClass('dd_chk_select')) {
                    return true;
                }
                else {
                    window.location.href = $("#hypTaskListMore").attr("href");
                }
            });
        }

        // as soon as user will type 2 character it will go for search.
        function setSearchTextKeyUpSearchTrigger(textbox) {

            var searchText = $(textbox).val();

            if (searchText.length > 1) {
                TriggerSearch();
            }

            $(textbox).focus();
        }

        function EditTask(id, tasktitle) {

            window.open("TaskGenerator.aspx?TaskId=" + ($('#<%=hdnTaskId.ClientID%>').val()));
        }

        function setDatePicker() {
            // on date selection finish, trigger search, both dates must be selected.
            $('.filter-datepicker').datepicker({

                onSelect: function () {
                    checkDatePickerDatesNTriggerSearch();
                }
            });

            $('.datepicker').datepicker({ dateFormat: 'mm-dd-yy' });
        }

        function checkDatePickerDatesNTriggerSearch() {
            var fromdate, todate;
            fromdate = $('#<%= txtFromDate.ClientID %>').val();
                todate = $('#<%= txtToDate.ClientID %>').val();
                if (fromdate.length > 0 && todate.length > 0) {
                    TriggerSearch();
                }
                else if (fromdate.length == 0 && todate.length == 0) {
                    TriggerSearch();
                }
            }

            function SetHeaderSectionHeight() {
                //$('.tasklist').css('max-height', '800px');
                $('.tasklist').animate({ 'maxHeight': 600 }, 1000);
            }

            function HideHeaderSectionHeight() {
                //$('.tasklist').css('max-height', '165px');
                $('.tasklist').animate({ 'maxHeight': 165 }, 1000);
            }

            function TriggerSearch() {
                $('#<%=btnSearch.ClientID %>').click();

            }

            function setClickableTooltip(target) {
                $(target).mouseenter(function () {

                    var hyperlinkview = $("#hypViewMore");
                    var expanded = hyperlinkview.attr("data-expanded");
                    if (expanded == "0") {
                        toggleShowMoreResults(expanded, hyperlinkview);
                    }
                });

                $(target).mouseleave(function () {

                    HideHeaderSectionHeight();
                    var linkobject = $("#hypViewMore");
                    $(linkobject).html("View More");
                    $(linkobject).attr("data-expanded", "0");
                });
            }

            function bindViewMore() {

                $("#hypViewMore").click(function () {
                    var expanded = $(this).attr("data-expanded");
                    toggleShowMoreResults(expanded, this);
                });
            }

            function toggleShowMoreResults(view, linkobject) {

                if (view == "0") {// if content is hidden than expand it.
                    SetHeaderSectionHeight();
                    $(linkobject).html("Hide");
                    $(linkobject).attr("data-expanded", "1");
                }
                else {
                    HideHeaderSectionHeight();
                    $(linkobject).html("View More");
                    $(linkobject).attr("data-expanded", "0");
                }
            }

</script>
