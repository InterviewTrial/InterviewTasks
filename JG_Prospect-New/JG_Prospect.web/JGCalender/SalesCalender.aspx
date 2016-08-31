<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SalesCalender.aspx.cs" Inherits="JG_Prospect.JGCalender.SalesCalender" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="css/cupertino/jquery-ui-1.10.3.min.css" rel="stylesheet" type="text/css" />
    <link href="fullcalendar/fullcalendar.css" rel="stylesheet" type="text/css" />
    <link href="css/jquery.qtip-2.2.0.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
    <link href="datetime/css/stylesheet.css" rel="stylesheet" type="text/css" />

    <script src="jquery/moment-2.8.1.min.js" type="text/javascript"></script>
    <script src="jquery/jquery-2.1.1.js" type="text/javascript"></script>
    <script src="jquery/jquery-ui-1.11.1.js" type="text/javascript"></script>
    <script src="jquery/jquery.qtip-2.2.0.js" type="text/javascript"></script>
    <script src="fullcalendar/fullcalendar-2.6.0.js" type="text/javascript"></script>
    <script src="scripts/calendarscript.js" type="text/javascript"></script>
    <script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=false&libraries=places&key=AIzaSyCKkBhvDXVd3K53AdMRXjbKpE0utScfWZM"></script>

    <style type='text/css'>
        body {
            margin-top: 40px;
            text-align: center;
            font-size: 14px;
            font-family: "Lucida Grande",Helvetica,Arial,Verdana,sans-serif;
        }

        .calender-header {
            padding-bottom: 60px;
        }

        #calendar {
            /*width: 900px;*/
            /*margin: 0 auto;*/
        }
        /* css for timepicker */
        .ui-timepicker-div dl {
            text-align: left;
        }

            .ui-timepicker-div dl dt {
                height: 25px;
            }

            .ui-timepicker-div dl dd {
                margin: -25px 0 10px 65px;
            }

        .style1 {
            width: 100%;
        }

        /* table fields alignment*/
        .alignRight {
            text-align: right;
            padding-right: 10px;
            padding-bottom: 10px;
        }

        .alignLeft {
            text-align: left;
            padding-bottom: 10px;
        }

        .caret-right {
            width: 0;
            height: 0;
            border-top: 4px solid rgba(0, 0, 0, 0);
            border-bottom: 4px solid rgba(0, 0, 0, 0);
            border-left: 4px solid #777777;
        }

        .dropdown-menu > li {
            padding-left: 10px;
        }

        dropdown-menu .divider1 {
            height: 1px;
            margin: 5px 0 !important;
            overflow: hidden;
            background-color: #e5e5e5;
            /*DropDown Menu Employees*/
        }

        .customer-check-box {
            margin-right: 5px;
        }

        input[type=checkbox] {
            margin: 4px 10px 0;
            margin-top: 1px\9;
            line-height: normal;
        }

        .fc-time-grid .fc-event {
            overflow: auto;
        }

        .fc-time-grid .fc-slats td {
            height: 3em;
        }

        .fc-time {
            display: none;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true">
        </asp:ScriptManager>
        <asp:HiddenField ID="hdnCustomerIds" runat="server" />
        <div id="calendar" style="height: 100%; overflow: visible">
        </div>
        <div class="col-sm-12">
            <div class="divmap" id="dvMap" style="width: 50%; height: 300px; margin-top: 20px; margin-left: 20px; margin-bottom: 20px; float: left">
            </div>
            <div style="float: right; margin-right: 20px; margin-bottom: 20px; width: 25%; height: 300px; margin-top: 20px;">
                <div class="date dateCalender" id="datepicker"></div>
            </div>
        </div>

        <div style="float: left; width: 100%; padding: 0 0 0 10px;">

            <div style="float: left; width: 45%">
                <table style="font-family: Verdana; font-size: small;" width="100%">
                    <tbody>
                        <tr>
                            <td style="font-family: Verdana; font-size: 11pt; color: red;">
                                <b>A:</b><textarea name="txtFromLocation" rows="2" cols="10" id="txtFromLocation" style="color: Black; width: 93%;">3502 Scotts Ln Philadelphia, PA 19129</textarea>
                                <br />
                                <br />
                                <b>B:</b><textarea name="txtToLocation" rows="2" cols="10" id="txtToLocation" style="color: Black; width: 93%;"></textarea>
                                <br />
                                <div class="btn_sec">
                                    <input type="button" name="btnGetDirection" value="Get Direction" id="btnGetDirection" onclick="GetRoute();" tabindex="3" style="height: 40px; width: 190px; margin: 6px 17px;" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div id="direction_steps_holder" style="width: 100%">
                                    <div id="dvDistance" style="padding: 5px;">
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div id="updatedialog" style="font: 70% 'Trebuchet MS', sans-serif; margin: 50px; display: none;"
            title="Update or Delete Event">
            <table cellpadding="0" class="style1">
                <tr>
                    <td class="alignRight">Customer ID:</td>
                    <td class="alignLeft"><span id="txtCustID"></span></td>
                </tr>
                <tr>
                    <td class="alignRight">Last Name:</td>
                    <td class="alignLeft"><span id="txtlstName"></span></td>
                </tr>
                <tr>
                    <td class="alignRight">Primary Phone #:</td>
                    <td class="alignLeft"><span id="spnPrimaryPhone"></span></td>
                </tr>
                <tr>
                    <td class="alignRight">Address:</td>
                    <td class="alignLeft"><span id="spnAddress"></span></td>
                </tr>
                <tr>
                    <td class="alignRight">Zip:</td>
                    <td class="alignLeft"><span id="spnZip"></span></td>
                </tr>
                <tr style="display: none">
                    <td class="alignRight">Description:</td>
                    <td class="alignLeft">
                        <textarea id="eventDesc" disabled="disabled" cols="30" rows="3"></textarea></td>
                </tr>
                <tr>
                    <td class="alignRight">Status:</td>
                    <td class="alignLeft">
                        <select name="eventStatus" id="eventStatus">
                            <option value="0">Select</option>
                            <option value="Set">Set</option>
                            <option value="Prospect">Prospect</option>
                            <option selected="selected" value="est>$1000">est&gt;$1000</option>
                            <option value="est<$1000">est&lt;$1000</option>
                            <option value="sold>$1000">sold&gt;$1000</option>
                            <option value="sold<$1000">sold&lt;$1000</option>
                            <option value="Closed (not sold)">Closed (not sold)</option>
                            <option value="Closed (sold)">Closed (sold)</option>
                            <option value="Rehash">Rehash</option>
                            <option value="cancelation-no rehash">cancelation-no rehash</option>

                        </select></td>
                </tr>
                <tr>
                    <td class="alignRight">Product Line:</td>
                    <td class="alignLeft">
                        <span id="spnProductLine"></span></td>
                </tr>
                <tr>
                    <td class="alignRight">Start:</td>
                    <td class="alignLeft">
                        <span id="eventStart"></span></td>
                </tr>
                <tr>
                    <td class="alignRight">End: </td>
                    <td class="alignLeft">
                        <span id="eventEnd"></span>
                        <input type="hidden" id="eventId" /></td>
                </tr>
                <tr>
                    <td class="alignRight">Added By:</td>
                    <td class="alignLeft">
                        <span id="spnAddedBy"></span></td>
                </tr>
            </table>
        </div>


        <div id="NewEventDialog" style="font: 70% 'Trebuchet MS', sans-serif; margin: 50px; display: none;" title="Create New Event">
            <label id="addEventStartDate" style="display: none"></label>
            <label id="addEventEndDate" style="display: none"></label>
            <ul class="nav navbar-nav">
                <li>
                    <a>
                        <label>
                            <input type='radio' id="chkExisting" name="chkNewEvent" value="Existing" checked="checked" />Existing Customer
                       
                        </label>
                    </a>
                </li>
                <li>
                    <a>
                        <label>
                            <input type="radio" id="chkNew" name="chkNewEvent" value="New" />New Customer
                       
                        </label>
                    </a>
                </li>
                <li>
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">Sales Calendar <b class="caret"></b></a>
                    <ul id="ul-customer" class="dropdown-menu" style="width: 250px; height: 250px; overflow-y: scroll;">
                </li>
            </ul>
        </div>
        <div runat="server" id="jsonDiv" />
        <input type="hidden" id="hdClient" runat="server" />
    </form>

    <script type="text/javascript">
        var source, destination;
        var directionsDisplay;
        var directionsService = new google.maps.DirectionsService();

        google.maps.event.addDomListener(window, 'load', function () {
            new google.maps.places.SearchBox(document.getElementById('txtFromLocation'));
            new google.maps.places.SearchBox(document.getElementById('txtToLocation'));
            directionsDisplay = new google.maps.DirectionsRenderer({ 'draggable': true });
        });
        function GetRoute() {
            var philadelphia = new google.maps.LatLng(39.9526, 75.1652);
            var mapOptions = {
                zoom: 7,
                center: philadelphia
            };

            map = new google.maps.Map(document.getElementById('dvMap'), mapOptions);
            directionsDisplay.setMap(map);

            //directionsDisplay.setPanel(document.getElementById('dvPanel'));

            //*********DIRECTIONS AND ROUTE**********************//
            source = document.getElementById("txtFromLocation").value;
            destination = document.getElementById("txtToLocation").value;

            var request = {
                origin: source,
                destination: destination,
                travelMode: google.maps.TravelMode.DRIVING
            };
            directionsService.route(request, function (response, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    directionsDisplay.setDirections(response);
                }
            });

            //*********DISTANCE AND DURATION**********************//
            var service = new google.maps.DistanceMatrixService();
            service.getDistanceMatrix({
                origins: [source],
                destinations: [destination],
                travelMode: google.maps.TravelMode.DRIVING,
                unitSystem: google.maps.UnitSystem.METRIC,
                avoidHighways: false,
                avoidTolls: false
            }, function (response, status) {
                if (status == google.maps.DistanceMatrixStatus.OK && response.rows[0].elements[0].status != "ZERO_RESULTS") {
                    var distance = response.rows[0].elements[0].distance.text;
                    var duration = response.rows[0].elements[0].duration.text;
                    var dvDistance = document.getElementById("dvDistance");
                    dvDistance.innerHTML = "";
                    dvDistance.innerHTML += "Distance: " + distance + "<br />";
                    dvDistance.innerHTML += "Duration:" + duration;

                } else {
                    alert("Unable to find the distance.");
                }
            });

        }

        Date.prototype.yyyymmdd = function () {
            var yyyy = this.getFullYear().toString();
            var mm = (this.getMonth() + 1).toString();
            var dd = this.getDate().toString();
            return yyyy + "-" + (mm[1] ? mm : "0" + mm[0]) + "-" + (dd[1] ? dd : "0" + dd[0]);
        };

        var isExisting = true;
        $(document).ready(function () {

            $('#datepicker').datepicker({
                dateFormat: 'DD, d MM, yy',
                inline: true,
                onSelect: function (dateText, inst) {
                    var d = new Date(dateText);
                    var date = d.yyyymmdd();
                    parent.FullCalenderPerformCallback(date);
                }
            });

            if (getParameterByName('d').toString() != "") {
                $('#datepicker').datepicker("setDate", new Date(getParameterByName('d')));
            }

            var eIds = getParameterByName('e');
            $.ajax({
                url: "JsonResponse.ashx?eids=" + eIds,
                type: "GET",
                async: false,
                success: function (data) {
                    var map;
                    debugger
                    var elevator;
                    var test = $.parseJSON(data);
                    if (test.toString() != "") {
                        try {
                            var myOptions = {
                                zoom: 6,
                                center: new google.maps.LatLng(test[0].Latitude, test[0].Longitude),
                            };

                            map = new google.maps.Map($('#dvMap')[0], myOptions);

                            for (var x = 0; x < test.length; x++) {
                                var latlng = new google.maps.LatLng(test[x].Latitude, test[x].Longitude);
                                new google.maps.Marker({
                                    position: latlng,
                                    map: map
                                });
                            }
                        }
                        catch (ex) {
                            alert(ex);
                        }
                    }
                },
            });


            // update Dialog
            $('#updatedialog').dialog({
                autoOpen: false,
                width: 470,
                buttons: {
                    "update": function () {

                        var eventToUpdate = {
                            id: currentUpdateEvent.id,

                            status: $("#eventStatus").val()
                        };

                        if (checkForSpecialChars(eventToUpdate.title) || checkForSpecialChars(eventToUpdate.description)) {
                            alert("please enter characters: A to Z, a to z, 0 to 9, spaces");
                        }
                        else {
                            PageMethods.UpdateEvent(eventToUpdate, updateSuccess);
                            $(this).dialog("close");
                            // loadCalender();
                            location.reload();

                        }

                    }

                }
            });


            // new Dialog
            $('#NewEventDialog').dialog({
                autoOpen: false,
                width: 470,
                height: 450
            });

            var date = new Date();
            var d = date.getDate();
            var m = date.getMonth();
            var y = date.getFullYear();
            var options = {
                weekday: "long", year: "numeric", month: "short",
                day: "numeric", hour: "2-digit", minute: "2-digit"
            };


            LoadCalender();


            function formatDate(date) {
                var hours = date.getHours();
                var minutes = date.getMinutes();
                var ampm = hours >= 12 ? 'pm' : 'am';
                hours = hours % 12;
                hours = hours ? hours : 12; // the hour '0' should be '12'
                minutes = minutes < 10 ? '0' + minutes : minutes;
                var strTime = hours + ':' + minutes + ' ' + ampm;
                return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
            }

            $('.navbar a.dropdown-toggle').on('click', function (e) {
                var elmnt = $(this).parent().parent();
                if (!elmnt.hasClass('nav')) {
                    var li = $(this).parent();
                    var heightParent = parseInt(elmnt.css('height').replace('px', '')) / 2;
                    var widthParent = parseInt(elmnt.css('width').replace('px', '')) - 10;

                    if (!li.hasClass('open')) li.addClass('open')
                    else li.removeClass('open');
                    $(this).next().css('top', heightParent + 'px');
                    $(this).next().css('left', widthParent + 'px');

                    return false;
                }
            });

            $.getJSON("Customer.ashx?type=customer", function (data) {

                var items = [];
                $.each(data, function (key, val) {
                    // items.push("<li id='" + key + "'>" + val + "</li>");
                    items.push("  <li class='divider'></li> <li class='li-emp'><input type='checkbox' class='customer-check-box' customer_id='" + val.id + "' id='chk_" + val.id + "' />" + val.name + "</li>");
                });


                $("#ul-customer").append(items.join(""));
                $('.customer-check-box').on('click', function () {

                    var addEventStartDate = formatDate(new Date($("#addEventStartDate").text()))
                    var addEventEndDate = $("#addEventEndDate").text();

                    if (isExisting) {
                        var customers = [];
                        if ($('#hdnCustomerIds').val() !== '')
                            customers = JSON.parse($('#hdnCustomerIds').val());
                        if (this.checked) {
                            customers.push($(this).attr('customer_id'))
                            $('#hdnCustomerIds').val(JSON.stringify(customers));

                            window.top.location.href = "../Sr_App/Customer_Profile.aspx?CustomerId=" + $(this).attr('customer_id') + "&es=" + addEventStartDate + "&ee=" + addEventEndDate;
                        }
                    }
                });
            });

            $('input[name=chkNewEvent]').on('change', function () {

                var addEventStartDate = formatDate(new Date($("#addEventStartDate").text()))
                var addEventEndDate = $("#addEventEndDate").text();

                ClearCustomerCheckBox();
                var chkBox = $('input[name=chkNewEvent]:checked').val();
                ClearCustomerCheckBox();
                if (chkBox == 'Existing') {
                    isExisting = true;
                }
                if (chkBox == 'New') {
                    isExisting = false;
                    //window.location.href = "../Sr_App/new_customer.aspx";
                    //$(location).attr("href", "../Sr_App/new_customer.aspx");
                    window.top.location.href = "../Sr_App/new_customer.aspx?es=" + addEventStartDate + "&ee=" + addEventEndDate;
                }

            });

        });

        function ClearCustomerCheckBox() {
            $('input:checkbox.customer-check-box').each(function () {
                if (this.checked)
                    this.checked = false;
            });
        }

        function GetWay() {

            var philadelphia = new google.maps.LatLng(39.9526, 75.1652);
            var mapOptions = {
                zoom: 7,
                center: philadelphia
            };

            map = new google.maps.Map(document.getElementById('dvMap'), mapOptions);
            directionsDisplay.setMap(map);

            //directionsDisplay.setPanel(document.getElementById('dvPanel'));

            //*********DIRECTIONS AND ROUTE**********************//
            source = "3502 Scotts Ln Philadelphia, PA 19129";
            destination = "New York";

            var request = {
                origin: source,
                destination: destination,
                travelMode: google.maps.TravelMode.DRIVING
            };
            directionsService.route(request, function (response, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    directionsDisplay.setDirections(response);
                }
            });

            //*********DISTANCE AND DURATION**********************//
            var service = new google.maps.DistanceMatrixService();
            service.getDistanceMatrix({
                origins: [source],
                destinations: [destination],
                travelMode: google.maps.TravelMode.DRIVING,
                unitSystem: google.maps.UnitSystem.METRIC,
                avoidHighways: false,
                avoidTolls: false
            }, function (response, status) {
                if (status == google.maps.DistanceMatrixStatus.OK && response.rows[0].elements[0].status != "ZERO_RESULTS") {
                    var distance = response.rows[0].elements[0].distance.text;
                    var duration = response.rows[0].elements[0].duration.text;
                    //var dvDistance = document.getElementById("dvDistance");
                    //dvDistance.innerHTML = "";
                    //dvDistance.innerHTML += "Distance: " + distance + "<br />";
                    //dvDistance.innerHTML += "Duration:" + duration;

                } else {
                    alert("Unable to find the distance.");
                }
            });
        }

        var currentUpdateEvent;
        var addStartDate;
        var addEndDate;
        var globalAllDay;

        function updateEvent(event, element) {

            if ($(this).data("qtip")) $(this).qtip("destroy");

            currentUpdateEvent = event;
            $('#updatedialog').dialog('open');
            $("#eventName").val(event.title);
            $("#eventDesc").val(event.description);
            $("#eventId").val(event.id);
            $("#eventStart").text("" + event.start.toLocaleString());
            $("#eventStatus").val(event.status);

            $("#txtCustID").text(event.customerid);

            $("#txtlstName").text(event.lastname);
            $("#spnPrimaryPhone").text(event.primarycontact);
            $("#spnAddress").text(event.address);
            $("#spnZip").text(event.zipcode);
            $("#spnProductLine").text(event.productline);
            $("#spnAddedBy").text(event.addedby);

            if (event.end === null) {
                $("#eventEnd").text("");
            }
            else {
                $("#eventEnd").text("" + event.end.toLocaleString());
            }

            return false;
        }

        function updateSuccess(updateResult) {
        }

        function deleteSuccess(deleteResult) {
        }

        function addSuccess(addResult) {

            if (addResult != -1) {
                $('#calendar').fullCalendar('renderEvent',
                                {
                                    title: $("#addEventName").val(),
                                    start: addStartDate,
                                    end: addEndDate,
                                    id: addResult,
                                    description: $("#addEventDesc").val(),
                                    allDay: globalAllDay
                                },
                                true
                            );


                $('#calendar').fullCalendar('unselect');
            }
        }

        function UpdateTimeSuccess(updateResult) {
        }

        function selectDate(start, end, allDay) {

            $('#NewEventDialog').dialog('open');
            $("#addEventStartDate").text("" + start.toLocaleString());
            $("#addEventEndDate").text("" + end.toLocaleString());
        }

        function updateEventOnDropResize(event, allDay) {
            var eventToUpdate = {
                id: event.id,
                start: event.start
            };

            if (event.end === null) {
                eventToUpdate.end = eventToUpdate.start;
            }
            else {
                eventToUpdate.end = event.end;
            }
            var endDate;
            if (!event.allDay) {
                endDate = new Date(eventToUpdate.end + 60 * 60000);
                endDate = endDate.toJSON();
            }
            else {
                endDate = eventToUpdate.end.toJSON();
            }

            eventToUpdate.start = eventToUpdate.start.toJSON();
            eventToUpdate.end = eventToUpdate.end.toJSON(); //endDate;
            eventToUpdate.allDay = event.allDay;

            PageMethods.UpdateEventTime(eventToUpdate, UpdateTimeSuccess);
        }

        function eventDropped(event, dayDelta, minuteDelta, allDay, revertFunc) {
            if ($(this).data("qtip")) $(this).qtip("destroy");
            updateEventOnDropResize(event);
        }

        function eventResized(event, dayDelta, minuteDelta, revertFunc) {
            if ($(this).data("qtip")) $(this).qtip("destroy");

            updateEventOnDropResize(event);
        }

        function checkForSpecialChars(stringToCheck) {
            var pattern = /[^A-Za-z0-9 ]/;
            return false;

            return pattern.test(stringToCheck);
        }

        function isAllDay(startDate, endDate) {
            var allDay;

            if (startDate.format("HH:mm:ss") == "00:00:00" && endDate.format("HH:mm:ss") == "00:00:00") {
                allDay = true;
                globalAllDay = true;
            }
            else {
                allDay = false;
                globalAllDay = false;
            }

            return allDay;
        }

        function qTipText(start, end, description) {
            var text;

            if (end !== null)
                text = "<strong>Start:</strong> " + start.format("MM/DD/YYYY hh:mm T") + "<br/><strong>End:</strong> " + end.format("MM/DD/YYYY hh:mm T") + "<br/><br/>" + description;
            else
                text = "<strong>Start:</strong> " + start.format("MM/DD/YYYY hh:mm T") + "<br/><strong>End:</strong><br/><br/>" + description;

            return text;
        }
        function getParameterByName(name) {
            name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
            var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                results = regex.exec(location.search);
            return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
        }

        // to save the selected status on change the dropdown value from event
        function OnchangeEventStatus(obj, Id) {
            var eventToUpdate = {
                id: Id,
                //  title: $("#eventName").val(),
                //description: $("#eventDesc").val(),
                status: $(obj).val()
            };
            if (checkForSpecialChars(eventToUpdate.title) || checkForSpecialChars(eventToUpdate.description)) {
                alert("please enter characters: A to Z, a to z, 0 to 9, spaces");
            }
            else {
                PageMethods.UpdateEvent(eventToUpdate, updateSuccess);
                location.reload();
            }
        }

        function LoadCalender() {
            var dateDefault = null;
            var viewDefault = 'agendaWeek'
            if (getParameterByName('d') != undefined && getParameterByName('d') != '') {
                dateDefault = getParameterByName('d');
                viewDefault = 'agendaDay';
            }
            var eIds = getParameterByName('e');
            var searchText = getParameterByName('s');

            $('#calendar').fullCalendar({
                theme: true,
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay,agendaFourDay'
                },

                views: {
                    agendaFourDay: {
                        type: 'agenda',
                        duration: { days: 4 },
                        buttonText: '4 day'
                    },
                },

                defaultView: viewDefault,
                allDaySlot: false,
                selectable: true,
                selectHelper: true,
                select: selectDate,
                editable: false,
                eventMouseover: function (data, event, view) {
                    GetUserWay(data.CommonAddress);
                },
                events: "JsonResponse.ashx?eids=" + eIds + "&searchText=" + searchText,
                defaultDate: dateDefault,
                eventDrop: eventDropped,
                eventResize: eventResized,
                eventClick: function (calEvent, jsEvent, view) {
                    window.top.location.href = "../Sr_App/Customer_Profile.aspx?CustomerId=" + calEvent.customerid;
                },
                eventRender: function (event, element, view) {
                    // to bind link inside event
                    $(element).find('.fc-title').prepend('<a href="javascript:void(0);" class="event-link" style="color:#fff;text-decoration: none;border-bottom: 1px solid #fff;">' + event.customerid + ',</a>');
                    // to bind dropdown inside event
                    $(element).find('.fc-title').append('<select class="event-dropdown" id="event-dropdown-' + event.id + '" style="color:black;width:96%" onchange="OnchangeEventStatus(this,' + event.id + ')">' +
                                '<option value="0">Select</option>' +
                                '<option value="Set">Set</option>' +
                                '<option value="Prospect">Prospect</option>' +
                                '<option selected="selected" value="est>$1000">est&gt;$1000</option>' +
                                '<option value="est<$1000">est&lt;$1000</option>' +
                                '<option value="sold>$1000">sold&gt;$1000</option>' +
                                '<option value="sold<$1000" >sold&lt;$1000</option>' +
                                '<option value="Closed (not sold)">Closed (not sold)</option>' +
                                '<option value="Closed (sold)">Closed (sold)</option>' +
                                '<option value="Rehash">Rehash</option>' +
                                '<option value="cancelation-no rehash">cancelation-no rehash</option></select>');

                    //stop click event for the dropdown,
                    $(element).find('.event-dropdown').click(function (e) {
                        e.stopImmediatePropagation();
                    });
                    //stop click event for link and redirect to customer profile
                    $(element).find('.event-link').click(function (e) {
                        e.stopImmediatePropagation();
                        window.top.location.href = "/Sr_App/Customer_Profile.aspx?CustomerId=" + event.customerid;
                    });
                    element.qtip({
                        content: {
                            text: qTipText(event.start, event.end, event.description),
                            title: '<strong>' + event.title + '</strong>'
                        },
                        position: {
                            my: 'bottom left',
                            at: 'top right'
                        },
                        style: { classes: 'qtip-shadow qtip-rounded' }
                    });
                },
                eventAfterRender: function (event, element, view) {
                    $('#event-dropdown-' + event.id + '').val(event.status); // to show the selected status on bind event                
                }
            });

        }

        function GetUserWay(Destination) {

            var source, destination;
            var directionsDisplay;
            var directionsService = new google.maps.DirectionsService();

            directionsDisplay = new google.maps.DirectionsRenderer({ 'draggable': true });
            //debugger
            var philadelphia = new google.maps.LatLng(39.9526, 75.1652);
            var mapOptions = {
                zoom: 7,
                center: philadelphia
            };


            map = new google.maps.Map(document.getElementById('dvMap'), mapOptions);
            directionsDisplay.setMap(map);

            //directionsDisplay.setPanel(document.getElementById('dvPanel'));

            //*********DIRECTIONS AND ROUTE**********************//
            source = "3502 Scotts Ln Philadelphia, PA 19129";
            destination = Destination;

            var request = {
                origin: source,
                destination: destination,
                travelMode: google.maps.TravelMode.DRIVING
            };
            directionsService.route(request, function (response, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    directionsDisplay.setDirections(response);
                }
            });

            //*********DISTANCE AND DURATION**********************//
            var service = new google.maps.DistanceMatrixService();
            service.getDistanceMatrix({
                origins: [source],
                destinations: [destination],
                travelMode: google.maps.TravelMode.DRIVING,
                unitSystem: google.maps.UnitSystem.METRIC,
                avoidHighways: false,
                avoidTolls: false
            }, function (response, status) {
                if (status == google.maps.DistanceMatrixStatus.OK && response.rows[0].elements[0].status != "ZERO_RESULTS") {
                    var distance = response.rows[0].elements[0].distance.text;
                    var duration = response.rows[0].elements[0].duration.text;
                    var dvDistance = document.getElementById("dvDistance");
                    dvDistance.innerHTML = "";
                    dvDistance.innerHTML += "Distance: " + distance + "<br />";
                    dvDistance.innerHTML += "Duration:" + duration;
                } else {
                    alert("Unable to find the distance.");
                }
            });
        }


    </script>
</body>
</html>
