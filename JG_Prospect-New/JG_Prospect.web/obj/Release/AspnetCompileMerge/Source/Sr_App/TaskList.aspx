<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="TaskList.aspx.cs" Inherits="JG_Prospect.Sr_App.TaskList" EnableEventValidation="false" %>
<%@ MasterType VirtualPath="~/Sr_App/SR_app.Master" %>
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

    <asp:UpdatePanel ID="UpdatePanel8" runat="server">
        <ContentTemplate>

            <div class="right_panel">

                <!-- appointment tabs section start -->
                <ul class="appointment_tab">
                    <li><a href="home.aspx">Personal Appointment</a></li>
                    <li><a href="GoogleCalendarView.aspx">Master Appointment</a></li>
                    <%-- Originaly it Redirect to  MasterAppointment.aspx altered by Neeta and Redirects to GoogleCalendarView.aspx--%>
                    <%--<li><a href="MasterAppointment.aspx">Master Appointment</a></li>--%>
                    <li><a href="#">Construction Calendar</a></li>
                    <li><a href="CallSheet.aspx">Call Sheet</a></li>
                </ul>
                <!-- appointment tabs section end -->
                <h1>Task List
                </h1>

                <div class="form_panel_custom">
                    <table class="filter_section">
                        <tr>
                            <td>
                                <span>Designation:</span>
                            </td>
                            <td>
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
                            <td style="display: none"></td>
                        </tr>
                        <tr>


                            <td>

                                <asp:DropDownList ID="ddlDesignation" Width="130" AutoPostBack="true" runat="server" OnSelectedIndexChanged="ddlDesignation_SelectedIndexChanged">
                                </asp:DropDownList></td>
                            <td>

                                <asp:DropDownList ID="ddlUsers" Width="100" AutoPostBack="true" runat="server" OnSelectedIndexChanged="ddlUsers_SelectedIndexChanged">
                                </asp:DropDownList></td>
                            <td>

                                <asp:DropDownList ID="ddlTaskStatus" Width="100" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlTaskStatus_SelectedIndexChanged">
                                    <asp:ListItem Text="--All--" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="Open" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Assigned" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="In Progress" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="Pending" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="Re-Opened" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="Closed" Value="6"></asp:ListItem>
                                </asp:DropDownList></td>
                            <td>


                                <asp:TextBox ID="txtFromDate" CssClass="filter-datepicker" Width="80" runat="server"></asp:TextBox></td>
                            <td>
                                <asp:TextBox ID="txtToDate" CssClass="filter-datepicker" Width="80" runat="server"></asp:TextBox></td>
                            <td>

                                <asp:TextBox ID="txtSearch" runat="server" onkeyup="javascript:setSearchTextKeyUpSearchTrigger(this);" Width="150"></asp:TextBox></td>
                            <td>
                                <asp:ImageButton ID="btnSearch" runat="server" ImageUrl="~/img/search_btn.png" CssClass="searchbtn" Style="display: none;" OnClick="btnSearch_Click" />
                            </td>

                            <td style="display: none">
                                <%--<asp:Button ID="btnSubmit" runat="server" OnClick="btnSubmit_Click"  />--%>
                                <a id="hypTaskListMore" href="../Sr_App/TaskList.aspx">View All</a>
                            </td>
                        </tr>
                    </table>
                    <asp:GridView ID="gvTasks" runat="server" EmptyDataText="No task available!" AllowCustomPaging="true" AllowPaging="true" PageSize="20" CssClass="table" Width="100%" CellSpacing="0" CellPadding="0" BorderStyle="Solid" BorderWidth="1" AutoGenerateColumns="False" OnRowDataBound="gvTasks_RowDataBound" OnPageIndexChanging="gvTasks_PageIndexChanging">
                        <HeaderStyle CssClass="trHeader " />
                        <RowStyle CssClass="FirstRow" />
                        <AlternatingRowStyle CssClass="AlternateRow " />
                        <Columns>
                            <asp:BoundField DataField="InstallId" HeaderText="Install ID" />
                            <asp:TemplateField HeaderText="Task Title">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hypTask" runat="server"><%# Eval("Title") %></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Designation">
                                <ItemTemplate>
                                    <asp:Label ID="lblUserDesignation" runat="server" Text='<%# Eval("Designation") %>'></asp:Label>
                                    <%-- <asp:DropDownList ID="ddlRole" runat="server">
                                            <asp:ListItem Text="Sr.Developer"></asp:ListItem>
                                            <asp:ListItem Text="Jr.Developer"></asp:ListItem>
                                        </asp:DropDownList>--%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Assigned To">
                                <ItemTemplate>
                                    <asp:Label ID="lblAssignedUser" runat="server" Text='<%# Eval("FristName") %>'></asp:Label>
                                    <%--<asp:DropDownList ID="ddlRole" runat="server">
                                            <asp:ListItem Text="Sr.Developer"></asp:ListItem>
                                            <asp:ListItem Text="Jr.Developer"></asp:ListItem>
                                        </asp:DropDownList>--%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Label ID="lblTaskStatus" runat="server"></asp:Label>
                                    <%--<asp:DropDownList ID="ddlRole" runat="server">
                                            <asp:ListItem Text="Sr.Developer"></asp:ListItem>
                                            <asp:ListItem Text="Jr.Developer"></asp:ListItem>
                                        </asp:DropDownList>--%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Due Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblTaskDueDate" runat="server" Text='<%#Eval("DueDate")%>'></asp:Label>
                                    <%--<asp:DropDownList ID="ddlRole" runat="server">
                                            <asp:ListItem Text="Sr.Developer"></asp:ListItem>
                                            <asp:ListItem Text="Jr.Developer"></asp:ListItem>
                                        </asp:DropDownList>--%>
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- End of Right panel -->
            </div>
        </ContentTemplate>

    </asp:UpdatePanel>

    <script src="../js/jquery.dd.min.js"></script>


</asp:Content>
