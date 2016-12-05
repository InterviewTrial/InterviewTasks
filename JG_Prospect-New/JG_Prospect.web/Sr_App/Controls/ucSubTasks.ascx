<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucSubTasks.ascx.cs" Inherits="JG_Prospect.Sr_App.Controls.ucSubTasks" %>

<fieldset class="tasklistfieldset">
    <legend>Task List</legend>
    <asp:UpdatePanel ID="upSubTasks" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="divSubTaskGrid">
                <asp:GridView ID="gvSubTasks" runat="server" ShowHeaderWhenEmpty="true" AllowSorting="true" EmptyDataRowStyle-HorizontalAlign="Center"
                    HeaderStyle-BackColor="Black" HeaderStyle-ForeColor="White" BackColor="White" EmptyDataRowStyle-ForeColor="Black"
                    EmptyDataText="No sub task available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0"
                    AutoGenerateColumns="False" EnableSorting="true" GridLines="Vertical" DataKeyNames="TaskId,InstallId"
                    OnRowDataBound="gvSubTasks_RowDataBound"
                    OnRowCommand="gvSubTasks_RowCommand"
                    OnSorting="gvSubTasks_Sorting">
                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                    <HeaderStyle CssClass="trHeader " />
                    <RowStyle CssClass="FirstRow" />
                    <AlternatingRowStyle CssClass="AlternateRow " />
                    <Columns>
                        <asp:TemplateField HeaderText="List ID" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="60"
                            SortExpression="InstallId">
                            <ItemTemplate>
                                <asp:Literal ID="ltrlInstallId" runat="server" Text='<%# Eval("InstallId") %>' />
                                <asp:LinkButton ID="lbtnInstallId" CssClass="context-menu" data-highlighter='<%# Eval("TaskId")%>' ForeColor="Blue" runat="server" Text='<%# Eval("InstallId") %>' CommandName="edit-sub-task"
                                    CommandArgument='<%# Container.DataItemIndex  %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Task Description" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left"
                            SortExpression="Description">
                            <ItemTemplate>
                                <%# Eval("Description")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Type" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="85">
                            <ItemTemplate>
                                <asp:Literal ID="ltrlTaskType" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="105"
                            SortExpression="Status">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlStatus_SelectedIndexChanged" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Priority" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="88">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlTaskPriority" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gvSubTasks_ddlTaskPriority_SelectedIndexChanged" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Attachments" HeaderStyle-Width="15%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Left">
                            <ItemTemplate>
                                <asp:Repeater ID="rptAttachment" OnItemCommand="rptAttachment_ItemCommand" OnItemDataBound="rptAttachment_ItemDataBound" runat="server">
                                    <ItemTemplate>
                                        <small>
                                            <asp:LinkButton ID="lbtnDownload" runat="server" ForeColor="Blue" CommandName="DownloadFile" />
                                            <asp:Literal ID="ltrlSeprator" runat="server" Text=" ," />
                                        </small>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="88">
                            <ItemTemplate>
                                <asp:LinkButton ID="lbtlFeedback" runat="server" Text="Comment" CommandName="sub-task-feedback"
                                    CommandArgument='<%# Container.DataItemIndex  %>' />
                                <div>
                                    <asp:CheckBox ID="chkAdmin" runat="server" CssClass="fz fz-admin" ToolTip="Admin" />
                                    <asp:CheckBox ID="chkITLead" runat="server" CssClass="fz fz-techlead" ToolTip="IT Lead" />
                                    <asp:CheckBox ID="chkUser" runat="server" CssClass="fz fz-user" ToolTip="User" />
                                    <div data-id="divPasswordToFreezeSubTask" style="display: none;">
                                        <asp:TextBox ID="txtPasswordToFreezeSubTask" runat="server" TextMode="Password"
                                            data-id="txtPasswordToFreezeSubTask" AutoPostBack="true"
                                            CssClass="textbox" Width="110" OnTextChanged="gvSubTasks_txtPasswordToFreezeSubTask_TextChanged" />
                                    </div>
                                </div>
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
            <div id="divAddSubTask" runat="server">
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
                                &nbsp;
                                <small>
                                    <a href="javascript:void(0);" style="color: #06c;" onclick="copytoListID(this);">
                                        <asp:Literal ID="listIDOpt" runat="server" />
                                    </a>
                                </small>
                            </td>
                            <td>Type:
                                <asp:DropDownList ID="ddlTaskType" AutoPostBack="true" OnSelectedIndexChanged="ddlTaskType_SelectedIndexChanged" runat="server" />
                                &nbsp;&nbsp;Priority:
                                <asp:DropDownList ID="ddlSubTaskPriority" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">Attachment(s):
                                <div style="max-height: 300px; clear: both; background-color: white; overflow-y: auto; overflow-x: hidden;">
                                    <asp:UpdatePanel ID="upnlAttachments" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:Repeater ID="grdSubTaskAttachments" runat="server"
                                                OnItemDataBound="grdSubTaskAttachments_ItemDataBound"
                                                OnItemCommand="grdSubTaskAttachments_ItemCommand">
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
                            <td>Due Date:<asp:TextBox ID="txtSubTaskDueDate" runat="server" CssClass="textbox datepicker" />
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
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</fieldset>

<%--Popup Stars--%>
<div class="hide">

    <%--Sub Task Feedback Popup--%>
    <div id="divSubTaskFeedbackPopup" runat="server" title="Sub Task Feedback">
        <asp:UpdatePanel ID="upSubTaskFeedbackPopup" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <fieldset>
                    <legend>
                        <asp:Literal ID="ltrlSubTaskFeedbackTitle" runat="server" /></legend>
                    <%--<table cellspacing="3" cellpadding="3" width="100%">
                        <tr>
                            <td>
                                <table class="table" cellspacing="0" cellpadding="0" rules="cols" border="1"
                                    style="background-color: White; width: 100%; border-collapse: collapse;">
                                    <tbody>
                                        <tr class="trHeader " style="color: White; background-color: Black;">
                                            <th align="left" scope="col">Description</th>
                                            <th align="center" scope="col" style="width: 15%;">Attachments</th>
                                        </tr>
                                        <tr class="FirstRow">
                                            <td align="left">Feedback for sub task with install Id I.
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </table>--%>
                    <table id="tblAddEditSubTaskFeedback" runat="server" cellspacing="3" cellpadding="3" width="100%">
                        <tr>
                            <td colspan="2">&nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="90" align="right" valign="top">Description:
                            </td>
                            <td>
                                <asp:TextBox ID="txtSubtaskComment" runat="server" CssClass="textbox" TextMode="MultiLine" Rows="4" Width="90%" />
                                <asp:RequiredFieldValidator ID="rfvComment" ValidationGroup="comment"
                                    runat="server" ControlToValidate="txtSubtaskComment" ForeColor="Red" ErrorMessage="Please comment" Display="None" />
                                <asp:ValidationSummary ID="vsComment" runat="server" ValidationGroup="comment" ShowSummary="False" ShowMessageBox="True" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right" valign="top">Files:
                            </td>
                            <td>
                                <input id="hdnSubTaskNoteAttachments" runat="server" type="hidden" />
                                <input id="hdnSubTaskNoteFileType" runat="server" type="hidden" />
                                <div id="divSubTaskNoteDropzone" runat="server" class="dropzone work-file-Note">
                                    <div class="fallback">
                                        <input name="file" type="file" multiple />
                                        <input type="submit" value="Upload" />
                                    </div>
                                </div>
                                <div id="divSubTaskNoteDropzonePreview" runat="server" class="dropzone-previews work-file-previews-note">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div class="btn_sec">
                                    <asp:Button ID="btnSaveSubTaskFeedback" runat="server" ValidationGroup="comment" OnClick="btnSaveSubTaskFeedback_Click" CssClass="ui-button" Text="Save" />
                                    <asp:Button ID="btnSaveCommentAttachment" runat="server" OnClick="btnSaveCommentAttachment_Click" Style="display: none;" Text="Save Attachement" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

</div>
<%--Popup Ends--%>

<script type="text/javascript">
    Dropzone.autoDiscover = false;

    $(function () {
        ucSubTasks_Initialize();
        ApplySubtaskLinkContextMenu();
    });

    var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

    prmTaskGenerator.add_endRequest(function () {
        ucSubTasks_Initialize();
        ApplySubtaskLinkContextMenu();
    });

    function ucSubTasks_Initialize() {
        ucSubTasks_ApplyDropZone();
    }

    function copytoListID(sender) {
        var strListID = $.trim($(sender).text());
        if (strListID.length > 0) {
            $('#<%= txtTaskListID.ClientID %>').val(strListID);
        }
    }

    var objSubTaskDropzone, objSubtaskNoteDropzone;

    function ucSubTasks_ApplyDropZone() {
        //remove already attached dropzone.
        if (objSubTaskDropzone) {
            objSubTaskDropzone.destroy();
            objSubTaskDropzone = null;
        }

        if ($("#<%=divSubTaskDropzone.ClientID%>").length > 0) {
            objSubTaskDropzone = new Dropzone("#<%=divSubTaskDropzone.ClientID%>", {
                maxFiles: 5,
                url: "taskattachmentupload.aspx",
                thumbnailWidth: 90,
                thumbnailHeight: 90,
                previewsContainer: 'div#<%=divSubTaskDropzonePreview.ClientID%>',
                init: function () {
                    this.on("maxfilesexceeded", function (data) {
                        alert('you are reached maximum attachment upload limit.');
                    });

                    // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                    this.on("success", function (file, response) {
                        var filename = response.split("^");
                        $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                        AddAttachmenttoViewState(filename[0] + '@' + file.name, '#<%= hdnAttachments.ClientID %>');
                    });
                }
            });
        }

        //Apply dropzone for comment section.
        if (objSubtaskNoteDropzone) {
            objSubtaskNoteDropzone.destroy();
            objSubTaskNoteDropzone = null;
        }
        objSubTaskNoteDropzone = GetWorkFileDropzone("#<%=divSubTaskNoteDropzone.ClientID%>", '#<%=divSubTaskNoteDropzonePreview.ClientID%>', '#<%= hdnSubTaskNoteAttachments.ClientID %>', '#<%=btnSaveCommentAttachment.ClientID%>');
    }

    function ucSubTasks_OnApprovalCheckBoxChanged(sender) {
        var $sender = $(sender);
        if ($sender.prop('checked')) {
            $sender.parent().parent().find('div[data-id="divPasswordToFreezeSubTask"]').show();
        }
        else {
            $sender.parent().parent().find('div[data-id="divPasswordToFreezeSubTask"]').hide();
        }
    }

    function ApplySubtaskLinkContextMenu() {

        $(".context-menu").bind("contextmenu", function () {
            var urltoCopy = updateQueryStringParameter( window.location.href , "hstid" , $(this).attr('data-highlighter'));
            copyToClipboard(urltoCopy);            
            return false;
        });
        
        if ($(".yellowthickborder").length > 0) {
            $('html, body').animate({
                scrollTop: $(".yellowthickborder").offset().top
            }, 2000);
        }

        $(".yellowthickborder").bind("click", function () {
            $(this).removeClass("yellowthickborder");
        });
    }

    
</script>
