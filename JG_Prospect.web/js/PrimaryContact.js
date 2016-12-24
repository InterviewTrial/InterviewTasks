function BindPrimaryContact() {
    debugger;
    $.ajax({
        type: "POST",
        url: "Customer_Profile.aspx/GetPrimaryContact",
        data: '{}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            debugger;
            var Data = response.d.split('^@');
            var result = JSON.parse(Data[0]);
            var PrimaryProduct = JSON.parse(Data[1]);
            var SecondaryProduct = JSON.parse(Data[2]);
            var ContactTime = JSON.parse(Data[3]);
            var BillingAddressValue = JSON.parse(Data[4]);
            var licount;
            var childCount = "";
            var chdCount = 0;

            $.each(result, function (key, value) {
                debugger;
                //Top Grid
                licount = key + 1;

                if (value.FName == "" && value.LName == "" && value.strContactType == "") {
                    chdCount++;
                    if (childCount == "") {
                        childCount = licount - 1;
                    }

                    if (value.PhoneType != "" || value.PhoneNumber != "") {
                        $("#tblPhone" + childCount + " tr:last").before("<tr><td class='paddingtd'></td>" +
                          "<td><input type='text' clientidmode='Static' onblur='CheckDuplicatePhone(this);' id='txtPhone" + licount + chdCount + "' name='nametxtPhone" + licount + chdCount + "' data-type='" + licount + "' tabindex='7' class='clsMaskPhone'  placeholder='___-___-____' /></td>" +
                          "<td><label class='clsFullWidth'>Phone Type</label></td><td>" +
                          "<select class='clsFullWidth' id='selPhoneType" + licount + chdCount + "' name='nameselPhoneType" + licount + chdCount + "' data-type='" + licount + "' clientidmode='Static' tabindex='4'>" +
                          "<option value='0'>Select</option><option value='CellPhone'>Cell Phone #</option><option value='HousePhone'>House Phone #</option><option value='WorkPhone'>Work Phone #</option><option value='AltPhone'>Alt. Phone #</option>" +
                          "</select></td></tr>");
                        $("#txtPhone" + licount + chdCount).val(value.PhoneNumber);
                        $("#selPhoneType" + licount + chdCount).val(value.PhoneType);

                    }
                    if (value.EMail != "") {
                        $("#tblEmail" + childCount + " tr:last").before("<tr><td class='paddingtd'></td>" +
                            "<td><input type='text' clientidmode='Static' onblur='CheckDuplicateEmail(this)' id='txtEMail" + licount + chdCount + "' name='nametxtEMail" + licount + chdCount + "' data-type='" + licount + "' tabindex='7'  placeholder='EMail' /></td></tr>");
                        $("#txtEMail" + licount + chdCount).val(value.EMail);
                    }
                }
                else {

                    $('input[id*="btnParent"]').css('visibility', 'hidden');

                    var strChecked = "";
                    if (licount == 1) {
                        var strChecked = "checked = 'checked'";
                    }

                    $("#divPrimaryContact ul li:last").after("<li style='width: 100%;'><div class='tblPrimaryContact' style='margin-top: 10px; width: 100%'><div style='width: 40%; float: left;'>" +
                    "<table id='tblDetails" + licount + "'><tr><td style='padding:0px;'><input type='checkbox' " + strChecked + " name='chkContactType" + licount + "'/></td><td><select id='selContactType" + licount + "' name='selContactType" + licount + "' clientidmode='Static' tabindex='4' class='drop_down'><option value='0'>Select</option>" +
                    "<option value='DM'>DM</option><option value='Spouse'>Spouse</option><option value='Partner'>Partner</option><option value='Others'>Others</option></select>" +
                    "</td><td><input type='text' style='width:100px;' id='txtFName" + licount + "' tabindex='7' name='nametxtFName" + licount + "'  placeholder='First Name' data-type='" + licount + "' /></td><td>" +
                    "<input type='text' style='width:100px;' tabindex='7' id='txtLName" + licount + "' name='nametxtLName" + licount + "'  placeholder='Last Name' data-type='" + licount + "' /></td></tr><tr><td class='paddingtd'>" +
                    "<input type='button' id='btnParent" + licount + "' value='Add' data-type='" + licount + "' class='clsFullWidth cls_btn_plus' tabindex='31' onclick='AddTemplate(this)' /></td>" +
                    "</tr></table></div><div style='width: 30%; float: left;'><table id='tblPhone" + licount + "'><tr><td>" +
                    "<input type='text' style='width:70px;' clientidmode='Static' onblur='CheckDuplicatePhone(this);' id='txtPhone" + licount + "' name='nametxtPhone" + licount + "' data-type='" + licount + "' tabindex='7' class='clsMaskPhone'  placeholder='___-___-____' /></td>" +
                    "<td style='width:70px;'><label class='clsFullWidth' style='width:70px;'>Phone Type</label></td><td><select style='width:100px;' class='clsFullWidth' id='selPhoneType" + licount + "' name='nameselPhoneType" + licount + "' data-type='" + licount + "' clientidmode='Static' tabindex='4'>" +
                    "<option value='0'>Select</option><option value='CellPhone'>Cell Phone #</option><option value='HousePhone'>House Phone #</option><option value='WorkPhone'>Work Phone #</option><option value='AltPhone'>Alt. Phone #</option>" +
                    "</select></td></tr><tr><td class='paddingtd'><input type='button' value='Add' data-type='" + licount + "' class='clsFullWidth cls_btn_plus' tabindex='31' onclick='Phone(this)' /></td>" +
                    "</tr></table></div><div style='width: 20%; float: left;'><table id='tblEmail" + licount + "'><tr>" +
                    "<td><input type='text' style='width:160px;' clientidmode='Static' id='txtEMail" + licount + "' onblur='CheckDuplicateEmail(this)' name='nametxtEMail" + licount + "' data-type='" + licount + "' tabindex='7'  placeholder='EMail' /></td></tr><tr><td class='paddingtd'>" +
                    "<input type='button' value='Add' data-type='" + licount + "' class='clsFullWidth cls_btn_plus' tabindex='31' onclick='Email(this)' /></td></tr></table></div></div></li>");

                    $("#selContactType" + licount).val(value.strContactType);
                    $("#txtFName" + licount).val(value.FName);
                    $("#txtLName" + licount).val(value.LName);
                    $("#txtPhone" + licount).val(value.PhoneNumber);
                    $("#selPhoneType" + licount).val(value.PhoneType);
                    $("#txtEMail" + licount).val(value.EMail);
                    childCount = "";
                    chdCount = 0;

                    //Require primary contact selection if there are more than 1 contact; else bubble is default selected                    
                    //if (licount == 1) {                       
                    //    $("#chkContactType" + licount).removeAttr('checked');
                    //    $("#chkContactType" + licount).attar('checked','checked');
                    //    //document.getElementById("chkContactType1").checked = true;
                    //}
                }
                try {
                    $('.clsMaskPhone').mask("999-999-9999");
                } catch (e1) { }
            });

            

            //Primary Product
            $.each(PrimaryProduct, function (key, value) {
                debugger;
                var CurrentDate = new Date;
                var date = CurrentDate.getDate() + "-" + parseInt(CurrentDate.getMonth() + 1) + "-" + CurrentDate.getFullYear() + ": ";
                if (value.strType == 'Est') {
                    $('#ContentPlaceHolder1_drpProductOfInterest1').after("<div style='float:right;width: 100%; text-align: right;'>" + value.ProductName + " - " + date +
                   "<input type='radio' id='Primary1" + PrimaryRadio + "' style='width:12px' name='PrimaryRadio" + PrimaryRadio + "' /> Service Or <input type='radio'id='Primary2" + PrimaryRadio + "' name='PrimaryRadio" + PrimaryRadio
                   + "' checked style='width:12px' value='Est'  />Est " +
                   "<button style='color:white;background-color:#9B3435;width:11px;cursor: pointer;' onclick='removeProduct(this)'>X</button><input type='hidden' id='hdnPrimaryId' name='hdnPrimaryId' value='" + value.ProductId + "'/><input type='hidden' id='hdnPrimaryType' name='hdnPrimaryType' value='Primary'/></div>");
                }
                else {
                    $('#ContentPlaceHolder1_drpProductOfInterest1').after("<div style='float:right;width: 100%; text-align: right;'>" + value.ProductName + " - " + date +
                   "<input type='radio' id='Primary1" + PrimaryRadio + "' style='width:12px' name='PrimaryRadio" + PrimaryRadio + "' checked value='Service' /> Service Or <input type='radio' id='Primary2" + PrimaryRadio + "' name='PrimaryRadio" + PrimaryRadio
                   + "' style='width:12px'/>Est " +
                   "<button style='color:white;background-color:#9B3435;width:11px;cursor: pointer;' onclick='removeProduct(this)'>X</button><input type='hidden' id='hdnPrimaryId' name='hdnPrimaryId' value='" + value.ProductId + "'/><input type='hidden' id='hdnPrimaryType' name='hdnPrimaryType' value='Primary'/></div>");
                }
                PrimaryRadio++;
            });
            //Secondary Product
            $.each(SecondaryProduct, function (key, value) {
                debugger;
                var CurrentDate = new Date;
                var date = CurrentDate.getDate() + "-" + parseInt(CurrentDate.getMonth() + 1) + "-" + CurrentDate.getFullYear() + ": ";
                if (value.strType == 'Est') {
                    $('#ContentPlaceHolder1_drpProductOfInterest2').after("<div style='float:right;width: 100%; text-align: right;'>" + value.ProductName + " - " + date +
                    "<input type='radio' id='Secondary1" + SecondaryRadio + "'  style='width:12px' name='SecondaryRadio" + SecondaryRadio + "' value='Service'/> Service Or <input type='radio' id='Secondary2" + SecondaryRadio + "' name='SecondaryRadio" + SecondaryRadio
                    + "' checked style='width:12px' value='Est' />Est " +
                    "<button style='color:white;background-color:#9B3435;width:11px;cursor: pointer;' onclick='removeProduct(this)'>X</button><input type='hidden' id='hdnSecondaryId' name='hdnSecondaryId' value='" + value.ProductId + "'/><input type='hidden' id='hdnSecondaryType' name='hdnSecondaryType' value='Secondary'/></div>");
                }
                else {
                    $('#ContentPlaceHolder1_drpProductOfInterest2').after("<div style='float:right;width: 100%; text-align: right;'>" + value.ProductName + " - " + date +
                    "<input type='radio' style='width:12px' id='Secondary1" + SecondaryRadio + "' name='SecondaryRadio" + SecondaryRadio + "' checked value='Service' /> Service Or <input type='radio' id='Secondary2" + SecondaryRadio + "' name='SecondaryRadio" + SecondaryRadio
                    + "' style='width:12px' value='Est'  />Est " +
                    "<button style='color:white;background-color:#9B3435;width:11px;cursor: pointer;' onclick='removeProduct(this)'>X</button><input type='hidden' id='hdnSecondaryId' name='hdnSecondaryId' value='" + value.ProductId + "'/><input type='hidden' id='hdnSecondaryType' name='hdnSecondaryType' value='Secondary'/></div>");
                }
                SecondaryRadio++;
            });
            $.each(ContactTime, function (key, value) {
                debugger;
                if (value.BestTimeToContact != "") {
                    var strMultiSelect = "<tr><td colspan='4'>" + value.BestTimeToContact +
                           " <button style='color:white;background-color:#9B3435;width:11px;cursor: pointer;' onclick='removeTime(this)'>X</button>" +
                           "</td></tr>";
                    $(".tblBestTimeToContact>tbody").append(strMultiSelect);
                }
            });
            //Bind Billing Address
            var div = "";
            $.each(BillingAddressValue, function (index, value) {
                debugger;
                if (index == 0) {
                    $("#txtbill_address1").val(value.strBillingAddress)
                    $("#selAddressType").val(value.strBillingAddressType)
                    $("#chkbillingaddress").attr("checked", true)
                    div = $("#chkbillingaddress")
                }
                else {
                    $(div).closest('tr').after("<tr><td><div>" +
                    "<input type='checkbox' id='chkbillingaddress" + index + "' style='width:5%' tabindex='20' checked='checked' clientidmode='Static' onchange='BillingAddress(this)' />" +
                    "</div><label><span>*</span>Billing Address" + (index) + " Same</label>" +
                    "<textarea id='txtbill_address" + (index + 1) + "' name='BillAddress" + (index + 1) + "' style='width:50%' clientidmode='Static' rows='6' tabindex='21'>" + value.strBillingAddress + "</textarea>" +
                    "<label></label><span id='spnAddress" + (index + 1) + "'></span></br></br><label> Address Type" + (index) + "<span>*</span></label>" +
                    "<select id='selAddressType" + (index + 1) + "' clientidmode='Static' name='AddressType" + (index + 1) + "'><option Value='Select'>Select</option>" +
                    "<option value='Primary Residence'>Primary Residence</option><option value='Business'>Business</option>" +
                    "<option value='Vacation House'>Vacation House</option><option value='Rental'>Rental</option><option value='Condo'>Condo</option>" +
                    "<option value='Apartment'>Apartment</option><option value='Mobile Home'>Mobile Home</option><option value='Other'>Other</option></select></td></tr>");
                    $("#selAddressType" + (index + 1)).val(value.strBillingAddressType);

                    if (index == 1) {
                        $("#chkbillingaddress").attr("checked", false);
                    }
                    else {
                        $("#chkbillingaddress" + (index - 1)).attr("checked", false);
                    }

                    div = $("#chkbillingaddress" + index);
                }

            });
        },
        failure: function (response) {
            alert(response.d);
        }
    });
}

function AddTemplate(e) {
    debugger;

    var liCount = $("#divPrimaryContact ul li").length + 1;

    $(e).closest('li').after("<li style='width: 100%;'><div class='tblPrimaryContact' style='margin-top: 10px; width: 100%'><div style='width: 40%; float: left;'>" +
    "<table><tr><td><input type='checkbox' id='chkContactType" + liCount + "' name='chkContactType " + liCount + "'/></td><td><select id='selContactType" + liCount + "' name='selContactType" + liCount + "' clientidmode='Static' tabindex='4' class='drop_down'><option value='0'>Select</option>" +
    "<option value='DM'>DM</option><option value='Spouse'>Spouse</option><option value='Partner'>Partner</option><option value='Others'>Others</option></select><label></label>" +
    "</td><td><input type='text' id='txtFName" + liCount + "' tabindex='7' name='nametxtFName" + liCount + "'  placeholder='First Name' data-type='" + liCount + "' /></td><td>" +
    "<input type='text' tabindex='7' id='txtLName" + liCount + "' name='nametxtLName" + liCount + "'  placeholder='Last Name' data-type='" + liCount + "' /></td></tr><tr><td class='paddingtd'>" +
    "<input type='button' value='Add' data-type='" + liCount + "' class='clsFullWidth cls_btn_plus' tabindex='31' onclick='AddTemplate(this)' /></td>" +
    "</tr></table></div><div style='width: 40%; float: left;'><table><tr><td class='paddingtd'></td><td>" +
    "<input type='text' clientidmode='Static' id='txtPhone" + liCount + "' name='nametxtPhone" + liCount + "' data-type='" + liCount + "' tabindex='7' class='clsMaskPhone'  placeholder='___-___-____' onblur='CheckDuplicatePhone(this)' /></td>" +
    "<td><label class='clsFullWidth'>Phone Type</label></td><td><select class='clsFullWidth' id='selPhoneType" + liCount + "' name='nameselPhoneType" + liCount + "' data-type='" + liCount + "' clientidmode='Static' tabindex='4'>" +
    "<option value='0'>Select</option><option value='CellPhone'>Cell Phone #</option><option value='HousePhone'>House Phone #</option><option value='WorkPhone'>Work Phone #</option><option value='AltPhone'>Alt. Phone #</option>" +
    "</select></td></tr><tr><td class='paddingtd'><input type='button' value='Add' data-type='" + liCount + "' class='clsFullWidth cls_btn_plus' tabindex='31' onclick='Phone(this)' /></td>" +
    "</tr></table></div><div style='width: 20%; float: left;'><table><tr><td class='paddingtd'></td>" +
    "<td><input type='text' clientidmode='Static' id='txtEMail" + liCount + "' name='nametxtEMail" + liCount + "' data-type='" + liCount + "' tabindex='7'  placeholder='EMail' onblur='CheckDuplicateEmail(this)' /></td></tr><tr><td class='paddingtd'>" +
    "<input type='button' value='Add' data-type='" + liCount + "' class='clsFullWidth cls_btn_plus' tabindex='31' onclick='Email(this)' /></td></tr></table></div></div></li>");
    $('.clsMaskPhone').mask("999-999-9999");
    $(e).css("visibility", "hidden");
}

function BillingAddress(e) {
    debugger;
    //Start Get value from UserControl
    var UcAddress = $('#ContentPlaceHolder1_UCAddress_txtaddress').val();
    var UcCity = $('#ContentPlaceHolder1_UCAddress_txtcity').val();
    var UcState = $('#ContentPlaceHolder1_UCAddress_txtstate').val();
    var UcZipCode = $('#ContentPlaceHolder1_UCAddress_txtzip').val();
    var UcSelAddress = document.getElementById("ContentPlaceHolder1_UCAddress_DropDownList1");
    var UcAddressType = UcSelAddress.options[UcSelAddress.selectedIndex].value;
    //End Get value from UserControl
    var BillingAddress = $(e).closest('tr').find('textarea').val('');
    var AddressType = $(e).closest('tr').find('select').val('0')
    //var Address = document.getElementById("selAddressType");
    //var BillingAddress = $('#txtbill_address').text();
    //var AddressType = Address.options[Address.selectedIndex].value;
    var lastChar = $(e).closest('tr').text().trim().split(" ")[1];
    var count = lastChar.slice(-1);
    //$('#txtbill_address').text("");
    //$('#selAddressType').val("0");
    if (count != "s") {
        //$('#txtbill_address1').text("");
        //$('#selAddressType1').val("0");
        var NewCount = parseInt(count, 10) + 1
        if ($("#chkbillingaddress" + count).is(':checked')) {
            var address = ($("#ContentPlaceHolder1_UCAddress_txtaddress" + count).val() == undefined) ? "" : $("#ContentPlaceHolder1_UCAddress1_txtaddress" + count).val();
            var city = ($("#ContentPlaceHolder1_UCAddress_txtcity" + count).val() == undefined) ? "" : $("#ContentPlaceHolder1_UCAddress1_txtcity" + count).val();
            var state = ($("#ContentPlaceHolder1_UCAddress_txtstate" + count).val() == undefined) ? "" : $("#ContentPlaceHolder1_UCAddress1_txtstate" + count).val();
            var zip = ($("#ContentPlaceHolder1_UCAddress_txtzip" + count).val() == undefined) ? "" : $("#ContentPlaceHolder1_UCAddress1_txtzip" + count).val();

            //$("#txtbill_address" + count).val(address + " " + city + " " + state + " " + zip);
            $(e).closest('tr').find('textarea').val(UcAddress + " " + UcCity + " " + UcState + " " + UcZipCode)
            //$(e).closest('tr').next().remove();
            for (var i = 0; i < $(e).closest('tr').nextAll().length + 1; i++) {
                if ($(e).closest('tr').next().children().children()[2] != undefined) {

                    $(e).closest('tr').next().remove();
                }
            }
            // $(e).closest('tr').nextAll('tr:not(.bt)').remove();
        }
        else {
            $("#txtbill_address" + count).val("");
            $(e).closest('tr').after("<tr><td><div>" +
            "<input type='checkbox' id='chkbillingaddress" + NewCount + "' style='width:5%' tabindex='20' checked='checked' onchange='BillingAddress(this)' />" +
            "</div><label><span>*</span>Billing Address" + NewCount + " Same</label><textarea id='txtbill_address" + NewCount + "' name='BillAddress" + NewCount + "' style='width:50%' rows='6' tabindex='21'></textarea><label></label><span id='spnAddress" + NewCount + "'></span></br></br><label> Address" + NewCount + " Type<span>*</span></label><select id='selAddressType" + NewCount + "' name='AddressType" + NewCount + "'><option Value='Select'>Select</option><option value='Primary Residence'>Primary Residence</option><option value='Business'>Business</option><option value='Vacation House'>Vacation House</option><option value='Rental'>Rental</option><option value='Condo'>Condo</option><option value='Apartment'>Apartment</option><option value='Mobile Home'>Mobile Home</option><option value='Other'>Other</option></select></td></tr>");
            $("#txtbill_address" + NewCount + "").text(UcAddress + " " + UcCity + " " + UcState + " " + UcZipCode);
            $("#selAddressType" + NewCount + "").val(UcAddressType);
        }
    }
    else {
        if ($("#chkbillingaddress").is(':checked')) {
            //$("#txtbill_address").val($("#ContentPlaceHolder1_txtaddress").val() + " " + $("#ContentPlaceHolder1_txtcity").val() + " " + $("#ContentPlaceHolder1_txtstate").val() + " " +
            //$("#ContentPlaceHolder1_txtzip").val());
            $(e).closest('tr').find('textarea').val(UcAddress + " " + UcCity + " " + UcState + " " + UcZipCode)
            $('#selAddressType').val(UcAddressType);
            //$(e).closest('tr').next().remove();
            for (var i = 0; i < $(e).closest('tr').nextAll().length + 1; i++) {
                if ($(e).closest('tr').next().children().children()[2] != undefined) {

                    $(e).closest('tr').next().remove();
                }
            }

        }
        else {
            //$("#txtbill_address").val("");
            $(e).closest('tr').after("<tr><td><div>" +
           "<input type='checkbox' id='chkbillingaddress1' style='width:5%' tabindex='20' checked='checked' onchange='BillingAddress(this)' />" +
           "</div><label><span>*</span>Billing Address1 Same</label><textarea id='txtbill_address1' name='BillAddress1' style='width:50%' rows='6' tabindex='21'></textarea><label></label><span id='spnAddress1'></span></br></br><label> Address1 Type <span>*</span></label><select id='selAddressType1' name='AddressType1'><option Value='Select'>Select</option><option value='Primary Residence'>Primary Residence</option><option value='Business'>Business</option><option value='Vacation House'>Vacation House</option><option value='Rental'>Rental</option><option value='Condo'>Condo</option><option value='Apartment'>Apartment</option><option value='Mobile Home'>Mobile Home</option><option value='Other'>Other</option></select></td></tr>");
            $('#txtbill_address1').text(UcAddress + " " + UcCity + " " + UcState + " " + UcZipCode);
            $('#selAddressType1').val(UcAddressType);
        }
    }

}