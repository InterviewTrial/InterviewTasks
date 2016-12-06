<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true" CodeBehind="DesignationAddEdit.aspx.cs" Inherits="JG_Prospect.Sr_App.DesignationAddEdit" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Src="~/UserControl/UCAddress.ascx" TagPrefix="uc1" TagName="UCAddress" %>
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
        <h1>Designation</h1>
        <div class="form_panel_custom">
            <ul>
                <li></li>
                <li style="width: 50% !important; border: none !important;">
                    <table border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td>
                                <label>Designation Name<span style="color: red">*</span></label>
                                <asp:TextBox ID="txtDesignationName" TabIndex="1" runat="server" MaxLength="50" Width="250px"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvDesignationName" runat="server" Display="Dynamic" ValidationGroup="Save"
                                    ControlToValidate="txtDesignationName" ErrorMessage="Please enter designation name."
                                    ForeColor="Red"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" TabIndex="2">
                                    <asp:ListItem Text="Active" Value="1" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Deactive" Value="0"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>Department</label>
                                <asp:DropDownList ID="ddlDepartment" runat="server" Width="200px" TabIndex="3">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div class="btn_sec" style="position: relative;">
                                    <asp:Button ID="btnSave" ClientIDMode="Static" runat="server" Text="Save" ValidationGroup="Save" TabIndex="4" OnClick="btnSave_Click" />
                                    <asp:Button ID="btnCancel" ClientIDMode="Static" runat="server" Text="Reset" OnClick="btnCancel_Click" TabIndex="5" />
                                    <%--<asp:Button ID="btnDelete" runat="server" Text="Delete" TabIndex="33" OnClick="btnDelete_Click" OnClientClick="return ConfirmDelete()" />--%>
                                </div>
                            </td>
                        </tr>
                    </table>
                </li>
                <li></li>
            </ul>
        </div>
        <!-- Tabs endss -->
    </div>
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
</asp:Content>

