<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucAuditTrailUpdateUser.ascx.cs" Inherits="JG_Prospect.UserControl.ucAuditTrailUpdateUser" %>

<style>
    .AuditUserData {
        background-color: #dadada;
    } 
        .AuditUserData td {
            padding: 7px 5px;
        }
</style>

<asp:Panel runat="server" ID="pnlAuditUserData">

<div class="AuditUserData">
    <asp:GridView runat="server" ID="grdAuditUserListing"></asp:GridView>
    <asp:ListView ID="lvAuditUserData" runat="server">
    </asp:ListView>
</div>

</asp:Panel>