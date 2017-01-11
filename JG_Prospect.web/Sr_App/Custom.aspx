<%@ Page Title="" Language="C#" MasterPageFile="~/Sr_App/SR_app.Master" AutoEventWireup="true"
    CodeBehind="Custom.aspx.cs" Inherits="JG_Prospect.Sr_App.Product_Line.Custom" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Src="~/UserControl/UCAddress.ascx" TagPrefix="uc1" TagName="UCAddress" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript" src="http://code.jquery.com/jquery-1.8.2.js"></script>
    <script src="../js/jquery-latest.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../Scripts/jquery.MultiFile.js"></script>
    <script src="../js/PrimaryContact.js" type="text/javascript"></script>
    <script type="text/javascript">
        function uploadComplete() {

            if (Checkfiles() == true) {
                var btnImageUploadClick = document.getElementById("ctl00_ContentPlaceHolder1_btnImageUploadClick");
                btnImageUploadClick.click();
            }
        }
        function uploadComplete2() {


            var btnImageUploadClick = document.getElementById("ctl00_ContentPlaceHolder1_btnImageUploadClick");
            btnImageUploadClick.click();

        }
        function Checkfiles() {

            var fup = document.getElementById('ctl00_ContentPlaceHolder1_ajaxFileUpload_ctl02');
            var fileName = fup.value;
            var ext = fileName.substring(fileName.lastIndexOf('.') + 1).toString().toLowerCase();
            if (ext == "gif" || ext == "jpeg" || ext == "jpg" || ext == "tiff" || ext == "tif" || ext == "bmp" || ext == "png") {
                if ($('#ContentPlaceHolder1_hidCount').val().length != 0) {
                    if (parseInt($('#ContentPlaceHolder1_hidCount').val()) == 5) {
                        alert('You can not upload more than five image.');
                        $('#ctl00_ContentPlaceHolder1_ajaxFileUpload_ctl02').val('');
                        fup.focus();
                        return false;
                    }
                }
                return true;
            }
            else {
                alert('Upload Gif,JPG,JPEG,TIFF,TIF,PNG and BMP images only');
                $('#ctl00_ContentPlaceHolder1_ajaxFileUpload_ctl02').val('');
                fup.focus();
                return false;
            }
        }
        function readURL(input) {
            debugger;
            var fileExtension = ['jpeg', 'jpg', 'png', 'gif', 'bmp'];
            if ($.inArray($(input).val().split('.').pop().toLowerCase(), fileExtension) == -1) {
                alert("Invalid formats are not allowed.");
                $(input).val("");
                return false;
            }
        }
        $(document).ready(function () {
            //$('#ContentPlaceHolder1_txtworkarea').focus();
            BindPrimaryContact();
        });
        function ValidateImage() {
            var count = $('#<%=hidCount.ClientID %>').val();
            //alert(count);
            if (count < 2) {
                alert('Upload atleast two image.');
                return false;
            }
        }
        function IsExists(pagePath, dataString, textboxid, errorlableid) {
            $.ajax({
                type: "POST",
                url: pagePath,
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                error:
          function (XMLHttpRequest, textStatus, errorThrown) {
              $(errorlableid).show();
              $(errorlableid).html("Error");
          },
                success:
          function (result) {
              if (result != null) {
                  var flg = (result.d);

                  if (flg == "True") {
                      $(errorlableid).show();
                      $(errorlableid).html('Verified');
                      document.getElementById('<%=txtProposalCost.ClientID %>').value = document.getElementById('<%=txtAmount.ClientID %>').value;
                      $('#mask').hide();
                      $('#<%=pnlpopup.ClientID %>').hide();
                  }
                  else {
                      $(errorlableid).show();
                      $(errorlableid).html('failure');
                  }
              }
          }
            });
  }

  function focuslost() {
      if (document.getElementById('<%= txtAmount.ClientID%>').value == '') {
          alert('Please enter proposal cost!');
          return false;
      }
      else if (document.getElementById('<%= txtauthpass.ClientID%>').value == '') {
          alert('Please enter admin code!');
          return false;
      }
      else {
          var pagePath = "Custom.aspx/Exists";
          var dataString = "{ 'value':'" + document.getElementById('<%= txtauthpass.ClientID%>').value + "' }";
          var textboxid = "#<%= txtauthpass.ClientID%>";
          var errorlableid = "#<%= lblError.ClientID%>";

          IsExists(pagePath, dataString, textboxid, errorlableid);
          return true;
      }
}
function ShowPopup() {
    $('#ContentPlaceHolder1_txtProposalCost').attr('readonly', 'readonly');
    $('#ContentPlaceHolder1_txtAmount').focus();
    if (document.getElementById('<%=txtProposalCost.ClientID %>').value != '') {
        document.getElementById('<%=txtAmount.ClientID %>').value = document.getElementById('<%=txtProposalCost.ClientID %>').value;
    }
    $('#mask').show();
    $('#<%=pnlpopup.ClientID %>').show();
}
function HidePopup() {
    $('#ContentPlaceHolder1_txtAmount, #ContentPlaceHolder1_txtauthpass').val('');
    $('#ContentPlaceHolder1_lblError').text('');

    $('#mask').hide();
    $('#<%=pnlpopup.ClientID %>').hide();
}
$(".btnClose").live('click', function () {
    $('#<%=txtAmount.ClientID %>, #<%=txtauthpass.ClientID %>, #<%=lblError.ClientID %>').val('');

    HidePopup();
});






    </script>
    <style type="text/css">
        .style2 {
            width: 100%;
        }

        #mask {
            position: fixed;
            left: 0px;
            top: 0px;
            z-index: 4;
            opacity: 0.4;
            -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=40)"; /* first!*/
            filter: alpha(opacity=40); /* second!*/
            background-color: gray;
            display: none;
            width: 100%;
            height: 100%;
        }

        .cls_btn_plus {
            background-color: RGBA(182,74,76,1);
            color: #fff;
            font-weight: bold;
            font-size: 14px;
            box-shadow: 0 0 15px #a1a0a0;
            cursor: pointer;
            border: 2px solid !important;
            border-radius: 6px;
            /* margin-bottom: 4px!important; */
            height: 27px;
            padding-right: 2px !important;
        }

        .form_panel_custom ul li table tr td {
            padding: 0px !important;
        }

        input[type=text], input[type=password], input[type=url], input[type=email], input.text, input.title, textarea, select {
            padding: 5px;
            border-radius: 5px;
            border: #b5b4b4 1px solid;
            margin-left: 0;
            margin-right: 0;
            margin-bottom: 0;
            background-color: #fff;
            border-bottom-left-radius: 5px;
            border-bottom-right-radius: 5px;
            border-bottom-style: solid;
            border-bottom-width: 1px;
        }

        /*CollapsiblePanelExtender
        .cpHeader {
            color: white;
            background-color: #719DDB;
            font: bold 11px auto "Trebuchet MS", Verdana;
            font-size: 12px;
            cursor: pointer;
            width: 450px;
            height: 18px;
            padding: 4px;
        }

        .cpBody {
            background-color: #DCE4F9;
            font: normal 11px auto Verdana, Arial;
            border: 1px gray;
            width: 450px;
            padding: 4px;
            padding-top: 7px;
        }*/
    </style>

    <script src="../Scripts/jquery.maskedinput.min.js" type="text/javascript"></script>
    <%--<script src="../Scripts/dropDownlistDiv.js" type="text/javascript"></script>--%>
    <script src="../Scripts/jquery.webui-popover.min.js" type="text/javascript"></script>
    <script src="../Scripts/pgwslideshow.min.js" type="text/javascript"></script>
       
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
        <h1 id="h1Heading" runat="server"></h1>
        <div class="form_panel_custom" id="customDiv">
            <span>
                <label>
                    Customer Id:
                </label>
                <b><a onclick="window.open('Customer_Profile.aspx?CustomerId=' + '<%= vCustomerId %>','name','height=550, width=790,toolbar=no,directories=no,status=no, menubar=no,scrollbars=yes,resizable=yes'); return false;" href='#'>
                    <asp:Label ID="lblmsg" runat="server" Visible="true"></asp:Label> </a>
                    <a onclick="window.open('Customer_Profile.aspx?CustomerId=' + '<%= vCustomerId %>','name','height=550, width=790,toolbar=no,directories=no,status=no, menubar=no,scrollbars=yes,resizable=yes'); return false;" href='#'>
                    <asp:Label ID="lblQuote" runat="server" Visible="true"></asp:Label>
                   </a>
                    
                </b>

            </span></br></br>
             <table style="width: 100%; padding: 0px;" border="0" cellspacing="0" cellpadding="0">
                 
                 <tr>
                     <td>
                         <span>
                             <label>
                                 *Check Primary Contact 
                             </label>
                         </span>
                     </td>
                 </tr>
                 <tr>
                     <td>
                         <div style="width: 100%; overflow-x: hidden;" id="divPrimaryContact">
                             <ul style="overflow-x: hidden;">
                                 <li></li>
                             </ul>
                         </div>
                     </td>
                 </tr>
                 <tr>
                     <td>
                         <table border="0" cellspacing="0" cellpadding="0">
                             <tr>
                                 <td style="vertical-align: top;">
                                     <uc1:UCAddress runat="server" ID="UCAddress" />
                                 </td>
                                 <td style="vertical-align: top;">
                                     
                                     <table >
                                         <tr>
                                             <td colspan="2">
                                                 <input type="checkbox" id="chkbillingaddress" style="width: 5%" tabindex="20" checked="checked" onchange="BillingAddress(this)" />
                                             </td>
                                         </tr>
                                         <tr>
                                             <td valign="top">Billing Address Same</td>
                                             <td>
                                                  <textarea id="txtbill_address" runat="server" clientidmode="Static" name="BillAddress" style="width: 169px;" tabindex="21"></textarea>
                                             </td>
                                         </tr>
                                         <tr>
                                             <td  valign="top">Address Type</td>
                                             <td>
                                                 <select id="selAddressType" name="AddressType" runat="server" clientidmode="Static">
                                                     <option value="Select">Select</option>
                                                     <option value="Primary Residence">Primary Residence</option>
                                                     <option value="Business">Business</option>
                                                     <option value="Vacation House">Vacation House</option>
                                                     <option value="Rental">Rental</option>
                                                     <option value="Condo">Condo</option>
                                                     <option value="Apartment">Apartment</option>
                                                     <option value="Mobile Home">Mobile Home</option>
                                                     <option value="Other">Other</option>
                                                 </select>
                                             </td>
                                         </tr>
                                         <tr>
                                             <td>
                                                 <table border="0" cellspacing="0" style="width: 100%" cellpadding="0">
                                                     <tr>
                                                         <td style="width: 41%;">&nbsp;</td>
                                                         <td style="text-align: left;">
                                                             <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                                                 <ContentTemplate>
                                                                     <asp:Button ID="btnAddAddress" runat="server" Text="Add Address" Width="110px" CssClass="cls_btn_plus" TabIndex="31"
                                                                         OnClick="btnAddAddress_Click" />
                                                                 </ContentTemplate>
                                                             </asp:UpdatePanel>
                                                         </td>
                                                     </tr>
                                                 </table>
                                             </td>
                                         </tr>
                                     </table>
                                     
                                 </td>
                                 <td style="vertical-align: top;">
                                      <asp:UpdatePanel ID="panel4" runat="server">
                                         <ContentTemplate>
                                             <asp:PlaceHolder runat="server" ID="myPlaceHolder"></asp:PlaceHolder>
                                         </ContentTemplate>
                                         <Triggers>
                                             <asp:AsyncPostBackTrigger ControlID="btnAddAddress" />
                                         </Triggers>
                                     </asp:UpdatePanel>
                                 </td>
                             </tr>
                         </table>
                     </td>
                 </tr>
                 
                 <tr>
                     <td>
                         <br />
                         <br />
                          <!-- ------------ Start DP 22-Dec-2016 ----------- -->
                         <%--<table border="0" cellspacing="0" style="width: 100%" cellpadding="0">
                             <tr>
                                 <td style="width: 53%; vertical-align: top;">
                                     <asp:UpdatePanel ID="up" runat="server">
                                         <ContentTemplate>
                                             <table id="Table1" runat="server" border="0" cellspacing="0" cellpadding="0">
                                                 <tr>
                                                     <td>
                                                         <label>
                                                             Select Product Category: <span>*</span></label>
                                                         <asp:DropDownList ID="ddlProductCategory" runat="server" Width="200px" AutoPostBack="true"
                                                             TabIndex="2" OnSelectedIndexChanged="ddlProductCategory_SelectedIndexChanged">
                                                         </asp:DropDownList>
                                                         <asp:TextBox ID="txtOther" runat="server" Width="120" Visible="false"></asp:TextBox>
                                                         <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ValidationGroup="Add"
                                                             ErrorMessage="Please Select Product Category." InitialValue="0" ControlToValidate="ddlProductCategory"
                                                             ForeColor="Red"></asp:RequiredFieldValidator>
                                                     </td>
                                                 </tr>
                                             </table>
                                         </ContentTemplate>
                                         <Triggers>
                                             <asp:AsyncPostBackTrigger ControlID="ddlProductCategory" EventName="SelectedIndexChanged" />
                                         </Triggers>
                                     </asp:UpdatePanel>
                                 </td>
                                 <td style="vertical-align: top;">
                                     <div>
                                         <asp:Button ID="btnAddProductCategory" runat="server" CssClass="cls_btn_plus" Text="Add Product Category" ValidationGroup="Add"
                                             TabIndex="3" OnClick="btnAddProductCategory_Click" />
                                        <a href="#">Clear/Delete</a>
                                     </div>
                                 </td>
                             </tr>
                         </table>--%>


                         <table id="Table1" runat="server" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <br />
                                        <br />
                                       
                                       
                                        <table id="tblAddmore" runat="server">
                                            <tr>
                                                <td>
                                                    <input type="button" ID="btnexpand"  runat="server" class="cls_btn_plus" value=" - " />
                                                    Select Product Category
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlProductCategory"   runat="server" Width="200px"  TabIndex="2" >
                                                    </asp:DropDownList>
                                                    <asp:TextBox ID="txtOther" runat="server" Width="120"  ></asp:TextBox>
                                                </td>
                                                <td>
                                                    <input type="button" ID="btnAdd"  runat="server" class="cls_btn_plus" value="Add Product Category" />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ValidationGroup="Add"
                                                    ErrorMessage="Please Select Product Line." InitialValue="0" ControlToValidate="ddlProductCategory"
                                                    ForeColor="Red"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                         </table>
                                        
                                    </td>
                                   
                                </tr>
                                
                                
                            </table>
                         <!-- ------------ End DP 22-Dec-2016 ----------- -->
                     </td>
                 </tr>
             </table>
            <br />
            <br />
            <ul>
                <li style="width: 49%;">
                    <table id="tblcustom" runat="server" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td>
                                <label>
                                    Customer: <span>*</span></label>
                                <asp:TextBox ID="txtCustomer" runat="server" MaxLength="35" onkeypress="return isAlphaKey(event);"
                                    onkeyup="javascript:Alpha(this)" TabIndex="1"></asp:TextBox>
                                <label>
                                </label>
                                <asp:RequiredFieldValidator ID="rfvcustomer" runat="server" ForeColor="Red" ValidationGroup="save"
                                    ControlToValidate="txtCustomer" ErrorMessage="Enter Customer Name"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>
                                    Proposal Terms:
                                </label>
                                <asp:TextBox ID="txtProposalTerm" runat="server" TextMode="MultiLine" autocomplete="false"
                                    TabIndex="3"></asp:TextBox>
                                <label>
                                    <asp:RequiredFieldValidator ID="rfvTerms" runat="server" ForeColor="Red" ValidationGroup="save"
                                        ControlToValidate="txtProposalTerm" ErrorMessage="Enter Proposal Term"></asp:RequiredFieldValidator>
                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>
                                    Proposal Costs: <span>*</span></label><strong>$</strong>
                                <asp:TextBox ID="txtProposalCost" AutoCompleteType="Disabled" runat="server" onclick="ShowPopup()"
                                    onkeypress="ShowPopup()" TabIndex="5"></asp:TextBox>
                                <label>
                                </label>
                                <asp:RequiredFieldValidator ID="rfvProposalCost" runat="server" ForeColor="Red" ValidationGroup="save"
                                    ControlToValidate="txtProposalCost" ErrorMessage="Enter Proposal Cost"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>
                                    Customer Attachment:</label>
                                <ajaxToolkit:AsyncFileUpload ID="AsyncFileUploadCustomerAttachment" runat="server" ClientIDMode="AutoID" ThrobberID="abc"
                                    OnUploadedComplete="AsyncFileUploadCustomerAttachment_UploadedComplete" CompleteBackColor="White"
                                    Style="width: 22% !important;" OnClientUploadComplete="uploadComplete2" />


                                <%-- <asp:FileUpload ID="fileAttachment" runat="server" class="multi" TabIndex="6" />--%>

                                <label>

                                    <asp:LinkButton ID="lnkDownload" runat="server" Text="" Visible="true" OnClick="lnkDownload_Click"></asp:LinkButton>

                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>
                                    Customer Supplied Material:</label>
                                <asp:TextBox ID="txtCustSupMaterial" runat="server" Enabled="false"></asp:TextBox>
                                <label>
                                    <asp:CheckBox ID="chkCustSupMaterial" runat="server" Text="N/A" AutoPostBack="true"
                                        Checked="true" TextAlign="Right" OnCheckedChanged="chkCustSupMaterial_CheckedChanged" />
                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>
                                    Material / Dumpster Storage:</label>
                                <asp:TextBox ID="txtStorage" runat="server" Enabled="false"></asp:TextBox>
                                <label>
                                    <asp:CheckBox ID="chkStorage" runat="server" Text="N/A" TextAlign="Right" AutoPostBack="true"
                                        Checked="true" OnCheckedChanged="chkStorage_CheckedChanged" />
                                </label>
                            </td>
                        </tr>
                    </table>
                </li>
                <li style="width: 49%;" class="last">
                    <table border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td>
                                <label>
                                    Work Area: <span>*</span></label>
                                <asp:TextBox ID="txtworkarea" runat="server" MaxLength="35" TabIndex="2"></asp:TextBox>
                                <label>
                                </label>
                                <asp:RequiredFieldValidator ID="rfvworkarea" runat="server" ForeColor="Red" ValidationGroup="save"
                                    ControlToValidate="txtworkarea" ErrorMessage="Enter Work Area"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr align="left">
                            <td align="left">
                                <table cellpadding="0" cellspacing="0" class="style2">
                                    <tr>
                                        <td style="width: 20%;">Location Image
                                        </td>
                                        <td style="width: 60%;">

                                            <ajaxToolkit:AsyncFileUpload ID="ajaxFileUpload" runat="server" ClientIDMode="AutoID"
                                                OnUploadedComplete="ajaxFileUpload_UploadedComplete" ThrobberID="imgLoad" CompleteBackColor="White"
                                                OnClientUploadComplete="uploadComplete" Style="width: 92% !important; margin-right: 6px" />

                                            <asp:Button ID="btnImageUploadClick" ClientIDMode="AutoID" runat="server" CausesValidation="false"
                                                Text="hidden" Style="display: none" OnClick="btnImageUploadClick_Click" />

                                            <%--<asp:FileUpload ID="FileUpload1" runat="server" onchange="readURL(this);" TabIndex="4"/>--%>
                                            <%--<asp:RequiredFieldValidator ID="reqUpload" runat="server" ControlToValidate="FileUpload1" 
                                                ErrorMessage="Upload atleast two image." Display="Dynamic" ForeColor="Red" SetFocusOnError="true" ValidationGroup="save">
                                            </asp:RequiredFieldValidator>--%>
                                        </td>
                                        <td style="width: 20%;">
                                            <%--<asp:Button ID="bntAdd" runat="server" Text="Attach" Width="50px" OnClick="bntAdd_Click"
                                                OnClientClick="return ValidateAddImage()" />--%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <asp:UpdatePanel ID="pnlUpdate" runat="server">
                                                <ContentTemplate>
                                                    <asp:GridView runat="server" ID="gvCategory" AutoGenerateColumns="false" OnRowCommand="gvCategory_RowCommand"
                                                        DataKeyNames="RowSerialNo" AllowPaging="true" OnRowDataBound="gvCategory_RowDataBound"
                                                        PageSize="1" OnPageIndexChanging="gvCategory_PageIndexChanging">
                                                        <EmptyDataTemplate>
                                                            <asp:Label ID="lblNoDataFound" runat="server" Text="Image Not Found."></asp:Label>
                                                        </EmptyDataTemplate>
                                                        <Columns>
                                                            <asp:TemplateField>
                                                                <ItemStyle Width="90%" />
                                                                <HeaderTemplate>
                                                                    <asp:Label ID="Image" runat="server" Text="Image" Font-Bold="true"></asp:Label>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <asp:Image ID="imglocation" runat="server" ImageUrl='<%#Eval("LocationPicture")%>'
                                                                        Height="100px" Width="100px" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemStyle Width="10%" />
                                                                <HeaderTemplate>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <asp:LinkButton ID="lnkCategoryDelete" runat="server" Text="X" CommandArgument='<%#Eval("RowSerialNo")%>'
                                                                        CommandName="DeleteRec" CausesValidation="false" OnClientClick='javascript:return confirm("Are you sure want to delete this entry?");'></asp:LinkButton>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                    <asp:HiddenField ID="hidCount" runat="server" />
                                                </ContentTemplate>

                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>
                                    Special Instructions / Exemptions:
                                </label>
                                <asp:TextBox ID="txtspecialIns" runat="server" TextMode="MultiLine" TabIndex="7"></asp:TextBox>
                                <label>
                                </label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:CheckBox ID="chkPermit" runat="server" Text="Permit Required" />
                                <asp:CheckBox ID="chkHabitat" runat="server" Text="Habitat For Humanity Pick Up" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                        </tr>
                    </table>
                </li>
            </ul>
            <div class="btn_sec">
                <asp:Button ID="btnsave" runat="server" Text="Save" ValidationGroup="save" OnClientClick="return ValidateImage()"
                    OnClick="btnsave_Click" TabIndex="8" />
                <asp:Button ID="btnexit" runat="server" Text="Exit" ValidationGroup="exit" TabIndex="9"
                    OnClick="btnexit_Click" />
                <asp:HiddenField ID="hidProdId" runat="server" />
                <asp:HiddenField ID="hidProdType" runat="server" />
            </div>
            <div id="mask">
            </div>
            <asp:Panel ID="pnlpopup" runat="server" BackColor="White" Height="175px" Width="300px"
                Style="z-index: 111; background-color: White; position: absolute; left: 35%; top: 12%; border: outset 2px gray; padding: 5px; display: none">
                <table width="100%" style="width: 100%; height: 100%;" cellpadding="0" cellspacing="5">
                    <tr style="background-color: #b5494c">
                        <td colspan="2" style="color: White; font-weight: bold; font-size: 1.2em; padding: 3px"
                            align="center">Admin Verification <a id="closebtn" style="color: white; float: right; text-decoration: none"
                                class="btnClose" href="#">X</a>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="width: 45%; text-align: center;">
                            <asp:Label ID="LabelValidate" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td align="right" style="width: 45%">Amount:
                        </td>
                        <td>
                            <asp:TextBox ID="txtAmount" runat="server" onkeypress="return isNumericKey(event);"
                                MaxLength="20" Text=""></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td align="right">Admin Password:
                        </td>
                        <td>
                            <asp:TextBox ID="txtauthpass" runat="server" TextMode="Password" Text=""></asp:TextBox>
                            <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <input type="button" class="btnVerify" value="Verify" onclick="javascript: return focuslost();" />
                            &nbsp;&nbsp;
                            <input type="button" class="btnClose" value="Cancel" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>
            <%--<ajaxToolkit:ModalPopupExtender ID="myModalPopupExtender" runat="server" TargetControlID="txtProposalCost"
                    PopupControlID="pnlVerify" CancelControlID="btnCancel">
                </ajaxToolkit:ModalPopupExtender>
                <asp:Panel ID="pnlVerify" runat="server" BackColor="Gray" height="200" width="450" Style="display: none;">
                    <iframe id="frameeditexpanse" runat="server" frameborder="0" src="CustomVerification.aspx" height="210" width="450">
                    </iframe>
                  <input id="btnCancel" value="Cancel" type="button" style="display:none;" />
                </asp:Panel>--%>
        </div>
    </div>

     <!-- ------------ Start DP 22-Dec-2016 ----------- -->
    <script type="text/javascript">
        $(document).ready(function () {
            var cnt = 2;
            function addRow() {
                var html =
                '<tr id="tr_'+cnt+'">' +
                    '<td><input type="button" ID="btnexpand_' + cnt + '"  class="cls_btn_plus" value=" - " />' +
                    'Select Product Category</td>' +
                    '<td>' +
                    '<select name="ddlProductCategory" class="productlines" id="ddlProductCategory_' + cnt + '" onChange="javascript:prodchange('+cnt +');" tabindex="2" style="width:200px;">' +
						'<option selected="selected" value="0">Select</option>' +
						'<option value="1">Custom Other -*T&amp;M*</option>' +
						'<option value="2">Service-Maintenance &amp; Repair </option>' +
						'<option value="3">Painting</option>' +
						'<option value="4">Fascia &nbsp;- Capping &amp; Soffit</option>' +
						'<option value="5">Gutters &amp; Gutter Guards</option>' +
						'<option value="6">Framing- Drywall-Insulation-trim</option>' +
						'<option value="7">Siding</option>' +
						'<option value="8">Masonry Siding &amp; Retaining Walls</option>' +
						'<option value="9">Masonry Flat- Concrete Cement &amp; Asphalt </option>' +
						'<option value="10">Roofing</option>' +
						'<option value="11">Roofing -Metal-Shake-Slate-Terracotta</option>' +
						'<option value="12" style="color:red;">Awnings</option>' +
						'<option value="13">Fencing</option>' +
						'<option value="14">Decking- Railing -Post-Columns</option>' +
						'<option value="16">Flooring</option>' +
						'<option value="17" style="color:red;">Windows &amp; Doors</option>' +
						'<option value="18" style="color:red;">Bathrooms</option>' +
						'<option value="19" style="color:red;">Kitchens</option>' +
						'<option value="20" style="color:red;">Basements</option>' +
						'<option value="21" style="color:red;">Additions</option>' +
						'<option value="23">Plumbing</option>' +
						'<option value="31" style="color:red;">Electric</option>' +
						'<option value="32">Tools, Equipment &amp;Machinery</option>' +
						'<option value="41">Excavating, Hardscaping &amp; Landscaping</option>' +
                        '<option value="42">New Residential Construction</option>' +
                        '<option value="44">Overhead</option>' +
                        '<option value="52">Dumpsters &amp; Waste</option>' +
                        '<option value="54">Heating, Venting &amp; Cooling</option>' +
                        '<option value="55">Dump</option>' +
						'<option value="56">Equipment &amp; Industry</option>' +
						'<option value="57">Masonry - &nbsp;Flat work &amp;&nbsp;Retaining walls</option>' +
						'<option value="58" style="color:red;">Flooring - Hardwood-Laminate-Vinyl</option>' +
						'<option value="59">Roofing- Asphalt &amp; Flat</option>' +
						'<option value="60">electrical</option>' +
						'<option value="61">Tools, equipment &amp; machinery</option>' +
						'<option value="62">tool-equipment</option>' +
						'<option value="63">0</option>' +
					    '</select>' +
                        '&nbsp;<input type="text" name="txtOth" style="display:none;width:120px;" id="txtOther_'+cnt+'" />'+
                    '</td>' +
                    '<td><a href="javascript:void(0);" class="BtnMinus">Clear/Delete</a></td>' +
                    '</tr>'

              
                $(html).appendTo($("#ContentPlaceHolder1_tblAddmore"));
                cnt++;
            };

           // $("#ContentPlaceHolder1_tblAddmore").on("click", ".cls_btn_plus", addRow);

            $(".cls_btn_plus").click(function () {
                $("#ContentPlaceHolder1_btnexpand").val(' + ')
                addRow();
            });
            function deleteRow() {
                var m = confirm("are you sure you want to delete this product category, Data will not be saved ?");
                if (m) {
                    //var strId = $(this).attr('id');
                    //alert(strId);
                    //var vArr = strId.split("_");
                    //var vId = vArr[1];
                    //alert($('#tr_' + vId + ''));
                    //$('#tr_'+vId+'').remove();
                    var par = $(this).parent().parent();
                    par.remove();
                }
            };
            $("#ContentPlaceHolder1_tblAddmore").on("click", ".BtnMinus", deleteRow);
        


            $("#ContentPlaceHolder1_txtOther").hide();
            $("#ContentPlaceHolder1_txtOther").val('');

            $("#ContentPlaceHolder1_ddlProductCategory").change(function () {
                var drpVal  = $("#ContentPlaceHolder1_ddlProductCategory").val();
                if ( parseInt(drpVal) == 2 || parseInt(drpVal) == 3) {
                    $("#ContentPlaceHolder1_txtOther").show();

                }
                else {
                    $("#ContentPlaceHolder1_txtOther").hide();
                    $("#ContentPlaceHolder1_txtOther").val('');

                }
            });
        
            
           
                
               /* if ($(this).val() == "2" || $(this).val == "3") {
                    var strId = $(this).attr('id');
                    var vArr = strId.split("_");
                    var vId = vArr[1];
                    $("#ContentPlaceHolder1_txtOther"+vId+"").show();

                }
                else {
                    $("#ContentPlaceHolder1_txtOther" + vId + "").val('');
                    $("#ContentPlaceHolder1_txtOther" + vId + "").hide();
                

                }*/
            
        });

        function prodchange(obj) {
            
            var drpval = $('#ddlProductCategory_' + obj + '').val();
            if (drpval != 0)
            {
                $('#btnexpand_' + obj + '').val(' + ')
            }
            else
            {
                $('#btnexpand_' + obj + '').val(' - ')
            }
            if(drpval==2 || drpval==3)
            {
                $('#txtOther_' + obj + '').show();
            }
            else
            {
                $('#txtOther_' + obj + '').val('');
                $('#txtOther_' + obj + '').hide();
            }
            
        }
        //-------- End DP ----------
    </script>
    
</asp:Content>
