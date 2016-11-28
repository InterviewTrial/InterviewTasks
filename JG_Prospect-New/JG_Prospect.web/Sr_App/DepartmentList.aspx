<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="DepartmentList.aspx.cs" Inherits="JG_Prospect.Sr_App.DepartmentList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <script type="text/javascript">
        function ConfirmDelete() {
            var Ok = confirm('All dependent record will be deleted permanently. Do you want to proceed?');
            if (Ok)
                return true;
            else
                return false;
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="right_panel">
        <!-- appointment tabs section start -->
        <ul class="appointment_tab">
            <li><a href="home.aspx">Personal Appointment</a></li>
            <li><a href="MasterAppointment.aspx">Master Appointment</a></li>
            <li><a href="#">Construction Calendar</a></li>
            <li><a href="CallSheet.aspx">Call Sheet</a></li>
        </ul>
        <!-- Tabs starts -->
        <h1>Departments</h1>
        <div class="form_panel_custom">
            <br />
            <strong><a href="DepartmentAddEdit.aspx?DepartmentId=0">Add Department</a></strong>
            <br /><br />
            <div>
                <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                    <ContentTemplate>
                        <asp:GridView ID="gvDepartmentList" runat="server"
                            Width="100%"
                            ShowHeaderWhenEmpty="true"
                            EmptyDataRowStyle-HorizontalAlign="Center"
                            HeaderStyle-BackColor="Black"
                            HeaderStyle-ForeColor="White"
                            BackColor="White"
                            EmptyDataRowStyle-ForeColor="Black"
                            EmptyDataText="No sub task available!"
                            CssClass="table"
                            CellSpacing="0"
                            CellPadding="0"
                            PageSize="10"
                            AutoGenerateColumns="False"
                            GridLines="Vertical"
                            OnPageIndexChanging="gvDepartmentList_PageIndexChanging"
                            OnRowDataBound="gvDepartmentList_RowDataBound">
                            <Columns>
                                <asp:TemplateField HeaderText="Name" ItemStyle-Width="200px">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdndepid" runat="server" Value='<%#Eval("ID") %>' />
                                        <strong><a href='DepartmentAddEdit.aspx?DepartmentId=<%#Eval("ID") %>'><%# Eval("DepartmentName").ToString()  %></a></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="" ItemStyle-Width="200px">
                                    <ItemTemplate>
                                        <a href='DesignationList.aspx?DepartmentId=<%#Eval("ID") %>'>Designation</a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="50px">
                                    <ItemTemplate>
                                        <asp:DropDownList ID="ddlactive" runat="server">
                                            <asp:ListItem Text="Active" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="Deactive" Value="0"></asp:ListItem>
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <PagerStyle HorizontalAlign="Right" />
                            <EmptyDataRowStyle ForeColor="White" HorizontalAlign="Center" />
                            <HeaderStyle CssClass="trHeader " />
                            <RowStyle CssClass="FirstRow" />
                            <AlternatingRowStyle CssClass="AlternateRow " />
                        </asp:GridView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <br />
        </div>
        <!-- Tabs endss -->
    </div>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
</asp:Content>
