<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="JG_Prospect.login" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%--<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>--%>
<%--<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <%-- <script type="text/javascript" src="../js/jquery-latest.js"></script>--%>
    <%--  <script type="text/javascript" src="../js/jquery.printElement.min.js"></script>--%>
    <link href="../datetime/css/jquery-ui-1.7.1.custom.css" rel="stylesheet" type="text/css" />
    <link href="../datetime/css/stylesheet.css" rel="stylesheet" type="text/css" />

    <link rel="stylesheet" href="https://code.jquery.com/ui/1.10.2/themes/smoothness/jquery-ui.css" />
    <script src="https://code.jquery.com/jquery-1.9.1.js"></script>
    <script src="https://code.jquery.com/ui/1.10.2/jquery-ui.js"></script>
    <link rel="stylesheet" href="/resources/demos/style.css" />

    <title>JG Prospect</title>
    <link href="css/screen.css" rel="stylesheet" media="screen" type="text/css" />
    <link href="css/jquery.ui.theme.css" rel="stylesheet" media="screen" type="text/css" />

    <%--    <script type="text/javascript"  src="http://code.jquery.com/jquery-latest.js"></script>
    <script type="text/javascript" src="/js/jquery-latest.js"></script>--%>
    <!--accordion jquery-->
    <script type="text/javascript" src="/js/ddaccordion.js"></script>

    <script type="text/javascript">
        $(function () {
            $("#txtDateOfBith").datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: '1950:2050',
                maxDate: 'today'
            });
        });
    </script>
    <%-- <script type="text/javascript">
        $(function () {
            // Tabs
            $('#tabs').tabs();
        });
    </script>--%>

    <style type="text/css">
        .ui-widget-header {
            border: 0;
            background: none /*{bgHeaderRepeat}*/;
            color: #222 /*{fcHeader}*/;
        }

        .auto-style1 {
            width: 100%;
        }

        input[type="radio"] {
            line-height: 20px !important;
            height: 20px;
            float: left;
            margin: 0 5px 0 0 !important;
        }

        input[type="checkbox"] {
            line-height: 20px !important;
            height: 20px;
            float: left;
            margin: 0 5px 0 0 !important;
        }

        label {
            float: left;
        }

        .fg-urs {
            float: left;
            margin: 0 0 0 11em;
        }

        .fg-prs {
            float: left;
            margin: 0 0 0 -1.4em;
        }
    </style>
    <script type="text/javascript">

        function SessionExpire() {
            alert('Your session has expired,login to continue');
        }


    </script>

</head>
<body>
    <form id="form1" runat="server" defaultbutton="btnsubmit">
        <asp:ScriptManager ID="scriptmanager1" runat="server"></asp:ScriptManager>
        <div class="container">
            <!--header section-->
            <div class="header">
                <img src="img/logo.png" alt="logo" width="88" height="89" class="logo" />
            </div>
            <div class="content_panel">
                <table width="100%" cellpadding="1px" cellspacing="1px">
                    <tr>
                        <td width="50%">
                            <div class="login_right_panel" style="min-height: 407px !important; float: right; margin: 0 0 0 0 !important;">
                                <h1><b>Customer Login</b></h1>
                                <div class="login_header" style="margin: -20px 0 0 0 !important;">
                                    <table cellpadding="0" cellspacing="0" style="float: right;">
                                        <tr>
                                            <td style="padding-right: 0px; width: 300px;"></td>
                                            <td style="padding-right: 0px; width: 150px;">
                                                <asp:RadioButton ID="rdCustomer" runat="server" Style="width: 10% !important;" Text="Customer" GroupName="Login" AutoPostBack="true" OnCheckedChanged="rdUserType_CheckedChanged" />
                                                <asp:RadioButton ID="rdSalesIns" runat="server" Style="width: 10% !important;" Text="Staff" GroupName="Login" AutoPostBack="true" OnCheckedChanged="rdUserType_CheckedChanged" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <!-- Tabs starts -->
                                <div id="tabs-1" style="margin: 0 0 0 0 !important;">
                                    <div class="login_form_panel" style="margin: 0 0 0 0 !important;">
                                        <ul>
                                            <li class="last">
                                                <table border="0" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td>
                                                            <label>Login Id<span>*</span></label>
                                                            <asp:TextBox ID="txtloginid" runat="server" TabIndex="1" Width="312px" placeholder="Enter email address or phone number"></asp:TextBox>
                                                            <br />
                                                            <label></label>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ValidationGroup="Login"
                                                                ControlToValidate="txtloginid" Display="Dynamic" ForeColor="Red">Please Enter UserName</asp:RequiredFieldValidator><br />
                                                            &nbsp; 
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Password<span>*</span></label>
                                                            <asp:TextBox ID="txtpassword" runat="server" TextMode="Password" TabIndex="2" Width="311px" placeholder="Password"></asp:TextBox>
                                                            <br />
                                                            <label></label>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ValidationGroup="Login"
                                                                ControlToValidate="txtpassword" ForeColor="Red" Display="Dynamic">Please Enter Password</asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding-bottom: 2px !important; background: none !important;">
                                                            <asp:CheckBox ID="chkRememberMe" Style="width: 4% !important; margin-left: -1px !important;" Text="  Remember Me" runat="server" />
                                                            <div class="btn_sec" style="width: 44% !important; float: left !important; margin-top: -2% !important; margin-left: -6% !important; height: 60px !important;">
                                                                <asp:Button ID="btnsubmit" runat="server" Text="Login" OnClick="btnsubmit_Click" Style="width: 98% !important; height: 67% !important;" ValidationGroup="Login" TabIndex="3" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding-top: 0px !important;">
                                                            <label></label>
                                                            <asp:LinkButton ID="lnkForgotUsername" runat="server" OnClick="lblForgotUserId_Click">Forgot Username</asp:LinkButton>
                                                            &nbsp;<asp:LinkButton ID="lnkForgotPassword" runat="server" OnClick="lnkForgotPassword_Click">Forgot Password</asp:LinkButton>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <b>One Touch Login</b>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/img/22222.png" OnClick="ImageButton1_Click" Width="30%" />
                                                            <asp:ImageButton ID="ImageButton2" runat="server" ImageUrl="~/img/33333.png" OnClick="ImageButton2_Click" Width="30%" />&nbsp;<asp:ImageButton ID="ImageButton3" runat="server" ImageUrl="~/img/4444.png" Width="30%" OnClick="ImageButton3_Click" />&nbsp;
                                                            <asp:ImageButton ID="ImageButton4" runat="server" ImageUrl="~/img/yahoologin.png" OnClick="ImageButton4_Click" Width="30%" />&nbsp;<asp:ImageButton ID="ImageButton5" runat="server" ImageUrl="~/img/microsoftlogin.png" Width="30%" OnClick="ImageButton5_Click" />&nbsp;
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td style="border: 0px solid #808080; background-color: #000000;"></td>
                        <td width="50%">
                            <div class="login_right_panel" style="min-height: 407px !important; float: left; margin: 0 0 0 0 !important; background-color: #EFEEEE">
                                <h1><b>Customer Sign Up</b></h1>
                                <div class="login_header" style="margin: -20px 0 0 0 !important;">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td style="padding-right: 0px; width: 300px;"></td>
                                        </tr>
                                    </table>
                                </div>
                                <div id="tabs-2" style="margin: 0 0 0 0 !important;">
                                    <div class="login_form_panel" style="margin: 0 0 0 0 !important;">
                                        <ul>
                                            <li>
                                                <table border="0" cellspacing="0" cellpadding="0">
                                                    <tr style="display: none !important">
                                                        <td style="padding-right: 0px; width: 30px;"></td>
                                                        <td style="padding-right: 0px;">
                                                            <label style="width: 42% !important;">Customer Sign Up &nbsp;&nbsp;&nbsp;   User Type<span>*</span></label>
                                                            <asp:RadioButton ID="rdoCustomer" GroupName="Signup" runat="server" Style="width: 10% !important;" Checked="true" />

                                                            <label style="width: 13% !important;">Customer</label><div style="display: none !important">
                                                                <asp:RadioButton ID="rdoEmp" GroupName="Signup" runat="server" Text="Employee" Style="width: 15% !important;" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Email<span style="color: red">*</span></td>
                                                        <td>
                                                            <asp:TextBox ID="txtSignupEmail" MaxLength="100" runat="server" Width="258px" placeholder="Username"></asp:TextBox>
                                                            <br />
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" Display="Dynamic" runat="server" ControlToValidate="txtSignupEmail" ValidationGroup="SignUp" ErrorMessage="Enter email id." ForeColor="Red"></asp:RequiredFieldValidator>
                                                            <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ControlToValidate="txtSignupEmail" Display="Dynamic" ErrorMessage="Enter valid email id." ForeColor="Red" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ValidationGroup="SignUp"></asp:RegularExpressionValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Phone No.</td>
                                                        <td>
                                                            <asp:TextBox ID="txtPhoneNumber" runat="server" Width="258px" MaxLength="15" placeholder="Phone number"></asp:TextBox>
                                                            <br />
                                                            <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator6" Display="Dynamic" runat="server" ControlToValidate="txtPhoneNumber" ValidationGroup="SignUp" ErrorMessage="Enter phone number." ForeColor="Red"></asp:RequiredFieldValidator>--%>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Password<span style="color: red">*</span></td>
                                                        <td>
                                                            <asp:TextBox ID="txtSignupPassword" runat="server" Width="258px" MaxLength="20" TextMode="Password" placeholder="Enter password"></asp:TextBox>
                                                            <br />
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ForeColor="Red" runat="server" ControlToValidate="txtSignupPassword" ErrorMessage="Enter password." ValidationGroup="SignUp" Display="Dynamic"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Confirm Password<span style="color: red">*</span></td>
                                                        <td>
                                                            <asp:TextBox ID="txtSignupCPassword" runat="server" TextMode="Password" Width="258px" placeholder="Confirm password"></asp:TextBox>
                                                            <br />
                                                            <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToCompare="txtSignupPassword" ControlToValidate="txtSignupCPassword" Display="Dynamic" ErrorMessage="Password &amp; confirm password should be same." ForeColor="Red" ValidationGroup="SignUp"></asp:CompareValidator>
                                                            <br />
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="txtSignupCPassword" Display="Dynamic" ErrorMessage="Enter confirm password" ForeColor="Red" ValidationGroup="SignUp"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        </ul>
                                        <div class="btn_sec">
                                            <asp:Button ID="btnSignUp" runat="server" Text="Sign Up" ValidationGroup="SignUp" OnClick="btnSignUp_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
                <%-- <div id="tabs">
                    <div id="tabs-2"></div>
                </div>--%>
                <!-- Tabs endss -->
            </div>
            <%--<asp:Button ID="Button1" Style="display: none;" runat="server" Text="Button" />
            <cc1:ModalPopupExtender ID="forgotpassword" runat="server" PopupControlID="Panel1" TargetControlID="Button1"
                CancelControlID="btnSubForgotPassword" BackgroundCssClass="modalBackground">
            </cc1:ModalPopupExtender>
            <asp:Panel ID="Panel1" runat="server" CssClass="modalPopup" align="center" Style="display: none">
                <table>
                    <tr>
                        <td>Enter Login Id
                        </td>
                        <td>
                            <asp:TextBox ID="txtFPEmail" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Button ID="btnSubForgotPassword" Style="background: url(../img/btn.png) no-repeat; width: 200px; height: 39px;" runat="server" Text="Submit" OnClick="btnSubForgotPassword_Click" />
                        </td>
                    </tr>
                </table>
                <br />
            </asp:Panel>
            <asp:Button ID="Button2" Style="display: none;" runat="server" Text="Button" />
            <cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server" PopupControlID="Panel2" TargetControlID="Button2"
                CancelControlID="btnClose" BackgroundCssClass="modalBackground">
            </cc1:ModalPopupExtender>
            <asp:Panel ID="Panel2" runat="server" CssClass="modalPopup" align="center" Style="display: none">
                <table>
                    <tr>
                        <td>Enter Login Id
                        </td>
                        <td>
                            <asp:TextBox ID="txtPhoneNo" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Button ID="btnForgotEmail" Style="background: url(../img/btn.png) no-repeat; width: 200px; height: 39px;" runat="server" Text="Submit" OnClick="btnForgotEmail_Click" />
                        </td>
                    </tr>
                </table>
                <br />
            </asp:Panel>--%>
        </div>

        <!--footer section-->
        <div class="footer_panel">
            <ul>
                <li>&copy; 2012 JG All Rights Reserved.</li>
                <li><a href="#">Terms of Use</a></li>
                <li>|</li>
                <li><a href="#">Privacy Policy</a></li>
            </ul>
        </div>
    </form>
</body>

</html>

