<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucStaffLoginAlert.ascx.cs" Inherits="JG_Prospect.UserControl.PopUp.ucStaffLoginAlert" %>

<script type="text/javascript" >

    var $ = jQuery.noConflict();
    
    function CloseStaffLoginPopUp() {
        document.getElementById('StaffLoginAlert').style.display = 'none';
        document.getElementById('StaffLoginAlertfade').style.display = 'none';
    }
     
    function showStaffLoginPopUp() {

        document.getElementById('StaffLoginAlert').style.display = 'block';
        document.getElementById('StaffLoginAlertfade').style.display = 'block';
        $("html, body").animate({ scrollTop: 0 }, "slow");
    }

    function ucClosePopupInterviewDate() {
        alert('111');
        document.getElementById('ucInterviewDatelite').style.display = 'none';
        alert('111222');
        document.getElementById('UcInterivewDtl').style.display = 'none';
        alert('11122233');
    }

    function ucoverlayInterviewDate() {
        alert('22');
        document.getElementById('ucInterviewDatelite').style.display = 'block';
        document.getElementById('UcInterivewDtl').style.display = 'block';
        //$("html, body").animate({ scrollTop: 0 }, "slow");
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
    .lblMsg{
        font-weight: 800;
    font-style: italic;
    font-size: initial
    }

    table tr th {
        border: 1px solid;
        padding: 0px;
    }

    table.table tr.trHeader {
        background: #000000;
        color: #ffffff;
    }

    .FirstRow {
        background: #f57575;
        padding: 2px;
    }

    .AlternateRow {
        background: #f6f1f3;
        padding: 2px;
    }

    .dark-gray-background {
        background-color: darkgray;
        background-image: none;
    }

    .AlternateRow a, .FirstRow a {
        color: #111;
    }

    .white_contentuC {
            display: none;
            position: absolute;
            top: 5%;
            left: 20%;
            width: 60%;
            height: 5%;
            padding: 16px;
            border: 10px solid #327FB5;
            background-color: white;
            z-index: 1002;
            overflow: auto;
        }
</style>


<asp:Panel ID="pnlStaffLoginAlert" runat="server">
    <div id="StaffLoginAlert" class="white_content" style="border:none; text-align:center; height: auto; background: #efeeee url(../img/form-bg.png) repeat-x top; min-height: 150px;">
        <a class="close" href="#" onclick="CloseStaffLoginPopUp()">&times;</a>
        <h1>Alert</h1>
        <div id="divMsg" style="text-align:left;margin-top:10px;margin-bottom:10px;">
            <div>Alert Note:</div>
            <br />
            <asp:Label CssClass="lblMsg" Text="Personal Alert Message after Login.....!" ID="lblAlertMsg" runat="server" />
            
        </div>
        
        <hr />
        <br />
        <div class="grid">
            <center>
                 <asp:UpdatePanel ID="upUsers" runat="server">
                    <ContentTemplate>
                <asp:GridView ID="grdUsers" CssClass="tableClass" runat="server"  AutoGenerateColumns="False" DataKeyNames="Id" AllowSorting="true" 
                    OnRowDataBound="grdUsers_RowDataBound"
                    EmptyDataText="No Data">
                    <Columns>
                       <%-- <asp:TemplateField HeaderText="Action" ControlStyle-Width="40px">
                            <ItemTemplate>
                                <asp:LinkButton ID="lbltest" Text="Edit" CommandName="Edit" runat="server"
                                    CommandArgument='<%#Eval("Id")%>'></asp:LinkButton>
                                <br />
                                <asp:LinkButton ID="lnkDelete" Text="Delete" CommandName="Delete" runat="server" OnClientClick="return confirm('Are you sure you want to delete this record?')"
                                    CommandArgument='<%#Eval("Id")%>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>--%>

                        <asp:TemplateField ShowHeader="True"  HeaderText="Id# <br /> Designation" ControlStyle-ForeColor="Black"
                            ItemStyle-HorizontalAlign="Center" Visible="true" ControlStyle-Width="100px">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtid" runat="server" MaxLength="30" Text='<%#Eval("Id")%>'></asp:TextBox>
                                
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblid" Visible="false" runat="server" Text='<%#Eval("Id")%>'></asp:Label>
                                <a href="/Sr_App/CreateSalesUser.aspx?id=<%#Eval("Id")%>" target="_blank"> <%#Eval("Id")%></a>                                
                                <br />
                                <asp:Label ID="lblDesignation" runat="server" Text='<%#Eval("Designation")%>'></asp:Label>
                            </ItemTemplate>
                            <ControlStyle ForeColor="Black" />
                            <ControlStyle ForeColor="Black" />
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>

                        <asp:TemplateField ShowHeader="True" HeaderText="Install Id" Visible="false" ControlStyle-ForeColor="Black"
                            ItemStyle-HorizontalAlign="Center">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtInstallid" runat="server" MaxLength="30" Text='<%#Eval("InstallId")%>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblInstallid" runat="server" Text='<%#Eval("InstallId")%>'></asp:Label>
                            </ItemTemplate>
                            <ControlStyle ForeColor="Black" />
                            <ControlStyle ForeColor="Black" />
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Picture" Visible="false" SortExpression="picture">
                            <ItemTemplate>
                                <asp:LinkButton ID="lbtnPicture" Text="Picture" CommandName="ShowPicture" runat="server"
                                    CommandArgument='<%#Eval("picture")%>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ShowHeader="True" HeaderText="First Name<br />Last Name" ControlStyle-ForeColor="Black"
                            ItemStyle-HorizontalAlign="Center" >
                            <EditItemTemplate>
                                <asp:TextBox ID="txtFirstName" runat="server" MaxLength="30" Text='<%#Eval("FristName")%>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblFirstName" runat="server" Text='<%#Eval("FristName")%>'></asp:Label>
                                <br />
                                <asp:Label ID="lblLastName" runat="server" Text='<%# Bind("Lastname") %>'></asp:Label>
                                
                            </ItemTemplate>
                            <ControlStyle ForeColor="Black" />
                            <ControlStyle ForeColor="Black" />
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Last name" Visible="false"  ItemStyle-HorizontalAlign="Center">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtlastname" runat="server" Text='<%# Bind("Lastname") %>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Designation" Visible="false" ItemStyle-HorizontalAlign="Center">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtDesignation" runat="server" Text='<%#Eval("Designation")%>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status </br> Interview On" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="90px">
                            <ItemTemplate>
                                <asp:HiddenField ID="lblStatus" runat="server" Value='<%#Eval("Status")%>'></asp:HiddenField>
                                
                                <asp:DropDownList ID="ddlStatus" AutoPostBack="true" OnSelectedIndexChanged="grdUsers_ddlStatus_SelectedIndexChanged" runat="server" DataValueField='<%#Eval("Status")%>'>
                                    <asp:ListItem Text="Applicant" Value="Applicant"></asp:ListItem><asp:ListItem Text="Phone/Video Screened" Value="PhoneScreened"></asp:ListItem>
                                    <asp:ListItem Text="Rejected" Value="Rejected"></asp:ListItem>
                                    <asp:ListItem Text="Interview Date" Value="InterviewDate"></asp:ListItem>
                                    <asp:ListItem Text="ReSchedule" Value="Re-Schedule"></asp:ListItem>
                                    <asp:ListItem Text="Offer Made" Value="OfferMade"></asp:ListItem>
                                    <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                                    <asp:ListItem Text="Deactive" Value="Deactive"></asp:ListItem>
                                    <asp:ListItem Text="Install Prospect" Value="Install Prospect"></asp:ListItem>
                                </asp:DropDownList><br />                                
                                <asp:Label ID="lblInterviewDetail" runat="server" Text='<%#Eval("InterviewDetail") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Source <hr/> Added By - On"  ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:Label ID="lblSource" runat="server" Text='<%#Eval("Source")%>'></asp:Label>
                                <hr />
                                <asp:Label ID="lblAddedBy" runat="server" Text='<%#Eval("AddedBy")%>'></asp:Label>
                                <br />
                                <asp:Label ID="lblHireDate" runat="server" Text='<%#Eval("CreatedDateTime")%>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <%--<asp:TemplateField HeaderText="Added On" Visible="false" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>--%>
                      <%--  <asp:TemplateField HeaderText="Source" ItemStyle-HorizontalAlign="Center" ControlStyle-Width="80px" ControlStyle-CssClass="wordBreak">
                            <ItemTemplate>
                                
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>--%>
                        <asp:TemplateField HeaderText="Phone, e-mail <br> skype/Other" ItemStyle-HorizontalAlign="Center"  ControlStyle-CssClass="wordBreak">
                            <ItemTemplate>
                                <asp:Label ID="lblPhone" runat="server" Text='<%# Bind("Phone") %>'></asp:Label>
                                <br />
                                <asp:Label ID="lblEmail" runat="server" Text='<%# Bind("Email") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                    </Columns>
                </asp:GridView> 
                 </ContentTemplate>
                </asp:UpdatePanel>
                </center>
        </div>
     </div>
</asp:Panel>

<!---- Interview Details --- START -->

<asp:Panel ID="pnlucInterviewDate" runat="server">
<div id="ucInterviewDatelite" class="white_contentuC" runat="server" style="height: auto;">
            <h3>Interview Details
            </h3>
            <%--<a href="javascript:void(0)" onclick="">Close</a>--%>
            <asp:UpdatePanel runat="server" UpdateMode="Always">
                <ContentTemplate>
                    <asp:Label ID="lblTest" Text="StillNotCall"></asp:Label>
                    55555555
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
</asp:Panel>
<!---- Interview Details --- END -->

<div id="StaffLoginAlertfade" class="black_overlay">
    </div>

<div id="UcInterivewDtl" class="black_overlay">
    </div>
