<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomPager.ascx.cs" Inherits="JG_Prospect.Controls.CustomPager" %>

<asp:Repeater ID="rptPager" runat="server">
    <ItemTemplate>
        <asp:LinkButton ID="lnkPage" runat="server" CssClass='<%# Convert.ToBoolean(Eval("Enabled")) ? "page_enabled" : "page_disabled" %>'
            Text='<%#Eval("Text") %>' CommandArgument='<%# Eval("Value") %>'
            OnClientClick='<%# !Convert.ToBoolean(Eval("Enabled")) ? "return false;" : "" %>'
            OnClick="Page_Changed" ClientIDMode="AutoID" Style="margin: 5px;" />
    </ItemTemplate>
</asp:Repeater>
