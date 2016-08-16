<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="InstallerHeader.ascx.cs" Inherits="JG_Prospect.Installer.InstallerHeader" %>
<%@ Register Src="~/Sr_App/Controls/TaskGenerator.ascx" TagPrefix="uc1" TagName="TaskGenerator" %>

<style>
    #divTask
    {
        width:80%;
        height:150px;
    }
     #divTask:hover{
        height:100%;
        position:absolute;
    }
        /*#divTask:hover > nav {
            position:fixed;
        }*/
</style>
<div class="header">
    <img src="../img/logo.png" alt="logo" width="88" height="89" class="logo" />
    <div id="divTask">
        <uc1:TaskGenerator runat="server" id="TaskGenerator" />
    </div>
    <div class="user_panel">
        Welcome! <span>
            <asp:Label ID="lbluser" runat="server" Text="User"></asp:Label>
            <asp:Button ID="btnlogout" runat="server" Text="Logout" CssClass="cancel" ValidationGroup="header" OnClick="btnlogout_Click" />
        </span>&nbsp;<div class="clr">
        </div>
        <ul>
            <li><a href="../Installer/InstallerHome.aspx">Home</a></li>
            <li>|</li>
            <li><a href="../Installer/ChangePassword.aspx">Change Password</a></li>
        </ul>
    </div>
    <div class="nav">
  <ul>
  <li id="Li_Dashboard" runat="server" ><a href="../Installer/InstallerHome.aspx">Dashboard</a></li>
  <li id="Li_sr_app" runat="server" visible="false"><a href="~/Sr_App/home.aspx" runat="server" id="sr_app">Senior App</a></li>  
  </ul>
  </div>
</div>