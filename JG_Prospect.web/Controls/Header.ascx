<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="JG_Prospect.Controls.Header" %>
<%@ Register Src="~/Sr_App/Controls/TaskGenerator.ascx" TagPrefix="uc1" TagName="TaskGenerator" %>
<!--tabs jquery-->
<script type="text/javascript" src="/js/jquery.ui.core.js"></script>
<%--<script type="text/javascript" src="/js/jquery.ui.widget.js"></script>--%>
<!--tabs jquery ends-->













<script type="text/javascript">
    $(function () {
        // Tabs
        $('#tabs').tabs();
    });
		</script>
<style type="text/css">
.ui-widget-header {
	border: 0;
	background:none/*{bgHeaderRepeat}*/;
	color: #222/*{fcHeader}*/;
}
</style>
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
     .ProfilImg {
        left: 1px;
        top: 47px;        
        position: absolute;
        margin-left:-40px;
        width: 181px;
    }
    .img-Profile {
        border-radius: 50%;
        width: 77px;
        height: 76px;
    }
    .ProfilImg .caption {
        opacity: 0;
        position: absolute;
        height: 28px;
        width: 75px;
        bottom: 0px;        
        padding: 2px 0px;
        color: #ffffff;
        background: #1f211f;
        text-align: center;
        font-weight: bold;
    }
    .ProfilImg:hover .caption {
        opacity: 0.6;
    }
        /*#divTask:hover > nav {
            position:fixed;
        }*/
</style>

<div class="header">
  <img src="img/logo.png" alt="logo" width="88" height="89" class="logo" />
    <div id="divTask">
        <uc1:TaskGenerator runat="server" id="TaskGenerator" />
    </div>
  <div class="user_panel">
  Welcome! <span>
  <asp:Label ID="lbluser" runat="server" Text="User"></asp:Label>
  <asp:Button ID="btnlogout" runat="server" Text="Logout" onclick="btnlogout_Click" 
      />
      </span> 
  &nbsp;<div class="clr"></div>
	<ul> 
    <li id="Lihome" runat="server" ><a href="<%= Page.ResolveUrl("~/home.aspx")%>">Home</a></li>
    <li>|</li>
    <li><a href="<%= Page.ResolveUrl("~/changepassword.aspx")%>">Change Password</a></li>
    </ul>
      <div class="ProfilImg" >
            <asp:Image CssClass="img-Profile" ID="imgProfile" runat="server" />
            <asp:HyperLink runat="server" ID="hLnkEditProfil" Text="Edit"></asp:HyperLink>
            <a href="#"><div class="caption">Edit</div></a>
        </div>
  </div>
  <!--nav section-->
  <div class="nav">
  <ul>
  <li id="Lidashboard" runat="server" ><a href="<%= Page.ResolveUrl("~/home.aspx")%>">Dashboard</a></li>
  <%--<li id="Lidefineperiod" runat="server" visible="false"><a href="/DefinePeriod.aspx">Pay Schedule</a></li>--%>
      <li id="Lidefineperiod" runat="server" visible="false"><a href="<%= Page.ResolveUrl("~/DefinePeriod.aspx")%>">Pay Schedule</a></li>
    
  <li ><a href="<%= Page.ResolveUrl("~/Prospectmaster.aspx")%>">Add/Update Prospect</a></li>
  <li id="LiUploadprospect" runat="server"><a href="<%= Page.ResolveUrl("~/upload.aspx")%>">Upload Prospects</a></li>
  <%--<li id="Licreateuser" runat="server" visible="false"><a href="/CreateUser.aspx">Create User</a></li>
  <li id="Liedituser" runat="server" visible="false" ><a href="/EditUser.aspx" runat="server" id="edituser">Edit User</a></li>--%>
  <%--<li><a href="<%= Page.ResolveUrl("~/Leads_summaryreport.aspx")%>" runat="server" id="Summaryreport">Prospect List</a></li>--%>
      <li><a href="<%= Page.ResolveUrl("~/Leads_summaryreport.aspx")%>">Prospect List</a></li>
  <%--<li id="Liprogress" runat="server" visible="true"><a href="<%= Page.ResolveUrl("~/ProgressReport.aspx")%>" runat="server" id="ProgressReport">Progress Report</a></li>--%>
       <li id="Liprogress" runat="server" visible="true"><a href="<%= Page.ResolveUrl("~/ProgressReport.aspx")%>">Progress Report</a></li>

  <%--<li id="Li_AssignProspect" runat="server" visible="true">--%><%--<a href="/AssignProspect.aspx" runat="server" id="AssignProspect">Assign Customer</a>--%></li>
  <%--<li id="Li_sr_app" runat="server" visible="false"><a href="<%= Page.ResolveUrl("~/Sr_App/home.aspx")%>" runat="server" id="sr_app">Senior App</a></li>  --%>
      <li id="Li_sr_app" runat="server" visible="false"><a href="<%= Page.ResolveUrl("~/Sr_App/home.aspx")%>">Senior App</a></li>  
    <%--<li id="Li1" runat="server" visible="true"><a href="~/Sr_App/ConstructionCalendar.aspx" runat="server" id="A1">Old Calendar</a></li>--%>  
 </ul>
  </div>
</div>