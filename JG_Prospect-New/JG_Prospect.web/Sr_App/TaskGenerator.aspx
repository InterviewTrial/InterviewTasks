<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="TaskGenerator.aspx.cs"
    Inherits="JG_Prospect.Sr_App.TaskGenerator" ValidateRequest="false" EnableEventValidation="false"
    MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>
<%@ Register Assembly="CKEditor.NET" Namespace="CKEditor.NET" TagPrefix="CKEditor" %>
<%@ Register Src="~/Controls/CustomPager.ascx" TagPrefix="uc1" TagName="CustomPager" %>
<%@ Register Src="~/Sr_App/Controls/ucTaskWorkSpecifications.ascx" TagPrefix="uc1" TagName="ucTaskWorkSpecifications" %>
<%@ Register Src="~/Sr_App/Controls/ucTaskHistory.ascx" TagPrefix="uc1" TagName="ucTaskHistory" %>
<%@ Register Src="~/Sr_App/Controls/ucSubTasks.ascx" TagPrefix="uc1" TagName="ucSubTasks" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="../css/jquery-ui.css" />
    <link href="../css/dropzone/css/basic.css" rel="stylesheet" />
    <link href="../css/dropzone/css/dropzone.css" rel="stylesheet" />
    <link href="../css/jquery.contextMenu.min.css" rel="stylesheet" />
    <script src="../ckeditor/ckeditor.js"></script>    
    <script src="../js/clipboard.min.js"></script>
    <script type="text/javascript" src="../js/dropzone.js"></script>

    <div class="right_panel">
        <hr />
        <asp:UpdatePanel ID="upTask" runat="server">
            <ContentTemplate>
                <h1>Task</h1>
                <table id="tblTaskHeader" runat="server" visible="false" class="appointment_tab"
                    style="position: absolute; top: 221px; right: 39px; background-color: #fff;">
                    <tr>
                        <td width="25%" align="left">
                            <asp:LinkButton ID="lbtnDeleteTask" runat="server" OnClick="lbtnDeleteTask_Click" Text="Delete" />
                            &nbsp;&nbsp;Task ID#:
                           
                            <asp:Literal ID="ltrlInstallId" runat="server" /></td>
                        <td align="center">Date Created:
                           
                            <asp:Literal ID="ltrlDateCreated" runat="server" /></td>
                        <td width="25%" align="right">
                            <asp:Literal ID="ltrlAssigningManager" runat="server" /></td>
                    </tr>
                </table>
                <div class="form_panel_custom">
                    <table id="tblAdminTaskView" runat="server" class="tablealign"
                        width="100%" cellspacing="5">
                        <tr>
                            <td style="width: 40%;">Designation <span style="color: red;">*</span>: 
                               

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
                            <td>Assigned:    

                                <asp:UpdatePanel ID="upnlAssigned" runat="server" RenderMode="Inline">
                                    <ContentTemplate>
                                        <asp:DropDownCheckBoxes ID="ddlAssignedUsers" runat="server" UseSelectAllNode="false"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlAssignedUsers_SelectedIndexChanged">
                                            <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                            <Texts SelectBoxCaption="--Open--" />
                                        </asp:DropDownCheckBoxes>
                                        <asp:LinkButton ID="lbtnViewAcceptanceLog" runat="server" Text="View Acceptance Log" OnClick="lbtnViewAcceptanceLog_Click" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <span style="padding-left: 20px;">
                                    <asp:CheckBox ID="chkTechTask" runat="server" Checked="false" Text=" Tech Task" />
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td class="valigntop">Task Title <span style="color: red;">*</span>:<br />
                                <asp:TextBox ID="txtTaskTitle" runat="server" Style="width: 90%" CssClass="textbox"></asp:TextBox>
                                <%--<ajax:Editor ID="txtTaskTitle" Width="100%" Height="20px" runat="server" ActiveMode="Design" AutoFocus="true" />--%>
                                <asp:RequiredFieldValidator ID="rfvTaskTitle" ValidationGroup="Submit"
                                    runat="server" ControlToValidate="txtTaskTitle" ForeColor="Red" ErrorMessage="Please Enter Task Title" Display="None">                                 
                                </asp:RequiredFieldValidator>
                                <asp:HiddenField ID="controlMode" runat="server" />
                                <asp:HiddenField ID="hdnTaskId" runat="server" Value="0" />
                            </td>
                            <td style="vertical-align: middle;">

                                <asp:LinkButton ID="lbtnShowWorkSpecificationSection" runat="server" Text="Work Specification Files"
                                    ValidationGroup="Submit" OnClick="lbtnShowWorkSpecificationSection_Click" />
                                <asp:LinkButton ID="lbtnShowFinishedWorkFiles" runat="server" Text="Finished Work Files"
                                    ValidationGroup="Submit" OnClick="lbtnShowFinishedWorkFiles_Click" />

                            </td>
                        </tr>
                        <tr>
                            <td align="left">Staus:
                               
                                <asp:DropDownList ID="cmbStatus" runat="server" CssClass="textbox" />
                                &nbsp;&nbsp;Priority:&nbsp;<asp:DropDownList ID="ddlTaskPriority" runat="server" CssClass="textbox" />
                            </td>
                            <td>
                                <div class="block-link-container">
                                    <asp:Literal ID="ltrlFreezedSpecificationByUserLinkMain" runat="server" />
                                </div>

                                <asp:TextBox ID="txtAdminPasswordToFreezeSpecificationMain" runat="server" TextMode="Password" CssClass="textbox fz fz-admin" Width="110"
                                    placeholder="Admin Password" AutoPostBack="true" Visible="false" OnTextChanged="txtPasswordToFreezeSpecification_TextChanged" />

                                <asp:TextBox ID="txtITLeadPasswordToFreezeSpecificationMain" runat="server" TextMode="Password" CssClass="textbox fz fz-techlead" Width="110"
                                    placeholder="IT Lead Password" AutoPostBack="true" Visible="false" OnTextChanged="txtPasswordToFreezeSpecification_TextChanged" />
                                <asp:TextBox ID="txtUserPasswordToFreezeSpecificationMain" runat="server" TextMode="Password" CssClass="textbox fz fz-user" Width="110"
                                    placeholder="User Password" AutoPostBack="true" Visible="false" OnTextChanged="txtPasswordToFreezeSpecification_TextChanged" />
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <td colspan="2">Task Description <span style="color: red;">*</span>:                                
                               
                                <br />
                                <asp:TextBox ID="txtDescription" TextMode="MultiLine" runat="server" CssClass="textbox" Width="98%" Rows="10"></asp:TextBox>
                                <%--<ajax:Editor ID="txtDescription" Width="100%" Height="100px" runat="server" ActiveMode="Design" AutoFocus="true" />--%>
                                
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <uc1:ucTaskHistory ID="objucTaskHistory_Admin" runat="server" />
                            </td>
                        </tr>
                        <tr id="trSubTaskList" runat="server">
                            <td colspan="2">
                                <uc1:ucSubTasks ID="objucSubTasks_Admin" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div class="btn_sec">
                                    <asp:Button ID="btnSaveTask" runat="server" Text="Save Task" CssClass="ui-button" ValidationGroup="Submit" OnClick="btnSaveTask_Click" />
                                </div>
                            </td>
                        </tr>
                    </table>
                    <!-- table for userview -->
                    <table id="tblUserTaskView" class="tablealign" style="width: 100%;" cellspacing="5" runat="server">
                        <tr>
                            <td><b>Designation:</b>
                                <asp:Literal ID="ltlTUDesig" runat="server"></asp:Literal>
                                <div id="divAcceptRejectButtons" runat="server" visible="false">
                                    <asp:LinkButton ID="lbtnAcceptTask" runat="server" Text="Accept" OnClick="lbtnAcceptTask_Click" />&nbsp;
                                    <asp:LinkButton ID="lbtnRejectTask" runat="server" Text="Reject" OnClick="lbtnRejectTask_Click" />
                                </div>
                            </td>
                            <td><b>Status:</b>
                                <asp:DropDownList ID="ddlTUStatus" AutoPostBack="true" runat="server" CssClass="textbox">
                                </asp:DropDownList>
                                &nbsp;&nbsp;
                               
                                <b>Priority:</b>
                                <asp:Literal ID="ltrlTaskPriority" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td class="valigntop"><b>Task Title:</b>
                                <asp:Literal ID="ltlTUTitle" runat="server"></asp:Literal>
                            </td>
                            <td class="valigntop">
                                <asp:LinkButton ID="lbtnShowWorkSpecificationSection1" runat="server" Text="Work Specification Files"
                                    OnClick="lbtnShowWorkSpecificationSection_Click" />&nbsp;

                                <asp:LinkButton ID="lbtnShowFinishedWorkFiles1" runat="server" Text="Finished Work Files"
                                    OnClick="lbtnShowFinishedWorkFiles_Click" />
                                <br />
                                <div>
                                    <div id="divWorkFileUser" class="dropzone work-file" data-hidden="<%=hdnWorkFiles.ClientID%>">
                                        <div class="fallback">
                                            <input name="WorkFile" type="file" multiple />
                                            <input type="submit" value="UploadWorkFile" />
                                        </div>
                                    </div>
                                    <div id="divWorkFileUserPreview" class="dropzone-previews work-file-previews">
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr style="display:none;">
                            <td colspan="2"><b>Task Description:</b>
                                <asp:TextBox ID="txtTUDesc" TextMode="MultiLine" ReadOnly="true" Style="width: 100%;" Rows="10" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <uc1:ucTaskHistory ID="objucTaskHistory_User" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <uc1:ucSubTasks ID="objucSubTasks_User" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <%--This is a client side hidden section and It is used to trigger server event from java script code.--%>
                <div class="hide">
                    <input id="hdnWorkFiles" runat="server" type="hidden" />
                    <asp:Button ID="btnAddAttachment" runat="server" OnClick="btnAddAttachment_ClicK" Text="Save"
                        CssClass="ui-button" />
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    <div id="divFixedSection" runat="server" style="position: fixed; right: 0px; bottom: 0px; margin: 0px 10px 10px 0px; padding: 3px; background-color: black; color: white;">
    </div>

    <%--Popup Starts--%>
    <div class="hide">

        <div id="divAcceptanceLog" runat="server" title="Acceptance Log">
            <asp:UpdatePanel ID="upAcceptanceLog" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:GridView ID="gvAcceptanceLog" runat="server" ShowHeaderWhenEmpty="true" EmptyDataRowStyle-HorizontalAlign="Center"
                        HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                        EmptyDataText="No acceptance log available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0"
                        AutoGenerateColumns="False" GridLines="Vertical" DataKeyNames="Id,UserId">
                        <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                        <HeaderStyle CssClass="trHeader " />
                        <RowStyle CssClass="FirstRow" />
                        <AlternatingRowStyle CssClass="AlternateRow " />
                        <Columns>
                            <asp:TemplateField HeaderText="User" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <%# string.Concat(Eval("UserFirstName").ToString()," - ") %>
                                    <asp:HyperLink runat="server" ForeColor="Blue"
                                        NavigateUrl='<%# Eval("UserId", "CreateSalesUser.aspx?id={0}") %>'
                                        Text='<%# Eval("UserId")%>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <%# Convert.ToBoolean(Eval("IsAccepted"))? "Accepted" : "Rejected" %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Date" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <%#Eval("DateCreated")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <%--Work Specification Popup--%>
        <div id="divWorkSpecificationSection" runat="server" title="Work Specification Files" data-min-button="Work Specification Files">
            <asp:UpdatePanel ID="upWorkSpecificationSection" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:UpdatePanel ID="upWorkSpecifications" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div>
                                <asp:UpdatePanel ID="upWorkSpecificationAttachments" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table>
                                            <thead>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <td style="vertical-align: top;">
                                                        <div id="divWorkFileAdmin" class="dropzone work-file" data-hidden="<%=hdnWorkFiles.ClientID%>">
                                                            <div class="fallback">
                                                                <input name="WorkFile" type="file" multiple />
                                                                <input type="submit" value="UploadWorkFile" />
                                                            </div>
                                                        </div>
                                                        <div id="divWorkFileAdminPreview" class="dropzone-previews work-file-previews">
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div style="text-align: right; vertical-align: top;">
                                                            <asp:Literal ID="ltrlFreezedSpecificationByUserLinkPopup" runat="server" />
                                                            <asp:TextBox ID="txtAdminPasswordToFreezeSpecificationPopup" runat="server" TextMode="Password" CssClass="textbox fz fz-admin" Width="110"
                                                                placeholder="Admin Password" AutoPostBack="true" Visible="false" OnTextChanged="txtPasswordToFreezeSpecification_TextChanged" />


                                                            <asp:TextBox ID="txtITLeadPasswordToFreezeSpecificationPopup" runat="server" TextMode="Password" CssClass="textbox fz fz-techlead" Width="110"
                                                                placeholder="IT Lead Password" AutoPostBack="true" Visible="false" OnTextChanged="txtPasswordToFreezeSpecification_TextChanged" />

                                                            <asp:TextBox ID="txtUserPasswordToFreezeSpecificationPopup" runat="server" TextMode="Password" CssClass="textbox fz fz-user" Width="110"
                                                                placeholder="User Password" AutoPostBack="true" Visible="false" OnTextChanged="txtPasswordToFreezeSpecification_TextChanged" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">
                                                        <div style="max-height: 300px; min-height: 200px; overflow-y: auto; overflow-x: hidden;">
                                                            <asp:UpdatePanel ID="upnlAttachments" runat="server" UpdateMode="Conditional">
                                                                <ContentTemplate>
                                                                    <asp:Repeater ID="grdWorkSpecificationAttachments" runat="server"
                                                                        OnItemDataBound="grdWorkSpecificationAttachments_ItemDataBound"
                                                                        OnItemCommand="grdWorkSpecificationAttachments_ItemCommand">
                                                                        <HeaderTemplate>
                                                                            <ul style="width: 100%; list-style-type: none; margin: 0px; padding: 0px;">
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <li style="margin: 10px; text-align: center; float: left; width: 100px;">
                                                                                <asp:LinkButton ID="lbtnDelete" runat="server" ClientIDMode="AutoID" ForeColor="Blue" Text="Delete" CommandArgument='<%#Eval("Id").ToString()+ "|" + Eval("attachment").ToString() %>' CommandName="delete-attachment" />
                                                                                <br />
                                                                                <img id="imgIcon" runat="server" height="100" width="100" src="javascript:void(0);" />
                                                                                <br />
                                                                                <small>
                                                                                    <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue" CommandName="download-attachment" />
                                                                                    <br />
                                                                                    <small><%# Convert.ToDateTime(Eval("UpdatedOn")).ToString("MM/dd/yyyy hh:mm tt") %></small>
                                                                                </small>
                                                                            </li>
                                                                        </ItemTemplate>
                                                                        <FooterTemplate>
                                                                            </ul>
                                                                       
                                                                        </FooterTemplate>
                                                                    </asp:Repeater>
                                                                </ContentTemplate>
                                                            </asp:UpdatePanel>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <uc1:ucTaskWorkSpecifications ID="objucTaskWorkSpecifications" runat="server" />
                            <br />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ContentTemplate>
            </asp:UpdatePanel>
            <%--Below div is required to make entire section visible.--%>
            <div style="float: none; clear: both;"></div>
        </div>

        <%--Finished Work Files Popup--%>
        <div id="divFinishedWorkFiles" runat="server" title="Finished Work Files" data-min-button="Finished Work Files">
            <%--Only Allow "*.doc" files to be uploaded
                            Add Log with file name "username_datetimeofsubmitionofwork.doc."
                            When user submit their CODE files, it should be auto compiled and if there is any compilation error it should show popup to user 
                            with build error and that errors should be logged with attempt count as well. when user resubmit work it should follow same process 
                            as above and there should be max. attempt count.
            --%>
            <fieldset>
                <legend>Log Finished Work</legend>
                <hr />
                <table width="100%" border="0" cellspacing="3" cellpadding="3">
                    <tr>
                        <td width="120" align="right">Est. Hrs. of Task:
                        </td>
                        <td width="250">
                            <asp:TextBox ID="txtEstHrsOfTaskFWF" runat="server" CssClass="textbox" Width="60" />
                        </td>
                        <td width="180" align="right">Actual Hrs. of Task:
                        </td>
                        <td style="min-width: 200px;">
                            <asp:TextBox ID="txtActualHrsOfTaskFWF" runat="server" CssClass="textbox" Width="60" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <table width="100%">
                                <tr>
                                    <td align="left">User Acceptance:
                                           
                                        <asp:DropDownList ID="ddlUserAcceptance" runat="server" CssClass="textbox">
                                            <asp:ListItem Text="Accept" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="Reject" Value="0"></asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td align="left">Due Date:
                                               
                                        <asp:TextBox ID="txtDueDate" runat="server" CssClass="textbox datepicker" Width="120" />
                                        <asp:Literal ID="ltlTUDueDate" runat="server" />
                                    </td>
                                    <td align="right">Hrs of Task:
                                               
                                        <asp:Literal ID="ltlTUHrsTask" runat="server" />
                                        <asp:TextBox ID="txtHours" runat="server" CssClass="textbox" Width="100" />
                                        <asp:RegularExpressionValidator ID="revHours" runat="server" ControlToValidate="txtHours" Display="None"
                                            ErrorMessage="Please enter decimal numbers for hours of task." ValidationGroup="SaveWorkSpecification" ValidationExpression="(\d+\.\d{1,2})?\d*" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td align="right">Freeze By:
                        </td>
                        <td>Yogesh Keraliya
                        </td>
                        <td align="right">Profile:
                        </td>
                        <td>
                            <a href="InstallCreateUser.aspx?Id=901">901</a>
                        </td>
                    </tr>
                    <tr>
                        <td align="right">Sub task:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlSubTasksFWF" runat="server" CssClass="textbox" Width="100">
                                <asp:ListItem>Select</asp:ListItem>
                                <asp:ListItem>I-a</asp:ListItem>
                                <asp:ListItem>I-b</asp:ListItem>
                                <asp:ListItem>II-b</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                        <td align="right">Sub task status:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlSubTaskStatusFWF" runat="server" CssClass="textbox" Width="100">
                                <asp:ListItem>Select</asp:ListItem>
                                <asp:ListItem>Open</asp:ListItem>
                                <asp:ListItem>In Progress</asp:ListItem>
                                <asp:ListItem>Closed</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" valign="top">File:<br />
                            <div class="dropzone">
                                <div class="dz-default dz-message"></div>
                            </div>
                        </td>
                        <td align="right" valign="top">Date of File Submission:
                        </td>
                        <td valign="top">
                            <asp:TextBox ID="DateOfFileSubmissionFWF" runat="server" CssClass="textbox" Width="80" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">Code files change log: (only doc files)<br />
                            <div class="dropzone">
                                <div class="dz-default dz-message"></div>
                            </div>
                        </td>
                        <td colspan="2">Database change script file: (only sql files)<br />
                            <div class="dropzone">
                                <div class="dz-default dz-message"></div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" valign="top">Code files: (only aspx, ascx or cs files)<br />
                            <div class="dropzone">
                                <div class="dz-default dz-message"></div>
                            </div>
                        </td>
                        <td colspan="2" valign="top">Comment on sub task:
                                       
                                       

                            <br />
                            <asp:TextBox ID="txtSubTaskCommentFWF" runat="server" CssClass="textbox" TextMode="MultiLine" Style="width: 90%;" Rows="4" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">Test page url :<br />
                            <asp:TextBox ID="txtTestPageUrl" runat="server" CssClass="textbox" Style="width: 90%" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <div class="btn_sec">
                                <asp:Button ID="btnSaveFWF" runat="server" CssClass="ui-button" Text="Save" OnClientClick="javascript:return false;" />
                            </div>
                        </td>
                    </tr>
                </table>
            </fieldset>
        </div>
    </div>
    <%--Popup Ends--%>

    <script type="text/javascript">

        var workspecEditor;

        Dropzone.autoDiscover = false;

        $(function () {
            Initialize();
            ApplyToolTip();
        });

        var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

        prmTaskGenerator.add_endRequest(function () {
            Initialize();
        });

        function Initialize() {
            ApplyDropZone();
        }

        function ShowPopup(varControlID) {

            var windowWidth = (parseInt($(window).width()) / 2) - 10;

            var dialogwidth = windowWidth + "px";

            var objDialog = $(varControlID).dialog({ width: dialogwidth, height: "auto" });

            AppendMinimizeButton(objDialog);

            // this will enable postback from dialog buttons.
            objDialog.parent().appendTo(jQuery("form:first"));
            if (varControlID == '#<%=divFinishedWorkFiles.ClientID%>') {

                $(varControlID).dialog("option", "position", {
                    my: 'left top',
                    at: 'right+5 top',
                    of: $('#<%=divWorkSpecificationSection.ClientID%>')
                });

                $(varControlID).on("dialogclose", function (event, ui) { location.reload(); });
            }
            else if (varControlID == '#<%=divWorkSpecificationSection.ClientID%>') {
                $(varControlID).dialog("option", "position", {
                    my: 'left top',
                    at: 'left top',
                    of: window
                });
            }
        }

        function AppendMinimizeButton(objDialog) {

            var varTarget = $('#' + objDialog.attr('id'));

            if (typeof (varTarget.attr('data-min-button')) != 'undefined') {

                if (objDialog.parent().find('.ui-dialog-titlebar-minimize').length == 0) {
                    var varMinimizeButton = $('<button type="button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-dialog-titlebar-minimize" role="button" title="Minimize"><span class="ui-button-icon-primary ui-icon ui-icon-minusthick"></span><span class="ui-button-text">Minimize</span></button>');

                    varMinimizeButton.click(function () {
                        var divFixedSection = $('#<%=divFixedSection.ClientID%>');

                        if (divFixedSection.find('a[data-id="' + varTarget.attr('id') + '"]').length == 0) {
                            var varLink = $('<a data-id="' + varTarget.attr('id') + '" href="javascript:void(0);" style="margin:0px 6px 0px 0px;color:white;font-weight:bold" onclick="javascript:ShowPopup(\'#' + varTarget.attr('id') + '\');$(this).remove();">' + varTarget.attr('data-min-button') + '</a>');
                            varLink.appendTo(divFixedSection);
                        }
                        HidePopup('#' + varTarget.attr('id'));
                    });

                    varMinimizeButton.insertBefore(objDialog.parent().find('.ui-dialog-titlebar-close'));
                }
            }
        }

        function ApplyToolTip() {
            $(document).tooltip({
                items: "[data-tooltip]",
                content: function () {
                    var element = $(this);

                    if (element.is("[data-tooltipcontent]")) {
                        return element.attr("data-tooltipcontent");
                    }
                    //if ( element.is( "[title]" ) ) {
                    //    return element.attr( "title" );
                    //}
                    //if ( element.is( "img" ) ) {
                    //    return element.attr( "alt" );
                    //}
                }
            });
        }

        // check if user has selected any designations or not.
        function checkDesignations(oSrc, args) {
            args.IsValid = ($("#<%= ddlUserDesignation.ClientID%> input:checked").length > 0);
        }

        var objWorkFileDropzone;

        function ApplyDropZone() {
            //debugger;
            ////User's drag and drop file attachment related code

            //remove already attached dropzone.
            if (objWorkFileDropzone) {
                objWorkFileDropzone.destroy();
                objWorkFileDropzone = null;
            }
            objWorkFileDropzone = GetWorkFileDropzone("div.work-file", 'div.work-file-previews', '#<%= hdnWorkFiles.ClientID %>', '#<%=btnAddAttachment.ClientID%>');
        }

    </script>
</asp:Content>
