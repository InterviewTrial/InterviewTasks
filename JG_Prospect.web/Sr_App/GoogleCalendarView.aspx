<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GoogleCalendarView.aspx.cs" MasterPageFile="~/Sr_App/SR_app.Master" Inherits="JG_Prospect.Sr_App.GoogleCalendarView" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%--<%@ Register Src="~/Controls/left.ascx" TagName="leftmenu" TagPrefix="uc1" %>--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%-- <script src="../datetime/js/jquery.ptTimeSelect.js" type="text/javascript"></script>
    <link href="../datetime/js/jquery.ptTimeSelect.css" rel="stylesheet" type="text/css" />--%>
    <style type="text/css">
        .rsAptDelete {
            display: none;
        }

        .RadScheduler .rsHeader .rsHeaderTimeline {
            background-position: -228px -31px;
            float: left;
            font-size: 0;
            height: 24px;
            line-height: 21px;
            margin: -26px 0 0 86px !important;
            overflow: hidden;
            text-indent: -9999px;
            width: 21px;
        }
        .rsAptContent ,.rsAptOut
        {
            height:63px !important;
        }

        *, *:before, *:after {
            box-sizing: none !important;
        }

        .RadScheduler_Default .rsHeader .rsSelected em, .RadScheduler_Default .rsHeader ul a:hover span {
            color: #fff;
            font-size: 11px;
        }

        .RadScheduler .rsMonthView .rsWrap {
            /*height: 71px !important;
            width: 155px !important;*/
            margin: 0 0 10px 0 !important;
        }

        .RadScheduler .rsMonthView .rsApt {
            /*height: 66px !important;
            width: 160px !important;*/
            width: 100% !important; /*108*/
            height: 50px !important; /*44*/
        }

        .RadScheduler .rsWeekView .rsApt {
            /*height: 66px !important;
            width: 160px !important;*/
            width: 100% !important; /*108*/
            height: 60px !important; /*44*/
        }

        .RadScheduler .rsDayView .rsApt {
            /*height: 66px !important;
            width: 160px !important;*/
            width: 40% !important; /*108*/
            height: 50px !important; /*44*/
        }

        tr {
            height: none !important;
        }

        .RadScheduler, .RadScheduler * {
            margin: 0;
            padding: 0;
            box-sizing: initial !important;
        }

            .RadScheduler .rsOvertimeArrow {
                display: none !important;
            }
    </style>
    <style type="text/css">
        /*.modalBackground {
            background-color: Gray;
            filter: alpha(opacity=80);
            opacity: 0.8;
            z-index: 10000;
            display: none;
        }*/

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

        .white_content {
            display: none;
            position: absolute;
            top: 10%;
            left: 20%;
            width: 60%;
            height: 5%;
            padding: 16px;
            border: 10px solid #327FB5;
            background-color: white;
            z-index: 1002;
            overflow: auto;
        }

        /*@font-face {
            font-family: 'barcode_fontregular';
            src: url('../fonts/barcodefont-webfont.eot');
            src: url('../fonts//barcodefont-webfont.eot?#iefix') format('embedded-opentype'), url('../fonts/barcodefont-webfont.woff2') format('woff2'), url('../fonts/barcodefont-webfont.woff') format('woff'), url('../fonts/barcodefont-webfont.ttf') format('truetype'), url('../fonts/barcodebarcodefont-webfont.svg#barcode_fontregular') format('svg');
            font-weight: normal;
            font-style: normal;
        }*/
    </style>
    <style type="text/css"> 
        .modalBackground { 
            background-color:#333333; 
            filter:alpha(opacity=70); 
            opacity:0.7; 
        } 
        .modalPopup { 
            background-color:#FFFFFF; 
            border-width:1px; 
            border-style:solid; 
            border-color:#CCCCCC; 
            padding:1px; 
            width:700px; 
            Height:450px; 
        }    



    </style> 
    <style>
    /* ----css start for eventcolor --*/
    table.eventcolor label input {
        visibility: hidden;
    }
    table.eventcolor  label  {
        display: block;
        margin: 0 0 0 -10px;
        padding: 0 0 20px 0;  
        height: 20px;
        width: 30px;
    
    }
    table.eventcolor  label   img {
        display: inline-block;
        padding: 0px;
        height:18px;
        width:18px;
	    background-color:none;
    }
    .selectedeventcolor
    {
        margin-right: 30px;
        height:18px;
        width:18px;
	    background-color:none;
    }
    table.eventcolor td span
    {
        margin-right:10px;
    }
    table.eventcolor  label  input:checked +img {  
        background: url(../img/whitetick.png);
        background-repeat: no-repeat;
        background-position:center center;
        background-size:15px 15px;
	    background-color:#000099;
    }

    /* ----css end for eventcolor --*/
    </style>
   <%-- <link href="../datetime/css/jquery-ui-1.7.1.custom.css" rel="stylesheet" type="text/css" />
    <link href="../datetime/css/stylesheet.css" rel="stylesheet" type="text/css" />--%>
   <link href="../css/jquery.timepicker.css" rel="stylesheet" type="text/css" />


    <script lang="JavaScript" type="text/javascript">
        $(document).ready(function () {


            $(".date").datepicker({
                minDate: 0,
                dateFormat: "dd-M-yy"
            });
          //  $('.time').ptTimeSelect();

            $("#btnSubmit").click(function () {
                var isduplicate = document.getElementById('hdnisduplicate').value;
                var custid = document.getElementById('hdnCustId').value;
                if (isduplicate.toString() == "1") {
                    if (confirm('Duplicate contact, Press Ok to add the another appointment for existing customer.')) {
                        window.open("../Prospectmaster.aspx?title=" + custid);
                    }
                    else {
                        // alert('false');
                    }
                }
            });
        });

        function fnCheckOne(me) {
            me.checked = true;
            var chkary = document.getElementsByTagName('input');
            for (i = 0; i < chkary.length; i++) {
                if (chkary[i].type == 'checkbox') {
                    if (chkary[i].id != me.id)
                        chkary[i].checked = false;
                }
            }
        }

        //function ClosePopupOfferMade() {
        //    document.getElementById('DivOfferMade').style.display = 'none';
        //    document.getElementById('DivOfferMadefade').style.display = 'none';
        //}

        //function OverlayPopupOfferMade() {
        //    document.getElementById('DivOfferMade').style.display = 'block';
        //    document.getElementById('DivOfferMadefade').style.display = 'block';
        //    $("html, body").animate({ scrollTop: 0 }, "slow");
        //}

        //function overlayInterviewDate() {

        //    document.getElementById('interviewDatelite').style.display = 'block';
        //    document.getElementById('interviewDatefade').style.display = 'block';
        //    //$('#interviewDatelite').focus();
        //    $("html, body").animate({ scrollTop: 0 }, "slow");
        //}

        //function overlayInterviewDate_Close() {
        //    document.getElementById('interviewDatelite').style.display = 'none';
        //    document.getElementById('interviewDatefade').style.display = 'none'
        //}
       

    </script>

   
                

 

<%--    <code>$('#time1 input').ptTimeSelect({ onBeforeShow: function(i){ $('#time1 #time1-data').append('onBeforeShow(event)
        Input field: ' + $(i).attr('name') + "<br />
        "); }, onClose: function(i) { $('#time1 #time1-data').append('onClose(event)Time
        selected:' + $(i).val() + "<br />
        "); } }); $('#time2 input').ptTimeSelect({ onBeforeShow: function(i){ $('#time2
        #time2-data').append('onBeforeShow(event) Input field: ' + $(i).attr('name') + "<br />
        "); }, onClose: function(i) { $('#time2 #time2-data').append('onClose(event)Time
        selected:' + $(i).val() + "<br />
        "); } }); </code>--%>
    <%---------end script for Datetime Picker----------%>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <%--  <div class="left_panel arrowlistmenu">
        <uc1:leftmenu ID="left1" runat="server" />
    </div>--%>
    <div class="right_panel">
        <ul class="appointment_tab">

            <li><a id="A1" href="home.aspx" runat="server">Sales Calendar</a> </li>
            <li><a id="A2" href="GoogleCalendarView.aspx" runat="server" class="active">Master  Calendar</a></li>
            <li><a id="A5" href="#" runat="server">Construction Calendar</a></li>
            <li><a id="A3" href="~/Sr_App/CallSheet.aspx" runat="server">Call Sheet</a></li>
        </ul>
        <h1>
            Master  Calendar</h1>
              <asp:Label ID="Label2" runat="server"></asp:Label>
        <asp:UpdatePanel ID="upContent" runat="server" UpdateMode="Always">
            <ContentTemplate>
                <h2>
                    <% 
                       
                        if (Session["DesigNew"].ToString() == "ITLead" || Session["DesigNew"].ToString() == "Office Manager" || Session["DesigNew"].ToString() == "Sales Manager" || Session["DesigNew"].ToString() == "ForeMan")
                       { %>
                    <asp:Button ID="btnCreateEvent" runat="server" Text="Create" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" Height="30px" Width="75px" OnClick="btnCreateEvent_Click"   />
                    <asp:Button ID="btnCreateCal" runat="server" Text="Create Calendar" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" Height="30px" Width="120px" OnClick="btnCreateCal_Click"   />
                    <% } %>
                    &nbsp; <asp:DropDownList runat="server" ID="drpMyCalendar" Height="30px" Width="200px" OnSelectedIndexChanged="drpMyCalendar_SelectedIndexChanged" AutoPostBack="true">
                                <asp:ListItem Text="My Calendar" Value="0"></asp:ListItem>
                           </asp:DropDownList>
                    
                    &nbsp;<asp:Button ID="btnAddEvent" runat="server" Text="Add Event" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" Height="30px" Width="75px" OnClick="btnAddEvent_Click" Visible="false" />
                    &nbsp;&nbsp;&nbsp;&nbsp;<asp:CheckBox ID="chkHR" runat="server" Visible ="false" OnCheckedChanged="chkHR_CheckedChanged" Text="HR" AutoPostBack="true" />
                    &nbsp;&nbsp;&nbsp;&nbsp;<asp:CheckBox ID="chkCompany" runat="server" Visible ="false" OnCheckedChanged="chkCompany_CheckedChanged" Text="Company" AutoPostBack="true" />
                    &nbsp;&nbsp;&nbsp;&nbsp;<asp:CheckBox ID="chkEvents" runat="server" Visible ="false" Text="Events" OnCheckedChanged="chkEvents_CheckedChanged" AutoPostBack="true" />

                </h2>
                <div class="calendar" style="margin: 0;">

                    <div id="calendarBodyDiv">
                        <telerik:RadScheduler  ID="rsAppointments" runat="server" DataKeyField="id" DayStartTime="7:00:00" DayEndTime="20:59:59"
                            AllowEdit="false" DataStartField="EventDate" DataEndField="EventDate" DataSubjectField="EventName"
                            ShowHeader="true" Width="100%" Height="100%" TimelineView-NumberOfSlots="0" TimelineView-ShowDateHeaders="false"
                            EnableExactTimeRendering="true" EnableDatePicker="true" SelectedView="MonthView"
                            CustomAttributeNames="EventName,id,LastName,ApplicantId,Designation,Status, Email, AssignedUserFristNames,TaskId ,InstallId"
                            AppointmentContexcalendarBodyDivtMenuSettings-EnableDefault="true" TimelineView-GroupingDirection="Vertical"
                            TimelineView-ReadOnly="true" m DisplayDeleteConfirmation="false" OnAppointmentCreated="rsAppointments_AppointmentCreated">
                            <%-- OnClientAppointmentClick="OnClientAppointmentClick" OnClientTimeSlotClick="OnClientTimeSlotClick"      OnAppointmentClick="rsAppointments_AppointmentClick"--%>
                            <AdvancedForm Modal="True" />
                            <AppointmentTemplate>
                                <%--<%#Eval("EventName") %>--%>
                                <asp:Label ID="lbleventname" runat="server" Text='<%#Eval("EventName")%>' BackColor="Wheat"></asp:Label>
                             <%--   <asp:LinkButton ID="lbtCustID" runat="server" OnClick="lbtCustID_Click" Text='<%#Eval("ApplicantId") %>' ForeColor="Black"></asp:LinkButton>

                                <asp:LinkButton ID="lnkEmail" Visible="false" runat="server" Text='<%#Eval("Email") %>'></asp:LinkButton>
                                <%#Eval("LastName") %>, <%#Eval("Designation") %>, <%#Eval("AssignedUserFristNames") %> ,
                                <asp:DropDownList ID="ddlStatus" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged" runat="server">
                                    <asp:ListItem Text="Applicant" Value="Applicant"></asp:ListItem>
                                    <asp:ListItem Text="Phone/Video Screened" Value="PhoneScreened"></asp:ListItem>
                                    <asp:ListItem Text="Rejected" Value="Rejected"></asp:ListItem>
                                    <asp:ListItem Text="Interview Date" Value="InterviewDate"></asp:ListItem>
                                    <asp:ListItem Text="Offer Made" Value="OfferMade"></asp:ListItem>
                                    <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                                    <asp:ListItem Text="Deactive" Value="Deactive"></asp:ListItem>
                                    <asp:ListItem Text="Install Prospect" Value="Install Prospect"></asp:ListItem>
                                </asp:DropDownList>

                                <asp:LinkButton ID="lbtnReSchedule" runat="server" OnCommand="lbtnReSchedule_Click" Text='Re-Schedule' CommandArgument='<%#Eval("ApplicantId") +","+ Eval("Designation")%> ' ></asp:LinkButton>
                                /&nbsp;
                                <a target="_blank" href="/Sr_App/TaskGenerator.aspx?TaskId=<%#Eval("TaskId")%>"><%#Eval("InstallId")%></a>   --%>                             
                                
                            </AppointmentTemplate>
                        </telerik:RadScheduler>
                        
                        <telerik:RadWindow ID="RadWindow1" runat="server" Modal="true" Title="No Appointment available"
                            Behaviors="Close">
                        </telerik:RadWindow>

                    </div>
                    <%-- <iframe src="https://www.google.com/calendar/embed?mode=WEEK&amp;src=kf0evh90ibsidlkgur33a0s0h4%40group.calendar.google.com&ctz=America/St_Thomas"
                        style="border: 0; width: 100%; height: 800px;" frameborder="0" scrolling="no">
                    </iframe>--%>
                    <%--  <iframe src="https://www.google.com/calendar/embed?mode=WEEK&amp;src=j3h50vq9am0at74sopc8dferk4%40group.calendar.google.com&ctz=America/St_Thomas"  style="border: 0; width: 100%; height: 800px;" frameborder="0" scrolling="no"></iframe>--%>
                </div>

            <!--  ------- Start DP Add events ------  -->
            <cc1:ModalPopupExtender ID="mpEvents" runat="server" PopupControlID="pnlEvent"  TargetControlID="btnCreateEvent"
            CancelControlID="btnClose" BackgroundCssClass="modalBackground">
            </cc1:ModalPopupExtender>
                    <asp:Panel ID="pnlEvent" runat="server" CssClass="modalPopup" Height="600px" Width="700px" align="center" >
                           
                       <h1><b>Add Events</b></h1>
                            
                                    <table border="1" cellspacing="5" cellpadding="5">
                                       
                                        <tr>
                                            <td colspan="4">
                                                <asp:Label ID="lblmsg" runat="server" Visible="false"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td   align="left">  Event Name <span>*</span>
                                            </td>
                                            <td >
                                                <asp:TextBox ID="txtEventName" runat="server"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" ValidationGroup="SubmitEvent"
                                                    runat="server" ControlToValidate="txtEventName" ForeColor="Red" ErrorMessage="Please Enter Event Name" Display="None"> </asp:RequiredFieldValidator>
                                            </td>
                                       
                                            <td   align="left">Calendar <span>*</span> </td>
                                            <td >
                                                <asp:DropDownList runat="server" ID="drpEventCalender" >
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="left">Event Colors  </td>
                                            <td colspan="3">
                                                
                                               <table class="eventcolor">
                                                   <tr>
                                                       <td>
                                                           <div  class="selectedeventcolor" style="background-color:#5484ed" /> 
                                                        </td>
                                                       <td>
                                                           <span> Select Color :</span>
                                                           <asp:HiddenField ID="txtEventColor" runat="server"   />
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#5484ed" class="radiol"  /> 		  
			                                                   <img src="" class="img1" style="background-color:#5484ed" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#a4bdfc" class="radiol"  /> 		  
			                                                    <img src="" class="img1" style="background-color:#a4bdfc" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                                <input type="radio" name="foo" value="#46d6db" class="radiol"  /> 		  
			                                                    <img class="img1" style="background-color:#46d6db" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#7ae7bf" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#7ae7bf" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#51b749" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#51b749" />
                                                           </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#fbd75b" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#fbd75b" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#ffb878" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#ffb878" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#ff887c" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#ff887c" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#dc2127" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#dc2127" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#9966CC" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#9966CC" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label>
                                                               <input type="radio" name="foo" value="#e1e1e1" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#e1e1e1" />
                                                           </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#FF33CC" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#FF33CC" />
                                                            </label>
                                                       </td>
                                                        <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#FF9966" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#FF9966" />
                                                            </label>
                                                       </td>

                                                        <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#CC6699" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#CC6699" />
                                                            </label>
                                                       </td>
                                                       <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#33CC66" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#33CC66" />
                                                            </label>
                                                       </td>
                                                        <td>
                                                           <label >
                                                               <input type="radio" name="foo" value="#FFFF99" class="radiol"  /> 		  
			                                                   <img class="img1" style="background-color:#FFFF99" />
                                                            </label>
                                                       </td>
                                                   </tr>
                                               </table>
                                             
                                            </td>
                                        </tr>
                                        <tr>
                                            <td> Event Start Date <span>*</span> </td>
                                            <td>
                                                 <asp:TextBox ID="txtEventStartDate" CssClass="date" onkeypress="return false" MaxLength="10"
                                                    TabIndex="1" runat="server"></asp:TextBox>
                                                 <asp:RequiredFieldValidator ID="RequiredFieldValidator6" ValidationGroup="SubmitEvent" runat="server"
                                                   ControlToValidate="txtEventStartDate" ForeColor="Red" ErrorMessage="Please Enter Event Date" Display="None"> </asp:RequiredFieldValidator>
                                             </td>
                                            <td>Event End Date <span>*</span></td>
                                            <td>
                                                 <asp:TextBox ID="txtEventEndDate" CssClass="date" onkeypress="return false" MaxLength="10"
                                                    TabIndex="1" runat="server"></asp:TextBox>
                                             </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                    Event Start Time <span>*</span>
                                            </td>
                                            <td>
                                                    <asp:TextBox ID="txtEventStartTime" CssClass="time"  MaxLength="10"
                                                    TabIndex="1" runat="server"></asp:TextBox>
                                             </td>
                                            <td>  Event End Time <span>*</span> </td>
                                            <td>
                                                    <asp:TextBox ID="txtEventEndTime" CssClass="time"  MaxLength="10"
                                                    TabIndex="1" runat="server"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                <asp:CheckBoxList  RepeatDirection="Horizontal"  runat="server" ID="chkEventType" >
                                                    <asp:ListItem Text="All Day" Value="1"></asp:ListItem>
                                                    <asp:ListItem Text="Repeat" Value="2"></asp:ListItem>
                                                    
                                                </asp:CheckBoxList>
                                            </td>
                                            <td colspan="3">
                                                <table>
                                                    <tr>
                                                        <td> 
                                                            <asp:Panel runat="server" ID="pnlRepeatEvent">
                                                                <asp:RadioButtonList  RepeatDirection="Horizontal" runat="server" ID="rdoRepeatEvent">
                                                                    <asp:ListItem Text="Daily" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="Weekly" Value="2"></asp:ListItem>
                                                                    <asp:ListItem Text="Monthly" Value="3"></asp:ListItem>
                                                                    <asp:ListItem Text="Weekly" Value="4"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </asp:Panel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                Attachment
                                            </td>
                                            <td valign="top">
                                                <asp:FileUpload  ID="flEventFile" runat="server" />
                                            </td>
                                            <td  align="left" valign="top">
                                                    Event Location <span>*</span>
                                            </td>
                                            <td valign="top">
                                                 <asp:TextBox ID="txtEventLoc"    MaxLength="10"    TabIndex="1" runat="server"></asp:TextBox>
                                                 <asp:RequiredFieldValidator ID="RequiredFieldValidator10" ValidationGroup="SubmitEvent" runat="server"
                                                   ControlToValidate="txtEventLoc" ForeColor="Red" ErrorMessage="Please Enter Event Location" Display="None"> </asp:RequiredFieldValidator>
                                             </td>
                                        </tr>
                                        <tr>
                                            
                                            <td colspan="2"  valign="top">
                                                <div style="overflow:scroll;height:200px;">
                                                    <table id="tblInvite" runat="server" >
                                                        <tr>
                                                            <td>
                                                                Invite Users : <asp:TextBox ID="txtInviteEmail"  runat="server"></asp:TextBox>
                                                               <input type="button" id="btnInviteEmail" runat="server" value="Add" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>

                                            <td  align="left" valign="top">
                                                    Description <span>*</span>
                                            </td>
                                            <td valign="top">
                                                 <asp:TextBox ID="txtEventDesc" TextMode="MultiLine"  Columns="30"   Rows="5"    TabIndex="1" runat="server"></asp:TextBox>
                                                 <asp:RequiredFieldValidator ID="RequiredFieldValidator11" ValidationGroup="SubmitEvent" runat="server"
                                                   ControlToValidate="txtEventDesc" ForeColor="Red" ErrorMessage="Please Enter Event Description" Display="None"> </asp:RequiredFieldValidator>
                                             </td>
                                        </tr>
                                      <tr>
                                          <td colspan="4">
                                               <asp:HiddenField ID="txtinvite"  runat="server"  ></asp:HiddenField>
                                                <asp:Button ID="btnEventSubmit"  runat="server" Height="30px" Width="70px" TabIndex="5" Text="Submit" OnClientClick="javascript:return gotoInvite();" OnClick="btnEventSubmit_Click"  Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" ValidationGroup="Submit" />
                                                <asp:Button ID="btnEventClose" runat="server" Height="30px" Width="70px" TabIndex="6" Text="Close" OnClick="btnEventClose_Click" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" />
                                          </td>
                                      </tr>
                                    </table>
                                
                           
                   </asp:Panel>

               <%-- <script src="//code.jquery.com/jquery-1.10.2.js"></script>--%>
      
                  <!-- Updated JavaScript url -->
               <script src="../js/jquery.timepicker.js"></script>
     
                <script type="text/javascript" >
                   
                    $(document).ready(function () {
                        $('#ContentPlaceHolder1_txtEventStartTime').timepicker({});
                        $('#ContentPlaceHolder1_txtEventEndTime').timepicker();

                        $(".radiol").click(function () {
                            $("#ContentPlaceHolder1_txtEventColor").val($(this).val());
                            $(".selectedeventcolor").attr("style", "background-color:" + $(this).val() + "");
                        });

                        $("#ContentPlaceHolder1_rdoRepeatEvent").find('input').prop("disabled", true);

                        $("#ContentPlaceHolder1_chkEventType input[type='checkbox']").click(function () {
                            
                            if($(this).val() ==2)
                            {
                                $('#ContentPlaceHolder1_chkEventType_0').prop("checked", false);
                                $('#ContentPlaceHolder1_txtEventEndDate').val('');
                                $("#ContentPlaceHolder1_rdoRepeatEvent").find('input').prop("disabled", false);
                                $('#ContentPlaceHolder1_txtEventStartTime').prop("disabled", false);
                                $('#ContentPlaceHolder1_txtEventEndTime').prop("disabled", false);
                            }
                            else {
                                $('#ContentPlaceHolder1_chkEventType_1').prop("checked", false);
                                var vStartDate = $('#ContentPlaceHolder1_txtEventStartDate').val();

                                $('#ContentPlaceHolder1_txtEventStartTime').prop("disabled", true);
                                $('#ContentPlaceHolder1_txtEventEndTime').prop("disabled", true);
                                $('#ContentPlaceHolder1_txtEventStartTime').val('');
                                $('#ContentPlaceHolder1_txtEventEndTime').val('');

                                $('#ContentPlaceHolder1_txtEventEndDate').val(vStartDate);
                                $("#ContentPlaceHolder1_rdoRepeatEvent").find('input').prop("disabled", true);
                            }
                            
                        });
                        

                        // invite people for event //
                        var cnt = 2;

                        function addRow() {
                            var txtInviteVal = $("#ContentPlaceHolder1_txtInviteEmail").val();
                            var html =
                            '<tr id="tr_' + cnt + '">' +
                                '<td>' + '&nbsp;<lable class="eventinvite">' + txtInviteVal + ' </lable>'+
                                '</td>' +
                                '<td><a href="javascript:void(0);" class="BtnMinus"> X </a></td>' +
                                '</tr>'

                            $(html).appendTo($("#ContentPlaceHolder1_tblInvite"));
                            cnt++;
                        };

                        function deleteRow() {
                            //var m = confirm("are you sure you want to delete this product category, Data will not be saved ?");
                            //if (m) {
                                var par = $(this).parent().parent();
                                par.remove();
                            //}
                        };

                        $("#ContentPlaceHolder1_btnInviteEmail").click(function () {
                             addRow();
                        });

                        $("#ContentPlaceHolder1_tblInvite").on("click", ".BtnMinus", deleteRow);
                

                    });

                    function gotoInvite() {
                       
                        var i = 0;
                        var strInviteEmail = "";
                        $(".eventinvite").each(function () {
                            //alert($(this).text());
                            if(i==0)
                            {
                                strInviteEmail = $(this).text();
                            }
                            else {
                                strInviteEmail = strInviteEmail + ";" + $(this).text();
                            }
                            i = i + 1;
                        });
                        $("#ContentPlaceHolder1_txtinvite").val(strInviteEmail);
                       
                    }

                </script>




                 <cc1:ModalPopupExtender ID="mpCalendar" runat="server" PopupControlID="pnlCalendar" TargetControlID="btnCreateCal"
            CancelControlID="btnClose" BackgroundCssClass="modalBackground">
            </cc1:ModalPopupExtender>
                    <asp:Panel ID="pnlCalendar" runat="server" CssClass="modalPopup" align="center" >
                           
                       <h1><b>Add Calendar</b></h1>
                            <table border="1" cellspacing="5" cellpadding="5">
                                <tr>
                                    <td colspan="4">
                                        <asp:Label ID="Label1" runat="server" Visible="false"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td   align="left">  Calendar Name <span>*</span>
                                    </td>
                                    <td >
                                        <asp:TextBox ID="txtCalName" runat="server"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ValidationGroup="SubmitCalendar"
                                            runat="server" ControlToValidate="txtCalName" ForeColor="Red" ErrorMessage="Please Enter Calendar Name" Display="None"> </asp:RequiredFieldValidator>
                                    </td>
                                       
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:Button ID="btnAddCalendar"  runat="server" Height="30px" Width="70px" TabIndex="5" Text="Submit" OnClick="btnAddCalendar_Click"  Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" ValidationGroup="Submit" />
                                        <asp:Button ID="btnCalClose" runat="server" Height="30px" Width="70px" TabIndex="6" OnClick="btnCalClose_Click" Text="Close" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" />
                                    </td>
                                </tr>
                            </table>
                           
                   </asp:Panel>




                <!-- --------- End DP -------  -->
            </ContentTemplate>

             
            <Triggers>
                <asp:PostBackTrigger ControlID="btnEventSubmit" />
            </Triggers>
             
        </asp:UpdatePanel>
    </div>
    
    <asp:UpdatePanel ID="upRadWindowManager" runat="server" UpdateMode="Always">
        <ContentTemplate>
            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" EnableShadow="true">
                <Windows>
                    <telerik:RadWindow ID="RadWindow2" runat="server" ShowContentDuringLoad="false" Width="400px"
                        Height="400px" Title="Annual Event Calendar" Behaviors="Default">
                        <%--<ContentTemplate>
                            <br />
                            <br />
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                              <asp:Label ID="Label1" runat="server" Text="Event Id : " Visible="false"></asp:Label>
                            <asp:LinkButton ID="lbtCustomerID" runat="server" OnClick="lbtCustomerID_Click" Visible="false"></asp:LinkButton>
                            <% -- Text='<%#Eval("id")%>'-- %>
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Label ID="Label2" runat="server" Text="Event Name : "></asp:Label>
                            <asp:TextBox ID="txtEventName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ValidationGroup="Submit"
                                runat="server" ControlToValidate="txtEventName" ForeColor="Red" ErrorMessage="Please Enter Event Name" Display="None">                                 
                            </asp:RequiredFieldValidator>
                            <br />
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Label ID="Label3" runat="server" Text="Event Date   :  "></asp:Label>
                            <% --<asp:Label ID="lblPhone" runat="server"></asp:Label><br />-- %>
                            &nbsp;&nbsp;<asp:TextBox ID="txtHolidayDate" CssClass="date" onkeypress="return false" MaxLength="10"
                                TabIndex="1" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ValidationGroup="Submit" runat="server"
                                ControlToValidate="txtHolidayDate" ForeColor="Red" ErrorMessage="Please Enter Event Date" Display="None">
                            </asp:RequiredFieldValidator>


                            <br />
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Label ID="lblApplicant" runat="server" Text="Name of Applicant : " Visible="false"></asp:Label>
                            <asp:Label ID="lblAplicantfirstName" runat="server" Visible="false"></asp:Label>
                            <asp:LinkButton ID="lbtLastName" runat="server" OnClick="lbtLastName_Click" Visible="false"></asp:LinkButton>

                            <br />
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Label ID="lblPhone" runat="server" Text="Phone Number: " Visible="false"></asp:Label>
                            <asp:Label ID="lblPhoneNo" runat="server" Visible="false"></asp:Label>

                            <br />
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Label ID="lblDesigna" runat="server" Text="Designation: " Visible="false"></asp:Label>
                            <asp:Label ID="lblDesignation" runat="server" Visible="false"></asp:Label>

                            <br />
                            <br />
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Label ID="lblAdded" runat="server" Text="Added By: " Visible="false"></asp:Label>
                            <asp:Label ID="lblAddedBy" runat="server" Visible="false"></asp:Label>
                            <br />
                            <br />

                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="btnsave" runat="server" ValidationGroup="Submit" OnClick="btnsave_Click" Text="Update" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" Height="30px" Width="75px" />
                            &nbsp; &nbsp;
                            <asp:Button ID="btnDelete" runat="server" ValidationGroup="Submit" Text="Delete" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" Height="30px" Width="75px" OnClick="btnDelete_Click" />
                            &nbsp; &nbsp;&nbsp; &nbsp;
                            <asp:Button ID="btnClose" runat="server" OnClick="btnClose_Click" Text="Close" Style="background: url(img/main-header-bg.png) repeat-x; color: #fff;" Height="30px" Width="75px" />
                           
                        </ContentTemplate>--%>
                         
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
           

        </ContentTemplate>
          
    </asp:UpdatePanel>

    <asp:Panel ID="panel1" runat="server">
        <div id="DivOfferMade" class="white_content" style="height: auto;">
            <h3>Offer Made Details</h3>
            <a href="javascript:void(0)" onclick="document.getElementById('DivOfferMade').style.display='none';document.getElementById('DivOfferMadefade').style.display='none'">Close</a>
            <asp:HiddenField ID="hidSelectedVal" runat="server" />
            <asp:HiddenField ID="hidApplicantID" runat="server" />
            <asp:UpdatePanel runat="server" UpdateMode="Always"><ContentTemplate>
            <table width="100%" style="border: Solid 3px #b04547; width: 100%; height: 300px;"
                cellpadding="0" cellspacing="0">
                <tr>
                    <td align="right" style="height: 15px;">
                        <br />
                        <label>
                            Email<span><asp:Label ID="lblOfferEmail" Text="*" runat="server" ForeColor="Red"></asp:Label></span></label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtOfferMail" runat="server" MaxLength="40" Width="242px"
                            Enabled="false" ReadOnly="true"></asp:TextBox>
                        <br />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" Display="Dynamic" runat="server" ControlToValidate="txtOfferMail"
                            ValidationGroup="OfferPopUp" ForeColor="Red" ErrorMessage="Please Enter Email"></asp:RequiredFieldValidator>
                        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" ControlToValidate="txtOfferMail" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                            Display="Dynamic" runat="server" ForeColor="Red" ErrorMessage="Please Enter a valid Email"
                            ValidationGroup="OfferPopUp">
                        </asp:RegularExpressionValidator>
                    </td>
                </tr>
                <tr>
                    <td align="right" style="height: 15px;">
                        <label>
                            Password<asp:Label ID="lblOfferPassword" runat="server" Text="*" ForeColor="Red"></asp:Label></label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtOfferPassword" runat="server" TextMode="Password" MaxLength="30"
                            autocomplete="off" Width="242px"></asp:TextBox>
                        <br />
                        <label>
                        </label>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="txtOfferPassword"
                            ValidationGroup="OfferPopUp" ForeColor="Red" Display="Dynamic" ErrorMessage="Please Enter Password"></asp:RequiredFieldValidator><br />
                    </td>
                </tr>
                <tr>
                    <td align="right" style="height: 15px;">
                        <label>
                            Confirm Password<asp:Label ID="Label4" runat="server" Text="*" ForeColor="Red"></asp:Label></label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtOfferConPassword" runat="server" TextMode="Password" autocomplete="off"
                            MaxLength="30" EnableViewState="false" AutoCompleteType="None" Width="242px"></asp:TextBox>
                        <br />
                        <label>
                        </label>
                        <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="txtOfferConPassword"
                            Display="Dynamic" ControlToCompare="txtOfferPassword" ForeColor="Red" ErrorMessage="Password didn't matched"
                            ValidationGroup="OfferPopUp">
                        </asp:CompareValidator>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="txtOfferConPassword"
                            ForeColor="Red" ValidationGroup="OfferPopUp" ErrorMessage="Enter Confirm Password"></asp:RequiredFieldValidator>

                    </td>
                </tr>
                <tr>
                    <td align="center" colspan="2">
                        <asp:Button ID="btnSaveOfferMade" runat="server" BackColor="#327FB5" ForeColor="White" Height="32px"
                            Style="height: 26px; font-weight: 700; line-height: 1em;" Text="Save" Width="100px" ValidationGroup="OfferPopUp"
                            TabIndex="119" OnClick="btnSaveOfferMade_Click" />
                        <%--<asp:Button ID="Button2" runat="server" OnClick="" />--%>
                    </td>
                </tr>
            </table>
                </ContentTemplate></asp:UpdatePanel>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlReScheduleInterviewDate" runat="server">
        <div id="interviewDatelite" class="white_content" style="height: auto;">
            <h3>Interview Details</h3>            
            <asp:UpdatePanel runat="server" UpdateMode="Always">
                <ContentTemplate>
            <table width="100%" style="border: Solid 3px #b04547; width: 100%; height: 300px;"
                cellpadding="0" cellspacing="0">
                <tr>
                    <td align="center" style="height: 15px;">Re-Schedule Date :
                    <asp:TextBox ID="dtInterviewDate" placeholder="Select Date" runat="server" ClientIDMode="Static" onkeypress="return false" TabIndex="104" Width="127px"></asp:TextBox>
                        <cc1:CalendarExtender ID="CalendarExtender1" TargetControlID="dtInterviewDate" Format="MM/dd/yyyy" runat="server"></cc1:CalendarExtender>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Select Date" ControlToValidate="dtInterviewDate" ValidationGroup="InterviewDate"></asp:RequiredFieldValidator>
                    </td>
                    <td align="center"></td>
                    <td>Re-Schedule Time :
                        <asp:DropDownList ID="ddlInsteviewtime" runat="server" TabIndex="105" Width="112px"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td  align="right">Recruiter</td>
                    <td> : </td>
                    <td align="left" >
                        <asp:DropDownList ID="ddlUsers" runat="server" />
                        <asp:RequiredFieldValidator ID="rfvddlUsers" runat="server" ErrorMessage="Select Recruiter" ControlToValidate="ddlUsers" 
                            ValidationGroup="InterviewDate" InitialValue="0" />
                    </td>
                </tr>
                <tr>
                    <td  align="right">Task</td>
                    <td> : </td>
                    <td align="left">
                        <asp:DropDownList ID="ddlTechTask" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td align="right">Current Assigned Task</td>
                    <td>:</td>
                    <td align="left">
                        <b>
                            <asp:Label ID="lblCurrentTask" runat="server"></asp:Label>
                        </b>
                    </td>
                </tr>
                <tr>
                    <td align="center" colspan="3">

                        
                        <asp:Button ID="btnSaveInterview" runat="server" BackColor="#327FB5" ForeColor="White" Height="32px"
                            Style="height: 26px; font-weight: 700; line-height: 1em;" Text="OK" Width="100px" ValidationGroup="InterviewDate"
                            TabIndex="119" OnClick="btnSaveInterview_Click" />
                        <input type="button" value="Cancel" onclick="overlayInterviewDate_Close()" style="Width:100px;height: 26px; font-weight: 700; line-height: 1em;" />                        
                    </td>
                </tr>
            </table>
                    </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </asp:Panel>
    <div id="interviewDatefade" class="black_overlay">
    </div>
    <div id="DivOfferMadefade" class="black_overlay">
    </div>

    
    <asp:ValidationSummary ID="ValidationSummary2" runat="server" ValidationGroup="SubmitEvent" ShowSummary="False" ShowMessageBox="True" />
    <asp:ValidationSummary ID="ValidationSummary3" runat="server" ValidationGroup="SubmitCalendar" ShowSummary="False" ShowMessageBox="True" />
    <asp:ValidationSummary ID="ValidationSummary1" runat="server" ValidationGroup="Submit" ShowSummary="False" ShowMessageBox="True" />
</asp:Content>

