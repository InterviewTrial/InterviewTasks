<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="TaskGenerator.aspx.cs"
    Inherits="JG_Prospect.Sr_App.TaskGenerator" ValidateRequest="false" EnableEventValidation="false" %>

<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit.HTMLEditor" TagPrefix="ajax" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="../css/jquery-ui.css" />
    <link href="../css/dropzone/css/basic.css" rel="stylesheet" />
    <link href="../css/dropzone/css/dropzone.css" rel="stylesheet" />
    <script type="text/javascript" src="../js/dropzone.js"></script>
    <script>
        //$(document).ready(function(){ 
        //    debugger;
        //    LogNoteSave();
        //});
    </script>

    <%--Popup open for viewing Log Images, Video and Audio--%>
    <style type="text/css">
        #mask {
            position: fixed;
            left: 0px;
            top: 0px;
            z-index: 4;
            opacity: 0.4;
            -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=40)"; /* first!*/
            filter: alpha(opacity=40); /* second!*/
            background-color: gray;
            display: none;
            width: 100%;
            height: 100%;
        }


        .modal {
            display: none;
            position: absolute;
            top: 0px;
            left: 0px;
            background-color: black;
            z-index: 100;
            opacity: 0.8;
            filter: alpha(opacity=60);
            -moz-opacity: 0.8;
            min-height: 100%;
        }

        #divImage {
            display: none;
            z-index: 1000;
            position: fixed;
            top: 0;
            left: 0;
            background-color: White;
            height: 550px;
            width: 600px;
            padding: 3px;
            border: solid 1px black;
        }

        .modalBackground {
            background-color: Black;
            filter: alpha(opacity=90);
            opacity: 0.8;
        }

        .modalPopup {
            background-color: #FFFFFF;
            border-width: 3px;
            border-style: solid;
            border-color: black;
            padding-top: 10px;
            padding-left: 10px;
            width: 300px;
            height: 140px;
        }
    </style>

    <script type="text/javascript" language="javascript">
        function ShowPopupLogFile() {
            debugger;
            $('#mask').show();
            $('#<%=pnlpopup.ClientID %>').show();
        }
        function HidePopupLogFile() {
            debugger;
            $('#mask').hide();
            $('#<%=pnlpopup.ClientID %>').hide();
        }
        //$(".btnClose").live('click',function () {
        //    debugger;
        //    HidePopupLogFile();
        //});
    </script>
    <%--    End--%>
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
                                        <asp:DropDownCheckBoxes ID="ddcbAssigned" runat="server" UseSelectAllNode="false"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddcbAssigned_SelectedIndexChanged">
                                            <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                            <Texts SelectBoxCaption="--Open--" />
                                        </asp:DropDownCheckBoxes>
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
                            <td class="valigntop">
                                <table>
                                    <tr>
                                        <td style="width: 30%;" class="valigntop">
                                            <asp:LinkButton ID="lbtnWorkSpecificationFiles" runat="server" Text="Work Specification Files"
                                                OnClick="lbtnWorkSpecificationFiles_Click" />
                                        </td>
                                        <td class="valigntop">
                                            <asp:LinkButton ID="lbtnFinishedWorkFiles" runat="server" Text="Finished Work Files"
                                                OnClick="lbtnFinishedWorkFiles_Click" />&nbsp;&nbsp;
                                    <br />
                                            <div id="divWorkFileAdmin" class="dropzone work-file">
                                                <div class="fallback">
                                                    <input name="WorkFile" type="file" multiple />
                                                    <input type="submit" value="UploadWorkFile" />
                                                </div>
                                            </div>
                                            <div id="divWorkFileAdminPreview" class="dropzone-previews work-file-previews">
                                            </div>

                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <%-- <td colspan="2">Notes <span style="color: red;">*</span>:<br />--%>
                            <%--  <asp:TextBox ID="txtDescription" TextMode="MultiLine" runat="server" CssClass="textbox" Width="98%" Rows="10"></asp:TextBox>--%>
                            <%--<ajax:Editor ID="txtDescription" Width="100%" Height="100px" runat="server" ActiveMode="Design" AutoFocus="true" />--%>
                            <%--<asp:RequiredFieldValidator ID="rfvDesc" ValidationGroup="Submit"
                                    runat="server" ControlToValidate="txtDescription" ForeColor="Red" ErrorMessage="Please Enter Task Description" Display="None">                                 
                                </asp:RequiredFieldValidator>--%>
                            <%--  </td>--%>
                        </tr>
                        <%-- Add Notes or Comments inside the log section :: 07-10-2016 --%>
                        <tr>
                            <td colspan="2">
                                <fieldset class="tasklistfieldset">
                                    <legend>Log</legend>

                                    <div style="margin-top: 5px">
                                        Task Description <span style="color: red;">*</span>:<br />
                                        <asp:TextBox ID="txtDescription" TextMode="MultiLine" runat="server" CssClass="textbox" Width="98%" Rows="10"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="rfvDesc" ValidationGroup="Submit"
                                            runat="server" ControlToValidate="txtDescription" ForeColor="Red" ErrorMessage="Please Enter Task Description" Display="None">                                 
                                        </asp:RequiredFieldValidator>
                                    </div>

                                    <div>
                                        <asp:UpdatePanel ID="upTaskHistory" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:TabContainer ID="tcTaskHistory" runat="server" ActiveTabIndex="0" AutoPostBack="false">
                                                    <asp:TabPanel ID="tpTaskHistory_All" runat="server" TabIndex="0">
                                                        <HeaderTemplate>All</HeaderTemplate>
                                                        <ContentTemplate>
                                                            <div>
                                                                <div class="grid">
                                                                    <asp:GridView ID="gdTaskUsers" runat="server"
                                                                        EmptyDataText="No task history available!"
                                                                        ShowHeaderWhenEmpty="true"
                                                                        AutoGenerateColumns="false"
                                                                        Width="100%"
                                                                        HeaderStyle-BackColor="Black"
                                                                        HeaderStyle-ForeColor="White"
                                                                        AllowSorting="false"
                                                                        BackColor="White"
                                                                        PageSize="3"
                                                                        GridLines="Horizontal"
                                                                        OnRowDataBound="gdTaskUsers_RowDataBound"
                                                                        OnRowCommand="gdTaskUsers_RowCommand">
                                                                        <%--<EmptyDataTemplate>
                                                                    </EmptyDataTemplate>--%>

                                                                        <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                                                        <HeaderStyle CssClass="trHeader " />
                                                                        <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                                                                        <AlternatingRowStyle CssClass="AlternateRow " />
                                                                        <Columns>
                                                                            <asp:TemplateField ShowHeader="True" Visible="false" HeaderText="Note Id" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblNoteId" runat="server" Text='<%#Eval("ID")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="User" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="18%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                   <%-- <asp:Label ID="lbluser" runat="server"
                                                                                        Text='<%#String.IsNullOrEmpty(Eval("FristName").ToString())== true ? Eval("UserFirstName").ToString() : Eval("FristName").ToString() %>'>
                                                                                    </asp:Label>--%>
                                                                                    <asp:HyperLink runat="server" NavigateUrl='<%# Eval("UserId", "CreateSalesUser.aspx?id={0}") %>' 
                                                                                        Text='<%# string.Concat(String.IsNullOrEmpty(Eval("FristName").ToString())== true ? Eval("UserFirstName").ToString() : Eval("FristName").ToString() , " -", Eval("UserId")) %>' />
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField ShowHeader="True" HeaderText="Date & Time" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblupdateDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField HeaderText="Notes" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <div>
                                                                                        <asp:Label ID="lblNotes" runat="server" Text='<%#Eval("Notes")%>'></asp:Label>
                                                                                    </div>
                                                                                    <div>
                                                                                        <asp:Image ID="imgFile" Height="60px" Width="60px" runat="server" />
                                                                                    </div>
                                                                                    <div>
                                                                                        <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                                        <asp:Label ID="lableOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>'></asp:Label>
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                                ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="10%">
                                                                                <ItemTemplate>
                                                                                    <asp:LinkButton ID="btnUpdateLogNotes" runat="server" Text="Edit Note" OnClick="btnUpdateLogNotes_Click" />
                                                                                    <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="Status" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="Status" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>
                                                                            <%--<asp:TemplateField ShowHeader="False" HeaderText="Files" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblFiles" runat="server" Text='<%# Eval("AttachmentCount")%>'></asp:Label>
                                                                                    <br>
                                                                                    <asp:LinkButton ID="lbtnAttachment" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>--%>
                                                                        </Columns>
                                                                        <HeaderStyle BackColor="Black" ForeColor="White"></HeaderStyle>
                                                                    </asp:GridView>
                                                                    <%-- OnRowDataBound="GridView1_RowDataBound"    OnPageIndexChanging="GridView1_PageIndexChanging" OnRowCommand="GridView1_RowCommand"--%>
                                                                </div>
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>

                                                    <asp:TabPanel ID="tpTaskHistory_Notes" runat="server" TabIndex="0">
                                                        <HeaderTemplate>Notes</HeaderTemplate>

                                                        <ContentTemplate>
                                                            <div>
                                                                <div class="grid">
                                                                    <asp:GridView ID="gdTaskUsersNotes" runat="server"
                                                                        EmptyDataText="No task not history available!"
                                                                        ShowHeaderWhenEmpty="true"
                                                                        AutoGenerateColumns="false"
                                                                        Width="100%"
                                                                        HeaderStyle-BackColor="Black"
                                                                        HeaderStyle-ForeColor="White"
                                                                        AllowSorting="false"
                                                                        BackColor="White"
                                                                        PageSize="3"
                                                                        GridLines="Horizontal"
                                                                        OnRowDataBound="gdTaskUsersNotes_RowDataBound">

                                                                        <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                                                        <HeaderStyle CssClass="trHeader " />
                                                                        <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                                                                        <AlternatingRowStyle CssClass="AlternateRow " />

                                                                        <Columns>
                                                                            <asp:TemplateField ShowHeader="True" Visible="false" HeaderText="Note Id" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblNoteId" runat="server" Text='<%#Eval("ID")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="User" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="18%"
                                                                                ItemStyle-HorizontalAlign="Left" Visible="false">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lbluser" runat="server"
                                                                                        Text='<%#String.IsNullOrEmpty(Eval("FristName").ToString())== true ? Eval("UserFirstName").ToString() : Eval("FristName").ToString() %>'>
                                                                                    </asp:Label>
                                                                                    <asp:HyperLink runat="server" NavigateUrl='<%# Eval("UserId", "Customer_Profile.aspx?CustomerId={0}") %>' Text='<%# Eval("UserId") %>' />
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="Date & Time" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblupdateDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField HeaderText="Notes" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <div>
                                                                                        <asp:Label ID="lblNotes" runat="server" Text='<%#Eval("Notes")%>'></asp:Label>
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>



                                                                            <asp:TemplateField ShowHeader="True" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                                ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="10%">
                                                                                <ItemTemplate>
                                                                                    <asp:LinkButton ID="btnUpdateLogNotes" runat="server" Text="Edit Note" OnClick="btnUpdateLogNotes_Click" />
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                        <HeaderStyle BackColor="Black" ForeColor="White"></HeaderStyle>
                                                                    </asp:GridView>
                                                                </div>
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>

                                                    <asp:TabPanel ID="tpTaskHistory_FilesAndDocs" runat="server" TabIndex="0" CssClass="task-history-tab">
                                                        <HeaderTemplate>Files & docs</HeaderTemplate>
                                                        <ContentTemplate>
                                                            <div>
                                                                <asp:Repeater ID="reapeaterLogDoc" runat="server">
                                                                    <ItemTemplate>
                                                                        <div style="width: 200px; height: 200px; float: left;">


                                                                            <div style="text-align: center;">
                                                                                <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:Image ID="imgDoc" runat="server" ImageUrl='<%#Eval("FilePath")%>'
                                                                                    Width="120px" Height="120px" />
                                                                                <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                                            </div>

                                                                            <div style="display: none">
                                                                                <asp:Label ID="lableFileExtension" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                                                            </div>
                                                                        </div>

                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>
                                                    <asp:TabPanel ID="tpTaskHistory_Images" runat="server" TabIndex="0" CssClass="task-history-tab">
                                                        <HeaderTemplate>Images</HeaderTemplate>
                                                        <ContentTemplate>
                                                            <div>
                                                                <asp:Repeater ID="reapeaterLogImages" runat="server">
                                                                    <ItemTemplate>
                                                                        <div style="width: 200px; height: 200px; float: left;">


                                                                            <div style="text-align: center;">
                                                                                <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:ImageButton ID="imgImages" runat="server" ImageUrl='<%#Eval("FilePath")%>'
                                                                                    Width="120px" Height="120px" Style="cursor: pointer" OnClientClick="return LoadDiv(this.src);" />
                                                                                <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                                            </div>

                                                                            <div style="display: none">
                                                                                <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                                                            </div>
                                                                        </div>

                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>
                                                    <asp:TabPanel ID="tpTaskHistory_Links" runat="server" TabIndex="0" CssClass="task-history-tab" Visible="false">
                                                        <HeaderTemplate>Links</HeaderTemplate>
                                                        <ContentTemplate>
                                                            HTML Goes here 4
                                   
                                                        </ContentTemplate>
                                                    </asp:TabPanel>
                                                    <asp:TabPanel ID="tpTaskHistory_Videos" runat="server" TabIndex="0" CssClass="task-history-tab">
                                                        <HeaderTemplate>Videos</HeaderTemplate>
                                                        <ContentTemplate>





                                                            <div>






                                                                <asp:Repeater ID="reapeaterLogVideoc" runat="server" OnItemCommand="reapeaterLogImages_ItemCommand">
                                                                    <ItemTemplate>
                                                                        <div style="width: 200px; height: 200px; float: left;">
                                                                            <div style="text-align: center;">
                                                                                <asp:LinkButton runat="server" Text='<%#Eval("AttachmentOriginal")%>' ID="linkOriginalfileName" CommandName="viewFile"
                                                                                    OnClientClick='<%# string.Format("return ViewDetails({0}, \"{1}\", \"{2}\", \"{3}\");", Eval("Id"), Eval("Attachment"), Eval("AttachmentOriginal"), Eval("FileType")) %>'
                                                                                    CommandArgument='<%# Eval("Attachment")%>'>
                                                                                </asp:LinkButton>
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:Image ID="imgImages" runat="server" ImageUrl='<%#Eval("FilePath")%>'
                                                                                    Width="120px" Height="120px" />
                                                                                <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                            </div>
                                                                            <div style="text-align: center;">
                                                                                <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                                            </div>

                                                                            <div style="display: none">
                                                                                <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                                                            </div>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>

                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>
                                                    <asp:TabPanel ID="tpTaskHistory_Audios" runat="server" TabIndex="0" CssClass="task-history-tab">
                                                        <HeaderTemplate>Audios</HeaderTemplate>
                                                        <ContentTemplate>
                                                            <div>
                                                                <asp:UpdatePanel ID="upLogAudio" runat="server" UpdateMode="Conditional">
                                                                    <ContentTemplate>
                                                                        <div>
                                                                            <asp:Repeater ID="reapeaterLogAudio" runat="server" OnItemCommand="reapeaterLogImages_ItemCommand">
                                                                                <ItemTemplate>
                                                                                    <div style="width: 200px; height: 200px; float: left;">
                                                                                        <div style="text-align: center;">
                                                                                           <%-- <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' 
                                                                                                CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>--%>

                                                                                            <asp:LinkButton runat="server" Text='<%#Eval("AttachmentOriginal")%>' ID="linkOriginalfileName" CommandName="viewFile"
                                                                                                OnClientClick='<%# string.Format("return ViewDetails({0}, \"{1}\", \"{2}\", \"{3}\");", Eval("Id"), Eval("Attachment"), Eval("AttachmentOriginal"), Eval("FileType")) %>'
                                                                                                CommandArgument='<%# Eval("Attachment")%>'>
                                                                                            </asp:LinkButton>

                                                                                        </div>
                                                                                        <div style="text-align: center;">
                                                                                            <asp:Image ID="imgImages" runat="server" ImageUrl='<%#Eval("FilePath")%>'
                                                                                                Width="120px" Height="120px" />
                                                                                            <asp:Label ID="lblMessage" ForeColor="Red" runat="server" Visible="false" />
                                                                                        </div>
                                                                                        <div style="text-align: center;">
                                                                                            <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                                        </div>
                                                                                        <div style="text-align: center;">
                                                                                            <asp:Label ID="lblDate" runat="server" Text='<%#Eval("UpdatedOn")%>'></asp:Label>
                                                                                        </div>

                                                                                        <div style="display: none">
                                                                                            <asp:Label ID="lableFileType" runat="server" Text='<%#Eval("FileType")%>' Visible="false"></asp:Label>
                                                                                        </div>
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                            </asp:Repeater>
                                                                        </div>
                                                                    </ContentTemplate>
                                                                </asp:UpdatePanel>
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>
                                                </asp:TabContainer>

                                                <div style="margin-top: 5px" id="divTableNote" runat="server">
                                                    <div>
                                                        <div>
                                                            <div>
                                                                <table style="width: 100%">
                                                                    <tr>
                                                                        <td style="width: 50px">
                                                                            <asp:Label runat="server"> Notes:</asp:Label>
                                                                        </td>
                                                                        <td style="width: 95%">
                                                                            <input type="hidden" id="hdnNoteId" runat="server" />
                                                                            <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Width="90%" CssClass="textbox"></asp:TextBox>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div>
                                                        <table style="width: 100%">
                                                            <tr>
                                                                <td style="width: 50%">
                                                                    <div class="btn_sec" style="text-align: right;">
                                                                        <asp:Button ID="btnAddNote" runat="server" Text="Save Note" CssClass="ui-button" OnClick="btnAddNote_Click" ValidationGroup="Submit" />
                                                                        <asp:Button ID="btnCancelUpdateNote" runat="server" Text="Cancel Update" CssClass="ui-button" OnClick="btnCancelUpdateNote_Click" ValidationGroup="Submit" Visible="false" />
                                                                    </div>
                                                                </td>
                                                                <td style="width: 50%">
                                                                    <table style="width: 100%">
                                                                        <tr>
                                                                            <td style="width: 10%">
                                                                                <asp:ImageButton ImageUrl="~/img/paperclip.png" Height="30px" Width="30px" runat="server" ID="imgBtnLogFiles" OnClientClick="papterclipClick(); return false"/>
                                                                            </td>

                                                                            <td style="width: 50%; display:none;" id="tduploadcontrol">
                                                                                <div runat="server">
                                                                                    <table style="width: 100%">
                                                                                        <tr>
                                                                                            <td style="text-align: right">
                                                                                                <input id="hdnNoteAttachments" runat="server" type="hidden" />
                                                                                                <input id="hdnNoteFileType" runat="server" type="hidden" />
                                                                                                <div id="divNoteDropzone" runat="server" class="dropzone work-file-Note">
                                                                                                    <div class="fallback">
                                                                                                        <input name="file" type="file" multiple />
                                                                                                        <input type="submit" value="Upload" />
                                                                                                    </div>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td style="text-align: left">
                                                                                                <table>
                                                                                                    <tr>

                                                                                                        <td>
                                                                                                            <div id="divNoteDropzonePreview" runat="server" class="dropzone-previews work-file-previews-note">
                                                                                                            </div>
                                                                                                        </td>

                                                                                                        <td style="visibility: hidden">
                                                                                                            <div class="btn_sec" style="text-align: right;">
                                                                                                                <asp:Button ID="btnUploadLogFiles" runat="server" Text="Upload File" CssClass="ui-button" OnClick="btnUploadLogFiles_Click" ValidationGroup="Submit" />
                                                                                                            </div>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </fieldset>
                            </td>
                        </tr>

                        <tr id="trSubTaskList" runat="server">
                            <td colspan="2">
                                <fieldset class="tasklistfieldset">
                                    <legend>Task List</legend>
                                    <asp:UpdatePanel ID="upSubTasks" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <div id="divSubTaskGrid">
                                                <asp:GridView ID="gvSubTasks" runat="server" ShowHeaderWhenEmpty="true" EmptyDataRowStyle-HorizontalAlign="Center"
                                                    HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                                                    EmptyDataText="No sub task available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0"
                                                    AutoGenerateColumns="False" GridLines="Vertical"
                                                    OnRowDataBound="gvSubTasks_RowDataBound"
                                                    OnRowCommand="gvSubTasks_RowCommand">
                                                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                                    <HeaderStyle CssClass="trHeader " />
                                                    <RowStyle CssClass="FirstRow" />
                                                    <AlternatingRowStyle CssClass="AlternateRow " />
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="List ID" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="10%">
                                                            <ItemTemplate>
                                                                <asp:LinkButton ID="lbtnEditSubTask" runat="server" CommandName="edit-sub-task" Text='<%# Eval("InstallId") %>'
                                                                    CommandArgument='<%# Container.DataItemIndex  %>' />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Task Description" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                                            <ItemTemplate>
                                                                <%# Eval("Description")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Type" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%# String.IsNullOrEmpty(Eval("TaskType").ToString()) == true ? String.Empty : ddlTaskType.Items.FindByValue( Eval("TaskType").ToString()).Text %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Status" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlStatus_SelectedIndexChanged" />
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
                                            <div id="divSubTask" runat="server" class="tasklistfieldset" style="display: none;">
                                                <asp:HiddenField ID="hdnSubTaskId" runat="server" Value="0" />
                                                <asp:HiddenField ID="hdnSubTaskIndex" runat="server" Value="-1" />
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
                                                    <tr>
                                                        <td>Attachment(s):<br>
                                                            <input id="hdnAttachments" runat="server" type="hidden" />
                                                            <div id="divSubTaskDropzone" runat="server" class="dropzone">
                                                                <div class="fallback">
                                                                    <input name="file" type="file" multiple />
                                                                    <input type="submit" value="Upload" />
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div id="divSubTaskDropzonePreview" runat="server" class="dropzone-previews">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr id="trDateHours" runat="server" visible="false">
                                                        <td>Due Date:
                           
                                                            <asp:TextBox ID="txtSubTaskDueDate" runat="server" CssClass="textbox datepicker" />
                                                        </td>
                                                        <td>Hrs of Task:
                           
                                                            <asp:TextBox ID="txtSubTaskHours" runat="server" CssClass="textbox" />
                                                            <asp:RegularExpressionValidator ID="revSubTaskHours" runat="server" ControlToValidate="txtSubTaskHours" Display="None"
                                                                ErrorMessage="Please enter decimal numbers for hours of task." ValidationGroup="vgSubTask"
                                                                ValidationExpression="(\d+\.\d{1,2})?\d*" />
                                                        </td>
                                                    </tr>
                                                    <tr id="trSubTaskStatus" runat="server" visible="false">
                                                        <td>Status:
                                                            <asp:DropDownList ID="ddlSubTaskStatus" runat="server" />
                                                        </td>
                                                        <td>&nbsp;
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
                            <td>User Acceptance:
                                <asp:DropDownList ID="ddlUserAcceptance" runat="server" CssClass="textbox">
                                    <asp:ListItem Text="Accept" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Reject" Value="0"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>Due Date:
                                <asp:TextBox ID="txtDueDate" runat="server" CssClass="textbox datepicker" />
                                <%--<asp:CalendarExtender ID="CEDueDate" runat="server" TargetControlID="txtDueDate"></asp:CalendarExtender>--%>
                                <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator3" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtDueDate" ForeColor="Red" ErrorMessage="Please Enter Due Date" Display="None">                                 
                        </asp:RequiredFieldValidator>--%>
                            </td>
                        </tr>
                        <tr>
                            <td>Hrs of Task:
                                <asp:TextBox ID="txtHours" runat="server" CssClass="textbox" />
                                <asp:RegularExpressionValidator ID="revHours" runat="server" ControlToValidate="txtHours" Display="None"
                                    ErrorMessage="Please enter decimal numbers for hours of task." ValidationGroup="Submit" ValidationExpression="(\d+\.\d{1,2})?\d*" />
                                <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator4" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtHours" ForeColor="Red" ErrorMessage="Please Enter Hours Of Task" Display="None">                                 
                        </asp:RequiredFieldValidator>--%>
                            </td>
                            <td>Staus:
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
                            <td class="valigntop"><b>Task Title:</b>
                                <asp:Literal ID="ltlTUTitle" runat="server"></asp:Literal>
                            </td>
                            <td class="valigntop">
                                <br />
                                <asp:LinkButton ID="lbtnFinishedWorkFiles1" runat="server" Text="Finished Work Files"
                                    OnClick="lbtnFinishedWorkFiles_Click" />&nbsp;&nbsp;
                               
                                <asp:LinkButton ID="lbtnWorkSpecificationFiles1" runat="server" Text="Work Specification Files"
                                    OnClick="lbtnWorkSpecificationFiles_Click" />
                                <br />
                                <br />
                                <div>
                                    <div id="divWorkFileUser" class="dropzone work-file">
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
                        <%--<tr>
                            <td colspan="2"><b>Task Description:</b>
                                <asp:TextBox ID="txtTUDesc" TextMode="MultiLine" ReadOnly="true" Style="width: 100%;" Rows="10" runat="server"></asp:TextBox>
                            </td>
                        </tr>--%>

                        <tr>
                            <td colspan="2">
                                <fieldset class="tasklistfieldset">
                                    <legend>Log</legend>

                                    <div style="margin-top: 5px">
                                        Task Description
                                        <br />
                                        <asp:TextBox ID="txtTUDesc" TextMode="MultiLine" runat="server" CssClass="textbox" Width="98%" Rows="10" Enabled="false"></asp:TextBox>
                                    </div>

                                    <div>
                                        <asp:UpdatePanel ID="upTaskHistroryUser" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:TabContainer ID="tcTaskHistoryUser" runat="server" ActiveTabIndex="0" AutoPostBack="false">
                                                    <asp:TabPanel ID="tpTaskHistoryUser_Notes" runat="server" TabIndex="0">
                                                        <HeaderTemplate>Notes</HeaderTemplate>
                                                        <ContentTemplate>
                                                            <div>
                                                                <div class="grid">
                                                                    <asp:GridView ID="gdTaskUsers1" runat="server"
                                                                        EmptyDataText="No task history available!"
                                                                        ShowHeaderWhenEmpty="true"
                                                                        AutoGenerateColumns="false"
                                                                        Width="100%"
                                                                        HeaderStyle-BackColor="Black"
                                                                        HeaderStyle-ForeColor="White"
                                                                        AllowSorting="false"
                                                                        BackColor="White"
                                                                        PageSize="3"
                                                                        GridLines="Horizontal"
                                                                        OnRowDataBound="gdTaskUsers1_RowDataBound"
                                                                        OnRowCommand="gdTaskUsers1_RowCommand">
                                                                        <%--<EmptyDataTemplate>
                                                                </EmptyDataTemplate>--%>
                                                                        <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                                                        <HeaderStyle CssClass="trHeader " />
                                                                        <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                                                                        <AlternatingRowStyle CssClass="AlternateRow " />

                                                                        <Columns>
                                                                            <asp:TemplateField ShowHeader="True" Visible="false" HeaderText="Note Id" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblNoteId" runat="server" Text='<%#Eval("ID")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="User" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="18%"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lbluser" runat="server" Text='<%#String.IsNullOrEmpty(Eval("FristName").ToString())== true ? Eval("UserFirstName").ToString() : Eval("FristName").ToString() %>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField ShowHeader="True" HeaderText="Date & Time" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" HeaderStyle-Width="10%"
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

                                                                            <asp:TemplateField HeaderText="Notes" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <div>
                                                                                        <asp:Label ID="lblNotes" runat="server" Text='<%#Eval("Notes")%>'></asp:Label>
                                                                                    </div>
                                                                                    <div>
                                                                                        <asp:Image ID="imgFile" Height="60px" Width="60px" runat="server" />
                                                                                    </div>
                                                                                    <div>
                                                                                        <asp:LinkButton ID="linkOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>' CommandName="viewFile" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                                        <asp:Label ID="lableOriginalfileName" runat="server" Text='<%#Eval("AttachmentOriginal")%>'></asp:Label>
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small"
                                                                                ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="10%">
                                                                                <ItemTemplate>
                                                                                    <asp:LinkButton ID="linkDownLoadFiles" runat="server" Text="Download" CommandName="DownLoadFiles" CommandArgument='<%# Eval("Attachment")%>'></asp:LinkButton>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="Status" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <asp:TemplateField ShowHeader="True" HeaderText="FileType" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
                                                                                ItemStyle-HorizontalAlign="Left">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lableFileExtension" runat="server" Text='<%#Eval("FileType")%>'></asp:Label>
                                                                                </ItemTemplate>
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <ControlStyle ForeColor="Black" />
                                                                                <HeaderStyle Font-Size="Small"></HeaderStyle>
                                                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                                                            </asp:TemplateField>

                                                                            <%--  <asp:TemplateField ShowHeader="False" HeaderText="Files" ControlStyle-ForeColor="White" HeaderStyle-Font-Size="Small" Visible="false"
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
                                                                    </asp:TemplateField>--%>
                                                                        </Columns>
                                                                        <HeaderStyle BackColor="Black" ForeColor="White"></HeaderStyle>
                                                                    </asp:GridView>
                                                                </div>
                                                            </div>
                                                        </ContentTemplate>
                                                    </asp:TabPanel>
                                                </asp:TabContainer>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>

                                    <div style="display: none">
                                        <br />
                                        <table cellspacing="0" cellpadding="0" width="950px" border="1" style="width: 100%; border-collapse: collapse;" id="tableNote1">

                                            <%-- Add Notes or Comments inside the log section :: 07-10-2016 --%>
                                            <tr style="display: none">
                                                <td>Notes:
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtNote1" runat="server" TextMode="MultiLine" Width="90%" CssClass="textbox"></asp:TextBox>
                                                </td>
                                            </tr>

                                            <tr id="trAddNote1">
                                                <td colspan="2">
                                                    <div class="btn_sec">
                                                        <asp:Button ID="btnAddNote1" runat="server" Text="Save" ValidationGroup="Submit" CssClass="ui-button" OnClick="btnAddNote_Click" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </fieldset>
                            </td>
                        </tr>


                        <tr>
                            <td colspan="2">
                                <fieldset class="tasklistfieldset">
                                    <legend>Task List</legend>
                                    <div>
                                        <asp:GridView ID="gvSubTasks1" runat="server" ShowHeaderWhenEmpty="true" EmptyDataRowStyle-HorizontalAlign="Center"
                                            HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                                            EmptyDataText="No sub task available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0"
                                            AutoGenerateColumns="False" GridLines="Vertical" DataKeyNames="TaskId"
                                            OnRowDataBound="gvSubTasks_RowDataBound"
                                            OnRowCommand="gvSubTasks_RowCommand">
                                            <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                                            <HeaderStyle CssClass="trHeader " />
                                            <RowStyle CssClass="FirstRow" />
                                            <AlternatingRowStyle CssClass="AlternateRow " />
                                            <Columns>
                                                <asp:TemplateField HeaderText="List ID" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="10%">
                                                    <ItemTemplate>
                                                        <%# Eval("InstallId") %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Task Description" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left">
                                                    <ItemTemplate>
                                                        <%# Eval("Description")%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Type" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# String.IsNullOrEmpty(Eval("TaskType").ToString()) == true ? String.Empty : ddlTaskType.Items.FindByValue( Eval("TaskType").ToString()).Text %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Status" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlStatus_SelectedIndexChanged" />
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
                                </fieldset>
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
    <%--Popup Starts--%>
    <div class="hide">
        <div id="divWorkSpecifications" runat="server">
            <asp:UpdatePanel ID="upWorkSpecificationFiles" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <table class="table" style="width: 100%;">
                        <tr>
                            <td>Work Specifications:
                            </td>
                            <td align="right" id="trFreezeWorkSpecification" runat="server">
                                <a href="javascript:void(0);" onclick="javascript:AcceptAllChanges();">Accept</a>&nbsp;
                                                <a href="javascript:void(0);" onclick="javascript:RejectAllChanges();">Reject</a> &nbsp;<asp:CheckBox ID="chkFreeze" runat="server" Checked="false" Text="Freeze all changes?" />
                            </td>

                        </tr>
                        <tr>
                            <td colspan="2">
                                <table class="table" width="100%">
                                    <tr>
                                        <td>
                                            <asp:TextBox ID="txtWorkSpecification" runat="server" />
                                            <div style="float: left; width: 98%;">
                                                <div style="float: left; font-size: 10px; text-align: left; min-width: 200px;">
                                                    <asp:LinkButton ID="lbtnDownloadWorkSpecificationFilePreview" runat="server"
                                                        Text="Download Preview" OnClick="lbtnDownloadWorkSpecificationFilePreview_Click" />&nbsp;
                                                    <asp:LinkButton ID="lbtnDownloadWorkSpecificationFile" runat="server"
                                                        Text="Download" OnClick="lbtnDownloadWorkSpecificationFile_Click" />
                                                </div>
                                                <div style="float: right; font-size: 10px; text-align: right; color: gray; min-width: 200px;">
                                                    <asp:Literal ID="ltrlLastCheckedInBy" runat="server" /><asp:Literal ID="ltrlLastVersionUpdateBy" runat="server" />
                                                </div>
                                            </div>
                                        </td>
                                    </tr>

                                    <tr id="trSaveWorkSpecification" runat="server">
                                        <td>
                                            <div class="btn_sec">
                                                <asp:Button ID="btnSaveWorkSpecification" runat="server" Text="Save" CssClass="ui-button"
                                                    OnClientClick="javascript:SetContentInTextbox();"
                                                    OnClick="btnSaveWorkSpecification_Click" />
                                                <asp:HiddenField ID="hdnWorkSpecificationId" runat="server" Value="0" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <hr />
                                <br />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">Attachment(s):
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <table class="table" width="100%">
                                    <tr>
                                        <td>
                                            <asp:Repeater ID="rptWorkFiles" OnItemCommand="rptWorkFiles_ItemCommand" OnItemDataBound="rptWorkFiles_ItemDataBound" runat="server">
                                                <HeaderTemplate>
                                                    <table class="table" width="100%">
                                                        <thead>
                                                            <tr class="trHeader">
                                                                <th>Attachments</th>
                                                                <th width="200">Uploaded By</th>
                                                            </tr>
                                                        </thead>
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <tr class="FirstRow">
                                                        <td><small>
                                                            <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue"
                                                                CommandName="DownloadFile" /></small>
                                                        </td>
                                                        <td><%#Eval("FirstName") %>
                                                        </td>
                                                    </tr>

                                                </ItemTemplate>
                                                <AlternatingItemTemplate>
                                                    <tr class="AlternateRow">
                                                        <td><small>
                                                            <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue"
                                                                CommandName="DownloadFile" /></small>
                                                        </td>
                                                        <td><%#Eval("FirstName") %>
                                                        </td>
                                                    </tr>
                                                </AlternatingItemTemplate>
                                                <FooterTemplate>
                                                    </table>
                                               
                                                </FooterTemplate>
                                            </asp:Repeater>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="lbtnDownloadWorkSpecificationFile" />
                    <asp:PostBackTrigger ControlID="lbtnDownloadWorkSpecificationFilePreview" />
                </Triggers>
            </asp:UpdatePanel>
        </div>
        <div id="divFinishedWorkFiles" runat="server" title="Finished Work Files">
            <asp:UpdatePanel ID="upFinishedWorkFiles" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <table width="500">
                        <tr>
                            <td>In progress...
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>
    <%--Popup Ends--%>
    <%--Popup ForFreez Approvel--%>
    <div class="hide">
        <div id="divFreez" runat="server">
            <asp:UpdatePanel ID="UpWorkspecApprooval" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <table style="width: 100%">
                        <tr>
                            <td style="text-align: center">Password:
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align: center">
                                <asp:TextBox ID="txtAuthenticateUser" runat="server" Width="150px" TextMode="Password"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align: center">
                                <div class="btn_sec">
                                    <asp:Button ID="btnSetApproval" runat="server" Text="Approve" CssClass="ui-button"
                                        OnClick="btnSetApproval_Click" />
                                    <asp:HiddenField ID="HiddenField1" runat="server" Value="0" />
                                </div>
                            </td>
                        </tr>

                    </table>
                </ContentTemplate>
                <%--<Triggers>
                    <asp:PostBackTrigger ControlID="lbtnDownloadWorkSpecificationFile" />
                    <asp:PostBackTrigger ControlID="lbtnDownloadWorkSpecificationFilePreview" />
                </Triggers>--%>
            </asp:UpdatePanel>
        </div>

    </div>
    <%--Popup ForFreez Approvel Ends--%>




    <%--Popup log file view --%>


    <div id="divBackground" class="modal">
    </div>
    <div id="divImage">
        <table style="height: 100%; width: 100%">
            <tr>
                <td valign="middle" align="center">
                    <img id="imgLoader" alt="" src="../img/loader.gif" />
                    <img id="imgFull" alt="" src="" style="display: none; height: 500px; width: 590px" />
                </td>
            </tr>
            <tr>
                <td align="center" valign="bottom">
                    <input id="btnClose" type="button" value="close" onclick="HideDiv()" />
                </td>
            </tr>
        </table>
    </div>

    <style>
        .modalBackground {
            background-color: Black;
            filter: alpha(opacity=40);
            opacity: 0.4;
        }

        .modalPopup1 {
            background-color: #FFFFFF;
            width: 500px;
            border: 3px solid #0DA9D0;
        }

            .modalPopup1 .header {
                background-color: #2FBDF1;
                height: 30px;
                color: White;
                line-height: 30px;
                text-align: center;
                font-weight: bold;
            }

            .modalPopup1 .body {
                min-height: 50px;
                line-height: 30px;
                text-align: center;
                padding: 5px;
            }

            .modalPopup1 .footer {
                padding: 3px;
            }

            .modalPopup1 .button {
                height: 23px;
                color: White;
                line-height: 23px;
                text-align: center;
                font-weight: bold;
                cursor: pointer;
                background-color: #9F9F9F;
                border: 1px solid #5C5C5C;
            }

            .modalPopup1 td {
                text-align: left;
            }
    </style>
    <input type="hidden" id="hiddenFilePath" runat="server" />
    <input type="hidden" id="hiddenFileName" runat="server" />
    <asp:LinkButton Text="" ID="lnkFake" runat="server" />
    <asp:ModalPopupExtender ID="mpe" runat="server" PopupControlID="Panel1" TargetControlID="lnkFake"
        CancelControlID="closebtn1" BackgroundCssClass="modalBackground">
    </asp:ModalPopupExtender>

    <asp:Panel ID="Panel1" runat="server" BackColor="White"
        Width="40%" Style="z-index: 111; background-color: White; position: absolute; left: 35%; top: 12%; border: outset 2px gray; padding: 5px; display: none">
        <div>
            <table style="width: 100%; height: 100%;" cellpadding="0" cellspacing="5">
                <tr style="background-color: gray">
                    <td colspan="2" style="color: White; font-weight: bold; font-size: 1.2em; padding: 3px"
                        align="center">
                        <asp:Label ID="lblFName" ForeColor="White" runat="server" />
                        <a id="closebtn1" style="color: white; float: right; text-decoration: none" class="btnClose" href="#">X</a>
                    </td>
                </tr>
            </table>
        </div>
        <div style="padding: 5px">
            <video id="Vedioplayer" style="display: none" height="98%" width="98%" controls>
                <source id='mp4Source' type="video/mp4" />
            </video>
            <audio id="Audiolayer" style="display: none" height="98%" width="98%" controls> 
                <source id='mp3Source' type="audio/mp3" />
            </audio>
        </div>
    </asp:Panel>



    <div id="mask">
    </div>
    <asp:Panel ID="pnlpopup" runat="server" BackColor="White"
        Width="40%" Style="z-index: 111; background-color: White; position: absolute; left: 35%; top: 12%; border: outset 2px gray; padding: 5px; display: none">
        <div>
            <table style="width: 100%; height: 100%;" cellpadding="0" cellspacing="5">
                <tr style="background-color: gray">
                    <td colspan="2" style="color: White; font-weight: bold; font-size: 1.2em; padding: 3px"
                        align="center">
                        <asp:Label ID="lblFileName" ForeColor="White" runat="server" />
                        <a id="closebtn" style="color: white; float: right; text-decoration: none" class="btnClose" href="#" onclick="HidePopupLogFile()">X</a>
                    </td>
                </tr>
            </table>
        </div>
        <div style="padding: 5px">

            <asp:Image ID="imgPreview" Height="98%" Width="98%" runat="server" Visible="false" />

            <div runat="server" height="98%" width="98%" id="divAudioVido">
                <video height="98%" width="98%" controls>
                    <source type="video/mp4" runat="server" id="videomp4" />
                    <source type="video/3gpp" runat="server" id="video3gpp" />
                    <source type="video/mpeg" runat="server" id="videompeg" />
                    <source type="video/x-ms-wmv" runat="server" id="videowmv" />
                    <source type="video/webm" runat="server" id="videowebm" />
                    <source type="audio/mp3" runat="server" id="audiomp3" />
                    <source type="audio/mp4" runat="server" id="audiomp4" />
                    <source type="audio/x-ms-wma" runat="server" id="audiowma" />
                </video>
            </div>
        </div>
    </asp:Panel>
    <%--Popup log file viewl--%>

    <%--<script type="text/javascript" src="../js/jquery-migrate-1.0.0.js"></script>--%>
    <script type="text/javascript" src='../js/ice/lib/rangy/rangy-core.js'></script>
    <script type="text/javascript" src='../js/ice/src/polyfills.js'></script>
    <script type="text/javascript" src='../js/ice/src/ice.js'></script>
    <script type="text/javascript" src='../js/ice/src/dom.js'></script>
    <script type="text/javascript" src='../js/ice/src/icePlugin.js'></script>
    <script type="text/javascript" src='../js/ice/src/icePluginManager.js'></script>
    <script type="text/javascript" src='../js/ice/src/bookmark.js'></script>
    <script type="text/javascript" src='../js/ice/src/selection.js'></script>
    <script type="text/javascript" src='../js/ice/src/plugins/IceAddTitlePlugin/IceAddTitlePlugin.js'></script>
    <script type="text/javascript" src='../js/ice/src/plugins/IceCopyPastePlugin/IceCopyPastePlugin.js'></script>
    <script type="text/javascript" src='../js/ice/src/plugins/IceEmdashPlugin/IceEmdashPlugin.js'></script>
    <script type="text/javascript" src='../js/ice/src/plugins/IceSmartQuotesPlugin/IceSmartQuotesPlugin.js'></script>
    <script type="text/javascript" src="../js/ice/lib/tinymce/jscripts/tiny_mce/tiny_mce.js"></script>


    <script type="text/javascript">
        
        function papterclipClick()
        {
            $('#tduploadcontrol').show();
        }



        function ViewDetails(Id, longName, shortName,fileType) {
            debugger;
          
            $("#<%=lblFName.ClientID %>").text(shortName);
            var filePath = '../TaskAttachments/'+ longName;

            var fileName = filePath;
            var fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1); 

            var tv_main_channel = "";

            if(fileType == 3) // Video
            {
                $('#Vedioplayer').show();
                $('#Audiolayer').hide();
                if(fileExtension == "mp4")
                {
                    tv_main_channel = $('#mp4Source');
                }
                tv_main_channel.attr('src', filePath);
                var video_block = $('#Vedioplayer');
                video_block.load();
            }

            if(fileType == 2) // Audio
            {
                $('#Vedioplayer').hide();
                $('#Audiolayer').show();
                if(fileExtension == "mp4")
                {
                    tv_main_channel = $('#mp4Source');
                }
                if(fileExtension == "mp3")
                {
                    tv_main_channel = $('#mp3Source');
                }

                tv_main_channel.attr('src', filePath);
                var audio_block = $('#Audiolayer');
                audio_block.load();
            }
        }
        function LoadDiv(url) {
            debugger;
            var img = new Image();
            var bcgDiv = document.getElementById("divBackground");
            var imgDiv = document.getElementById("divImage");
            var imgFull = document.getElementById("imgFull");
            var imgLoader = document.getElementById("imgLoader");
            imgLoader.style.display = "block";
            img.onload = function () {
                imgFull.src = img.src;
                imgFull.style.display = "block";
                imgLoader.style.display = "none";
            };
            img.src = url;
            var width = document.body.clientWidth;
            if (document.body.clientHeight > document.body.scrollHeight) {
                bcgDiv.style.height = document.body.clientHeight + "px";
            }
            else {
                bcgDiv.style.height = document.body.scrollHeight + "px";
            }
            imgDiv.style.left = (width - 650) / 2 + "px";
            imgDiv.style.top = "20px";
            bcgDiv.style.width = "100%";
 
            bcgDiv.style.display = "block";
            imgDiv.style.display = "block";
            return false;
        }
        function HideDiv() {
            var bcgDiv = document.getElementById("divBackground");
            var imgDiv = document.getElementById("divImage");
            var imgFull = document.getElementById("imgFull");
            if (bcgDiv != null) {
                bcgDiv.style.display = "none";
                imgDiv.style.display = "none";
                imgFull.style.display = "none";
            }
        }
    </script>


    <script type="text/javascript">
        var intUserId = <%=Session[JG_Prospect.Common.SessionKey.Key.UserId.ToString()]%>;
        var strUserName = '<%=Session[JG_Prospect.Common.SessionKey.Key.Username.ToString()]%>';

        var txtWorkSpecification = '<%=txtWorkSpecification.ClientID%>';
        
        function LoadTinyMce() {
            tinymce.init({
                mode: "exact",
                elements: txtWorkSpecification,
                theme: "advanced",
                plugins: 'ice,icesearchreplace',
                //theme_advanced_buttons1: "bold,italic,underline,|,bullist,numlist,|,undo,redo,code,|,search,replace,|,ice_togglechanges,ice_toggleshowchanges,iceacceptall,icerejectall,iceaccept,icereject",
                theme_advanced_buttons1: "bold,italic,underline,|,bullist,numlist,|,undo,redo,code,|,search,replace",
                theme_advanced_buttons2: "",
                theme_advanced_buttons3: "",
                theme_advanced_buttons4: "",
                theme_advanced_toolbar_location: "top",
                theme_advanced_toolbar_align: "left",
                extended_valid_elements: "p,span[*],delete[*],insert[*]",
                ice: {
                    user: { name: strUserName, id: intUserId },
                    preserveOnPaste: 'p,a[href],i,em,b,span',
                    deleteTag: 'delete',
                    insertTag: 'insert'
                },
                height: '150',
                width:'100%'
            });
        }

        function setUserMCE(el) {
            var name = 'J Grove';
            var id = 22;
            tinymce.execCommand('ice_changeuser', { id: id, name: name });
        }

        function AcceptAllChanges(){
            tinymce.execCommand('iceacceptall');
        }

        function RejectAllChanges(){
            tinymce.execCommand('icerejectall');
        }

        function SetContentInTextbox(){
            $('#'+txtWorkSpecification).val(""+tinymce.get(txtWorkSpecification).getContent());
        }
    </script>
    <script type="text/javascript">

        Dropzone.autoDiscover = false;
        $(function () {
            Initialize();
            LoadTinyMce();
        });

        var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

        prmTaskGenerator.add_endRequest(function () {
            Initialize();
        });

        function Initialize() {
            ApplyDropZone();
            LoadTinyMce();
        }

        function ShowPopup(varControlID) {
            var objDialog = $(varControlID).dialog({ width: "700px", height: "auto" });
            // this will enable postback from dialog buttons.
            objDialog.parent().appendTo(jQuery("form:first"));
        }

        function ShowPopupWithTitle(varControlID,strTitle) {
            var objDialog = $(varControlID).dialog({ width: "700px", height: "auto" });
            $('.ui-dialog-title').html(strTitle);
            // this will enable postback from dialog buttons.
            objDialog.parent().appendTo(jQuery("form:first"));
        }

        //Add By Ratnakar
        function ShowPopupForPasswordAuthentication(varControlID,strTitle) {
            var objDialog = $(varControlID).dialog({ width: "300px", height: "auto",margin:"0 auto" });
            $('.ui-dialog-title').html(strTitle);
            // this will enable postback from dialog buttons.
            objDialog.parent().appendTo(jQuery("form:first"));
            
        }
        function HidePopup(varControlID) {
            $(varControlID).dialog("close");
        }
        function HidePopup1(varControlID) {
            $(varControlID).dialog("close");
        }
        // check if user has selected any designations or not.
        function checkDesignations(oSrc, args) {
            args.IsValid = ($("#<%= ddlUserDesignation.ClientID%> input:checked").length > 0);
        }

        function copytoListID(sender) {
            var strListID = $.trim($(sender).text());
            if (strListID.length > 0) {
                $('#<%= txtTaskListID.ClientID %>').val(strListID);
            }
        }

        function AddAttachmenttoViewState(serverfilename, hdnControlID) {

            var attachments;

            if ($(hdnControlID).val()) {
                attachments = $(hdnControlID).val() + serverfilename + "^";
            }
            else {
                attachments = serverfilename + "^";
            }

            $(hdnControlID).val(attachments);
        }

        function RemoveAttachmentFromViewState(filename) {

            if ($('#<%= hdnAttachments.ClientID %>').val()) {

                //split images added by ^ seperator
                var attachments = $('#<%= hdnAttachments.ClientID %>').val().split("^");

                if (attachments.length > 0) {
                    //find index of filename and remove it.
                    var index = attachments.indexOf(filename);

                    if (index > -1) {
                        attachments.splice(index, 1);
                    }

                    //join remaining attachments.
                    if (attachments.length > 0) {
                        $('#<%= hdnAttachments.ClientID %>').val(attachments.join("^"));
                    }
                    else {
                        $('#<%= hdnAttachments.ClientID %>').val("");
                    }
                }
            }
        }

        var objNotesDropzone;
        var objWorkFileDropzone;
        var objSubTaskDropzone;
        //Dropzone.autoDiscover = false;
        //Dropzone.options.dropzoneForm = false;

        function ApplyDropZone() {
            debugger;
            ////User's drag and drop file attachment related code

            //remove already attached dropzone.
            if (objWorkFileDropzone) {
                objWorkFileDropzone.destroy();
                objWorkFileDropzone = null;
            }

            if (objNotesDropzone) {
                objNotesDropzone.destroy();
                objNotesDropzone = null;
            }

            if (objSubTaskDropzone) {
                objSubTaskDropzone.destroy();
                objSubTaskDropzone = null;
            }
            debugger;
            objWorkFileDropzone = GetWorkFileDropzone("div.work-file", 'div.work-file-previews');
            //objNotesDropzone = GetNotesDropzone("div.work-file-note", 'div.work-file-previews-note');
            //remove already attached dropzone.
            
           
            if($("#<%=divNoteDropzone.ClientID%>").length > 0) {
                debugger;
                objNotesDropzone = new Dropzone("#<%=divNoteDropzone.ClientID%>", {
                    maxFiles: 1,
                    url: "taskattachmentupload.aspx",
                    thumbnailWidth: 90,
                    thumbnailHeight: 90,
                    previewsContainer: 'div#<%=divNoteDropzonePreview.ClientID%>',
                    init: function () {
                        this.on("maxfilesexceeded", function (data) {
                            //var res = eval('(' + data.xhr.responseText + ')');
                            alert('you are reached maximum attachment upload limit.');
                        });

                        // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                        this.on("success", function (file, response) {
                            debugger;
                            var filename = response.split("^");

                           

                            debugger;

                            $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                            var fileType="";
                            if(file.type.match('audio.*'))
                            {   
                                fileType="audio";
                                ($('#<%= hdnNoteFileType.ClientID %>').val(fileType));
                            }

                            if(file.type.match('video.*'))
                            {  
                                fileType="video";
                                ($('#<%= hdnNoteFileType.ClientID %>').val(fileType));
                            }


                            

                           
                            AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnNoteAttachments.ClientID %>');

                            $('#<%= btnUploadLogFiles.ClientID %>').click();

                            console.log($('#<%= hdnNoteAttachments.ClientID %>').val());
                            //this.removeFile(file);
                        });
                    }

                });
            }

            debugger;
            if($("#<%=divSubTaskDropzone.ClientID%>").length > 0) {
                debugger;
                objSubTaskDropzone = new Dropzone("#<%=divSubTaskDropzone.ClientID%>", {
                    maxFiles: 5,
                    url: "taskattachmentupload.aspx",
                    thumbnailWidth: 90,
                    thumbnailHeight: 90,
                    previewsContainer: 'div#<%=divSubTaskDropzonePreview.ClientID%>',
                    init: function () {
                        this.on("maxfilesexceeded", function (data) {
                            //var res = eval('(' + data.xhr.responseText + ')');
                            alert('you are reached maximum attachment upload limit.');
                        });

                        // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                        this.on("success", function (file, response) {
                            debugger;
                            var filename = response.split("^");
                            $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                            AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnAttachments.ClientID %>');
                            console.log($('#<%= hdnAttachments.ClientID %>').val());
                            //this.removeFile(file);
                        });

                        //when file is removed from dropzone element, remove its corresponding server side file.
                        //this.on("removedfile", function (file) {
                        //    var server_file = $(file.previewTemplate).children('.server_file').text();
                        //    RemoveTaskAttachmentFromServer(server_file);
                        //});

                        // When is added to dropzone element, add its remove link.
                        //this.on("addedfile", function (file) {

                        //    // Create the remove button
                        //    var removeButton = Dropzone.createElement("<a><small>Remove file</smalll></a>");

                        //    // Capture the Dropzone instance as closure.
                        //    var _this = this;

                        //    // Listen to the click event
                        //    removeButton.addEventListener("click", function (e) {
                        //        // Make sure the button click doesn't submit the form:
                        //        e.preventDefault();
                        //        e.stopPropagation();
                        //        // Remove the file preview.
                        //        _this.removeFile(file);
                        //    });

                        //    // Add the button to the file preview element.
                        //    file.previewElement.appendChild(removeButton);
                        //});
                    }

                });
            }
        }

        function GetNotesDropzone(strDropzoneSelector, strPreviewSelector) {
            debugger;
            return new Dropzone(strDropzoneSelector,
                {
                    maxFiles:1,
                    url: "taskattachmentupload.aspx",
                    thumbnailWidth: 90,
                    thumbnailHeight: 90,
                    previewsContainer: strPreviewSelector,
                    init: function () {
                        this.on("maxfilesexceeded", function (data) {
                            //var res = eval('(' + data.xhr.responseText + ')');
                            alert('you are reached maximum attachment upload limit.');
                        });

                        // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                        this.on("success", function (file, response) {
                            debugger;
                            var filename = response.split("^");
                            $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                            AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnWorkFiles.ClientID %>');

                            // saves attachment.
                            $('#<%=hdnNoteAttachments.ClientID%>').click(); console.log('clicked');
                            //this.removeFile(file);
                        });
                    }

                });
            }

            debugger;
            function GetWorkFileDropzone(strDropzoneSelector, strPreviewSelector) {
                debugger;
                return new Dropzone(strDropzoneSelector,
                    {
                        maxFiles: 5,
                        url: "taskattachmentupload.aspx",
                        thumbnailWidth: 90,
                        thumbnailHeight: 90,
                        previewsContainer: strPreviewSelector,
                        init: function () {
                            this.on("maxfilesexceeded", function (data) {
                                //var res = eval('(' + data.xhr.responseText + ')');
                                alert('you are reached maximum attachment upload limit.');
                            });

                            // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                            this.on("success", function (file, response) {
                                debugger;
                                var filename = response.split("^");
                                $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                                AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnWorkFiles.ClientID %>');

                                // saves attachment.
                                $('#<%=btnAddAttachment.ClientID%>').click(); console.log('clicked');
                                //this.removeFile(file);
                            });

                            //when file is removed from dropzone element, remove its corresponding server side file.
                            //this.on("removedfile", function (file) {
                            //    var server_file = $(file.previewTemplate).children('.server_file').text();
                            //    RemoveTaskAttachmentFromServer(server_file);
                            //});

                            // When is added to dropzone element, add its remove link.
                            //this.on("addedfile", function (file) {

                            //    // Create the remove button
                            //    var removeButton = Dropzone.createElement("<a><small>Remove file</smalll></a>");

                            //    // Capture the Dropzone instance as closure.
                            //    var _this = this;

                            //    // Listen to the click event
                            //    removeButton.addEventListener("click", function (e) {
                            //        // Make sure the button click doesn't submit the form:
                            //        e.preventDefault();
                            //        e.stopPropagation();
                            //        // Remove the file preview.
                            //        _this.removeFile(file);
                            //    });

                            //    // Add the button to the file preview element.
                            //    file.previewElement.appendChild(removeButton);
                            //});
                        }

                    });
                }

                //Remove file from server once it is removed from dropzone.
                //function RemoveTaskAttachmentFromServer(filename) {
                //var param = { serverfilename: filename };
                //$.ajax({
                //    type: "POST",
                //    data: JSON.stringify(param),
                //    url: "taskattachmentupload.aspx/RemoveUploadedattachment",
                //    contentType: "application/json; charset=utf-8",
                //    dataType: "json",
                //    success: OnAttachmentRemoveSuccess,
                //    error: OnAttachmentRemoveError
                //});
                //}

                // Once attachement is removed then remove it from viewstate as well to keep correct track of file upload.
                //function OnAttachmentRemoveSuccess(data) {
                //    var result = data.d;
                //    if (r - esult) {
                //        RemoveAttachmentFromViewState(result);
                //    }
                //}

                //// Once attachement is removed then remove it from viewstate as well to keep correct track of file upload.
                //function OnAttachmentRemoveError(data) {
                //    var result = data.d;
                //    if (result) {
                //        console.log(result);
                //    }
                //}

    </script>
</asp:Content>
