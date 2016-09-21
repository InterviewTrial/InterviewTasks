<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="TaskList.aspx.cs" Inherits="JG_Prospect.Sr_App.TaskList" EnableEventValidation="false" %>

<%@ MasterType VirtualPath="~/Sr_App/SR_app.Master" %>
<%@ Register TagPrefix="asp" Namespace="Saplin.Controls" Assembly="DropDownCheckBoxes" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../Styles/dd.css" rel="stylesheet" />
    <link href="../css/dropzone/css/basic.css" rel="stylesheet" />
    <link href="../css/dropzone/css/dropzone.css" rel="stylesheet" />
    <script type="text/javascript" src="../js/dropzone.js"></script>
    <style type="text/css">
        .modalBackground {
            background-color: Gray;
            filter: alpha(opacity=80);
            opacity: 0.8;
            z-index: 10000;
            display: none;
        }

        .myfont {
            font-family: 'barcode_fontregular';
            font-size: 37px;
        }

        .black_overlay {
            display: none;
            position: fixed;
            top: 0%;
            left: 0%;
            width: 100%;
            height: 100%;
            background-color: black;
            z-index: 1001;
            -moz-opacity: 0.8;
            opacity: .80;
            filter: alpha(opacity=80);
            overflow-y: hidden;
        }

        .white_content {
            display: none;
            position: absolute;
            top: 10%;
            left: 20%;
            width: 60%;
            height: 5%;
            padding: 16px;
            border: 10px solid #327FB5;
            background-color: white;
            z-index: 1002;
            overflow: auto;
        }

        @font-face {
            font-family: 'barcode_fontregular';
            src: url('../fonts/barcodefont-webfont.eot');
            src: url('../fonts//barcodefont-webfont.eot?#iefix') format('embedded-opentype'), url('../fonts/barcodefont-webfont.woff2') format('woff2'), url('../fonts/barcodefont-webfont.woff') format('woff'), url('../fonts/barcodefont-webfont.ttf') format('truetype'), url('../fonts/barcodebarcodefont-webfont.svg#barcode_fontregular') format('svg');
            font-weight: normal;
            font-style: normal;
        }

        .GridView1 {
            border-collapse: collapse;
        }

            .GridView1 > tbody > tr > td {
                border: 1px solid #CCCCCC;
                margin: 0;
                padding: 0px !important;
            }

        .grid td {
            padding: 0px !important;
        }


        .clsGrid {
            overflow: inherit !important;
        }

        .clsFixWidth > tbody tr td {
            word-break: break-all;
        }

        .clsOverFlow {
            overflow: auto;
            height: 150px;
        }
    </style>
    <style type="text/css">
        .Autocomplete {
            overflow: auto;
            height: 150px;
        }

        .style1 {
            width: 451px;
        }

        .style2 {
            width: 451px;
        }

        .auto-style10 {
            width: 58px;
        }

        .auto-style11 {
            width: 100%;
        }

        .auto-style13 {
        }

        .auto-style14 {
            height: 137px;
            width: 447px;
        }

        .auto-style15 {
            width: 447px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:UpdatePanel ID="upTaskListContainer" runat="server">
        <ContentTemplate>
            <div class="right_panel">
                <!-- appointment tabs section start -->
                <ul class="appointment_tab">
                    <li><a href="home.aspx">Personal Appointment</a></li>
                    <li><a href="GoogleCalendarView.aspx">Master Appointment</a></li>
                    <li><a href="#">Construction Calendar</a></li>
                    <li><a href="CallSheet.aspx">Call Sheet</a></li>
                </ul>

                <!-- appointment tabs section end -->
                <h1>Task List</h1>

                <div class="form_panel_custom">
                    <br />
                    <%--Filter Section--%>
                    <table width="100%" cellspacing="5" class="filter_section">
                        <tr>
                            <td id="tdDesigCap" runat="server">
                                <span>Designation:</span>
                            </td>
                            <td id="tdUserCap" runat="server">
                                <span>User:</span>
                            </td>
                            <td>
                                <span>Status:</span>
                            </td>
                            <td>
                                <span>Period From:</span>
                            </td>
                            <td><span>To:</span></td>
                            <td>
                                <span>Task Title:</span>
                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td id="tdDesig" runat="server">
                                <asp:DropDownList ID="ddlDesignation" Width="130" AutoPostBack="true" runat="server"
                                    OnSelectedIndexChanged="ddlDesignation_SelectedIndexChanged">
                                    <asp:ListItem Text="--All--" Value="0"></asp:ListItem>
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
                                </asp:DropDownList>
                            </td>
                            <td id="tdUsers" runat="server">
                                <asp:DropDownList ID="ddlUsers" Width="100" AutoPostBack="true" runat="server"
                                    OnSelectedIndexChanged="ddlUsers_SelectedIndexChanged" />
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlTaskStatus" Width="100" runat="server" AutoPostBack="True"
                                    OnSelectedIndexChanged="ddlTaskStatus_SelectedIndexChanged" />
                            </td>
                            <td>
                                <asp:TextBox ID="txtFromDate" CssClass="filter-datepicker" Width="80" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox ID="txtToDate" CssClass="filter-datepicker" Width="80" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox ID="txtSearch" runat="server" Width="150" />
                            </td>
                            <td>
                                <asp:ImageButton ID="btnSearch" runat="server" ImageUrl="~/img/search_btn.png" CssClass="searchbtn"
                                    Style="display: none;" OnClick="btnSearch_Click" />
                            </td>
                        </tr>
                    </table>
                    <br />
                    <%--Task List Section--%>
                    <asp:GridView ID="gvTasks" runat="server" EmptyDataText="No task available!" AllowCustomPaging="true" 
                        AllowPaging="true" PageSize="20" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" 
                        BorderStyle="Solid" BorderWidth="1" AutoGenerateColumns="False" 
                        OnRowDataBound="gvTasks_RowDataBound" 
                        OnRowCommand="gvTasks_RowCommand"
                        OnPageIndexChanging="gvTasks_PageIndexChanging">
                        <HeaderStyle CssClass="trHeader " />
                        <RowStyle CssClass="FirstRow" />
                        <AlternatingRowStyle CssClass="AlternateRow " />
                        <FooterStyle CssClass="trFooter" />
                        <PagerStyle CssClass="trPager" />
                        <Columns>
                            <asp:BoundField DataField="InstallId" HeaderText="Install ID" HeaderStyle-Width="50" />
                            <asp:TemplateField HeaderText="Task Title" HeaderStyle-Width="300">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hypTask" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Designation" HeaderStyle-Width="150">
                                <ItemTemplate>
                                    <asp:Label ID="lblDesignation" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Assigned To" HeaderStyle-Width="150">
                                <ItemTemplate>
                                    <asp:Label ID="lblAssignedUser" runat="server" />
                                    <asp:DropDownCheckBoxes ID="ddcbAssignedUser" runat="server" UseSelectAllNode="false"
                                        AutoPostBack="true" OnSelectedIndexChanged="gvTasks_ddcbAssignedUser_SelectedIndexChanged">
                                        <Style SelectBoxWidth="140" DropDownBoxBoxWidth="120" DropDownBoxBoxHeight="150" />
                                        <Texts SelectBoxCaption="--Open--" />
                                    </asp:DropDownCheckBoxes>
                                    <asp:LinkButton ID="lbtnRequestStatus" runat="server" Visible="false" Text="Request" 
                                        CommandName="request" CommandArgument='<%# Eval("TaskId") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status" HeaderStyle-Width="60">
                                <ItemTemplate>
                                    <asp:Literal ID="ltrlStatus" runat="server" />
                                    <asp:DropDownList ID="ddlStatus" Width="50" AutoPostBack="true" runat="server" 
                                        OnSelectedIndexChanged="gvTasks_ddlStatus_SelectedIndexChanged" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Due Date" HeaderStyle-Width="60">
                                <ItemTemplate>
                                    <asp:Literal ID="ltrlDueDate" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </ContentTemplate>

    </asp:UpdatePanel>

    <script src="../js/jquery.dd.min.js"></script>
    <script type="text/javascript">
        function setTaskListAutoSearch() {

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
                    TriggerTaskListSearch();
                }
            });
            }

            function TriggerTaskListSearch() {
                $('#<%=btnSearch.ClientID %>').click();

            }

            $(document).ready(function () { setTaskListAutoSearch(); });
            prmTaskGenerator.add_endRequest(function () { setTaskListAutoSearch(); });
    </script>

</asp:Content>
