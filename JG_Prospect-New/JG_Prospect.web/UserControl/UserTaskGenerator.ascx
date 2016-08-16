<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserTaskGenerator.ascx.cs" Inherits="JG_Prospect.Controls.UserTaskGenerator" %>
<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<link rel="stylesheet" href="../css/jquery-ui.css" />
<link href="../css/dropzone/css/basic.css" rel="stylesheet" />
<link href="../css/dropzone/css/dropzone.css" rel="stylesheet" />
<script type="text/javascript" src="../js/dropzone.js"></script>

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
</style>

<div id="divTaskMain" class="tasklist">
    <asp:UpdatePanel ID="upnlTasks" runat="server" UpdateMode="Always">
        <ContentTemplate>
            <table class="table">
                <tr>

                    <td>
                        <span style="color: #fefefe;">Status:</span>
                    </td>
                    <td>
                        <span style="color: #fefefe;">Period From:</span>

                    </td>
                    <td><span style="color: #fefefe;">To:</span></td>
                    <td></td>
                    <td></td>
                    <td>
                        <asp:HiddenField ID="hdnTaskId" runat="server" />
                    </td>

                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="ddlTaskStatus" Width="100" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlTaskStatus_SelectedIndexChanged">
                            <asp:ListItem Text="--All--" Value="0"></asp:ListItem>
                            <asp:ListItem Text="Open" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                            <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                            <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                            <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                            <asp:ListItem Text="Closed" Value="6"></asp:ListItem>
                        </asp:DropDownList>

                    </td>

                    <td>

                        <asp:TextBox ID="txtFromDate" CssClass="filter-datepicker" Width="80" runat="server"></asp:TextBox></td>

                    <td>
                        <asp:TextBox ID="txtToDate" CssClass="filter-datepicker" Width="80" runat="server"></asp:TextBox></td>

                    <td>

                        <asp:TextBox ID="txtSearch" runat="server" PlaceHolder="Search.." Width="150"></asp:TextBox></td>

                    <td>
                        <asp:ImageButton ID="btnSearch" runat="server" ImageUrl="~/img/search_btn.png" CssClass="searchbtn" Style="display: none;" OnClick="btnSearch_Click" />
                    </td>

                    <td style="width: 8%;">
                        <asp:LinkButton ID="btnLoadMore" runat="server" Text="View More" OnClick="btnLoadMore_Click" />
                    </td>

                </tr>
            </table>
            <div id="taskGrid">
                <asp:GridView ID="gvTasks" runat="server" EmptyDataRowStyle-ForeColor="White" EmptyDataRowStyle-HorizontalAlign="Center" EmptyDataText="No task available!" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" AutoGenerateColumns="False" OnRowDataBound="gvTasks_RowDataBound" OnRowCommand="gvTasks_RowCommand" GridLines="Vertical">
                    <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                    <HeaderStyle CssClass="trHeader " />
                    <RowStyle CssClass="FirstRow" BorderStyle="Solid" />
                    <AlternatingRowStyle CssClass="AlternateRow " />
                    <Columns>
                        <asp:BoundField DataField="InstallId" HeaderText="ID#" HeaderStyle-Width="10%" />
                        <asp:TemplateField HeaderText="Task Title">
                            <ItemTemplate>
                                <asp:LinkButton ID="hypTask" runat="server" CommandName="EditTask" CommandArgument='<%# Eval("TaskId") %>'><%# Eval("Title") %></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Designation" HeaderStyle-Width="15%">
                            <ItemTemplate>
                                <asp:Label ID="lblUserDesignation" runat="server" Text='<%# Eval("Designation") %>' HeaderStyle-Width="10%"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Assigned To" HeaderStyle-Width="12%">
                            <ItemTemplate>
                                <asp:Label ID="lblAssignedUser" runat="server" Text='<%# Eval("FristName") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status" HeaderStyle-Width="5%">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlgvTaskStatus" Width="100" OnSelectedIndexChanged="ddlgvTaskStatus_SelectedIndexChanged" AutoPostBack="true" runat="server">
                                    <asp:ListItem Text="Open" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:HiddenField ID="hdnTaskId" runat="server" Value='<%# Eval("TaskId") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>
        </ContentTemplate>

    </asp:UpdatePanel>

</div>

<div id="divModal" title="Task : Title" style="background: #efeeee url(../img/form-bg.png) repeat-x top">

    <hr />
    <asp:UpdatePanel ID="upnlTaskPopup" runat="server">
        <ContentTemplate>

            <table class="tablealign" style="float: left">
                <tr>
                    <td>Task Title <span style="color: red;">*</span>:</td>
                    <td>
                        <asp:Literal ID="ltlTaskTitle" runat="server"></asp:Literal></td>
                </tr>
                <tr>
                    <td>Task Description <span style="color: red;">*</span>:</td>
                    <td>

                        <asp:Literal ID="ltlDescription" runat="server"></asp:Literal></td>

                </tr>
                <tr>
                    <td>Designation <span style="color: red;">*</span>:</td>
                    <td>
                        <asp:UpdatePanel ID="upnlDesignation" runat="server">
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
                </tr>
                <tr>
                    <td>Assigned:</td>
                    <td>
                        <asp:UpdatePanel ID="upnlAssigned" runat="server">
                            <ContentTemplate>
                                <asp:DropDownCheckBoxes ID="ddcbAssigned" runat="server" UseSelectAllNode="false">
                                    <Style SelectBoxWidth="195" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                </asp:DropDownCheckBoxes>
                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <%--                       <asp:DropDownList ID="ddlAssigned" runat="server" CssClass="textbox" onchange="addRow(this)">
                        <asp:ListItem Text="Darmendra"></asp:ListItem>
                        <asp:ListItem Text="Shabir"></asp:ListItem>
                       </asp:DropDownList>--%>
                  
                    </td>
                </tr>

                <%--            <tr>
                <td></td>
                <td>
                    <asp:Button ID="btnSave" Text="Save" CssClass="ui-button" runat="server"></asp:Button>
                </td>
            </tr>--%>
            </table>
            <table class="tablealign" style="float: left; margin-left: 100px">
                <tr>
                    <td>Staus:</td>
                    <td>

                        <asp:DropDownList ID="cmbStatus" runat="server" CssClass="textbox">
                            <asp:ListItem Text="Open" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                            <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                            <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                            <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                            <asp:ListItem Text="Closed" Value="6"></asp:ListItem>
                        </asp:DropDownList>

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
                </tr>
                <tr>
                    <td>Due Date:</td>
                    <td>
                        <asp:TextBox ID="txtDueDate" runat="server" CssClass="textbox">
                        </asp:TextBox>
                        <asp:CalendarExtender ID="CEDueDate" runat="server" TargetControlID="txtDueDate"></asp:CalendarExtender>
                        <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator3" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtDueDate" ForeColor="Red" ErrorMessage="Please Enter Due Date" Display="None">                                 
                        </asp:RequiredFieldValidator>--%>
                    </td>
                </tr>
                <tr>
                    <td>Hrs of Task:</td>
                    <td>
                        <asp:TextBox ID="txtHours" runat="server" CssClass="textbox">
                        </asp:TextBox>
                        <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator4" ValidationGroup="Submit"
                            runat="server" ControlToValidate="txtHours" ForeColor="Red" ErrorMessage="Please Enter Hours Of Task" Display="None">                                 
                        </asp:RequiredFieldValidator>--%>
                    </td>
                </tr>
            </table>
            <table cellspacing="0" cellpadding="0" width="950px" border="1" style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td>
                        <div class="btn_sec">
                            <asp:Button ID="btnSaveTask" runat="server" Text="Save Task" CssClass="ui-button" ValidationGroup="Submit" OnClick="btnSaveTask_Click" />
                        </div>
                    </td>
                </tr>
            </table>
            <hr />
            <br />
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
                    <td>Attachment:
                    </td>
                    <td>

                        <input id="hdnAttachments" runat="server" type="hidden" />

                        <div class="dropzone" style="overflow: auto; max-height: 150px;" id="dropzoneForm">
                            <div class="fallback">
                                <input name="file" type="file" multiple />
                                <input type="submit" value="Upload" />
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <div class="btn_sec">
                            <asp:Button ID="btnNotes" runat="server" Text="Add Note & Files" CssClass="ui-button" OnClick="btnNotes_Click" />

                        </div>
                    </td>
                </tr>
            </table>
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ValidationGroup="Submit" ShowSummary="False" ShowMessageBox="True" />

        </ContentTemplate>
    </asp:UpdatePanel>


    <script>

        var myDropzone;

        Dropzone.options.dropzoneForm = false;

        $(function () {

            //functions for auto search suggestions.
            createCategorisedAutoSearch();
            setAutoSearch();

            setDatePicker();
            setTaskDivClickTrigger();
            //setSearchTextKeyUpSearchTrigger();
            //manager.SetFocus('#<%=txtTaskTitle.ClientID%>');
            var dlg = $("#divModal").dialog({
                modal: true,
                autoOpen: false,
                height: 700,
                width: 800
            });

            dlg.parent().appendTo(jQuery("form:first"));

        });

        var prmTaskGenerator = Sys.WebForms.PageRequestManager.getInstance();

        prmTaskGenerator.add_endRequest(function () {

            //functions for auto search suggestions.
            createCategorisedAutoSearch();
            setAutoSearch();

            setDatePicker();
            ApplyDropZone();
            //setSearchTextKeyUpSearchTrigger();
            setTaskDivClickTrigger();

            var dlg = $("#divModal").dialog({
                modal: true,
                autoOpen: false,
                height: 700,
                width: 800
            });

            dlg.parent().appendTo(jQuery("form:first"));

        });

        function setAutoSearch() {

            $("#<%=txtSearch.ClientID%>").catcomplete({
                delay: 500,
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: "/Sr_App/ajaxcalls.aspx/GetSearchSuggestions",
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
                if ($(e.target).is("a") || $(e.target).is("select")) return;
                window.location.href = $("#hypTaskListMore").attr("href");
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

            $("#divModal").dialog("option", "title", tasktitle);

            $('#divModal').dialog("open");
        }

        function setDatePicker() {
            // on date selection finish, trigger search, both dates must be selected.
            $('.filter-datepicker').datepicker({

                onSelect: function () {
                    checkDatePickerDatesNTriggerSearch();
                }
            });

            $('.datepicker').datepicker();
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
            $('.tasklist').css('max-height', '800px');
            $('.tasklist').animate({ 'max-height': 800 }, 600);
        }

        function TriggerSearch() {
            $('#<%=btnSearch.ClientID %>').click();

        }

        function CloseTaskPopup() {

            $('#divModal').dialog("close");

        }



        //Add uploaded attachment to viewstate of page to save later.
        function AddAttachmenttoViewState(serverfilename) {

            var attachments;

            if ($('#<%= hdnAttachments.ClientID %>').val()) {
                attachments = $('#<%= hdnAttachments.ClientID %>').val() + serverfilename + "^";
            }
            else {
                attachments = serverfilename + "^";
            }

            $('#<%= hdnAttachments.ClientID %>').val(attachments);
            console.log($('#<%= hdnAttachments.ClientID %>').val());

        }

        //Remove file from server once it is removed from dropzone.
        function RemoveTaskAttachmentFromServer(filename) {

            var param = { serverfilename: filename };

            $.ajax({
                type: "POST",
                data: JSON.stringify(param),
                url: "taskattachmentupload.aspx/RemoveUploadedattachment",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnAttachmentRemoveSuccess,
                error: OnAttachmentRemoveError
            });

        }

        // Once attachement is removed then remove it from viewstate as well to keep correct track of file upload.
        function OnAttachmentRemoveSuccess(data) {
            var result = data.d;
            if (result) {

                RemoveAttachmentFromViewState(result);
            }

        }

        function RemoveAttachmentFromViewState(filename) {

            console.log($('#<%= hdnAttachments.ClientID %>').val());
            if ($('#<%= hdnAttachments.ClientID %>').val()) {

                //split images added by ^ seperator
                var attachments = $('#<%= hdnAttachments.ClientID %>').val().split("^");

                console.log(attachments);

                if (attachments.length > 0) {
                    //find index of filename and remove it.
                    var index = attachments.indexOf(filename);

                    if (index > -1) {
                        attachments.splice(index, 1);
                    }
                    console.log(attachments);

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

        function ApplyDropZone() {

            //User's drag and drop file attachment related code

            //remove already attached dropzone.
            if (myDropzone) {
                myDropzone.destroy();
                myDropzone = null;
            }

            myDropzone = new Dropzone("div#dropzoneForm", {
                maxFiles: 5,
                url: "taskattachmentupload.aspx",
                thumbnailWidth: 100,
                thumbnailHeight: 100,
                init: function () {
                    this.on("maxfilesexceeded", function (data) {
                        //var res = eval('(' + data.xhr.responseText + ')');
                        alert('you are reached maximum attachment upload limit.');
                    });

                    // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                    this.on("success", function (file, response) {
                        var filename = response.split("^");
                        $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');

                        AddAttachmenttoViewState(filename[0]);

                    });

                    //when file is removed from dropzone element, remove its corresponding server side file.
                    this.on("removedfile", function (file) {
                        var server_file = $(file.previewTemplate).children('.server_file').text();
                        RemoveTaskAttachmentFromServer(server_file);
                    });

                    // When is added to dropzone element, add its remove link.
                    this.on("addedfile", function (file) {

                        // Create the remove button
                        var removeButton = Dropzone.createElement("<a><small>Remove file</smalll></a>");

                        // Capture the Dropzone instance as closure.
                        var _this = this;

                        // Listen to the click event
                        removeButton.addEventListener("click", function (e) {
                            // Make sure the button click doesn't submit the form:
                            e.preventDefault();
                            e.stopPropagation();
                            // Remove the file preview.
                            _this.removeFile(file);
                        });

                        // Add the button to the file preview element.
                        file.previewElement.appendChild(removeButton);
                    });
                }

            });
        }
        // check if user has selected any designations or not.
        function checkDesignations(oSrc, args) {

            var n = $("#<%= ddlUserDesignation.ClientID%> input:checked").length;

            args.IsValid = (n > 0);

        }

    </script>
</div>
