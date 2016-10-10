<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucStatusChangePopup.ascx.cs" Inherits="JG_Prospect.UserControl.ucStatusChangePopup" %>
<script type="text/javascript">

    function CloseStatusChangePopUp() {
        document.getElementById('StatucsChangePopup').style.display = 'none';
        document.getElementById('interviewDatefade').style.display = 'none';
    }
     
    function showStatusChangePopUp() {

        document.getElementById('StatucsChangePopup').style.display = 'block';
        document.getElementById('interviewDatefade').style.display = 'block';        
        $("html, body").animate({ scrollTop: 0 }, "slow");
    }

</script>

<style>
    .close {
  position: absolute;
  top: 20px;
  right: 30px;
  transition: all 200ms;
  font-size: 30px;
  font-weight: bold;
  text-decoration: none;
  color: #333;
}
</style>


<asp:Panel ID="pnlStatucsChangePopup" runat="server">    
    <div id="StatucsChangePopup" class="white_content" style="height: auto;">
        <a class="close" href="#" onclick="CloseStatusChangePopUp()">&times;</a>
        
        <h3>Status Changed</h3>

        <h2 style="margin-top:25px">
            <i>Soon we are coming up with more functionality...!
            </i>
        </h2>

    </div>
</asp:Panel>
